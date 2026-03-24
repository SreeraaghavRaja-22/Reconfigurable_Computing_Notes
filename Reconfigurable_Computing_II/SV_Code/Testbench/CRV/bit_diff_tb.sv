`timescale 1 ns / 10 ps

// Module: bit_diff_tb_basic
// Description: Follows the simple template seen so far. Although simple, this
// template has significant limitations that become more apparent when doing
// more complex tests that are required for more complex modules.
//
// Specificially, a testbench often has the following primary parts:
// -Generation of test sequences that stimulate the DUT
// -A driver that converts that test sequences into DUT pin values
// -A monitor that detects the beginning of a test and saves the inputs.
// -A monitor that detects DUT outputs for new results or other behaviors.
// -A scoreboard that takes test inputs and outputs from the monitors and compares 
//  results with a reference model that is applied to the same test sequences.
//
// The primary limitation of this simple testbench is that it does all these
// parts in the same region of code. This makes it hard to modify one part
// without affecting the others. It also makes it hard for other people to
// understand the purpose of the code. Finally, it doesn't scale well to
// complicated tests, and multiple types of tests.
//
// So, we'll first understand this basic testbench and then gradually transform
// it into something where the different parts are isolated from each other.

module bit_diff_tb_basic;

    localparam NUM_TESTS = 1000;
    localparam WIDTH = 16;

    logic clk = 1'b0, rst, go, done;
    logic [WIDTH-1:0] data;
    logic signed [$clog2(2*WIDTH+1)-1:0] result;

    // Testbench variables -- Collect Statistics
    int passed, failed, reference;

    // Instantiate the DUT
    bit_diff #(.WIDTH(WIDTH)) DUT (.*);

    // Reference model for getting the correct result.
    function int model(int data, int width);
        automatic int diff = 0;

        for (int i = 0; i < width; i++) begin
            diff = data[0] ? diff + 1 : diff - 1;
            data = data >> 1;
        end

        return diff;
    endfunction

    // Generate the clock.
    initial begin : generate_clock
        forever #5 clk <= ~clk;
    end

    // Do everything else.
    initial begin
        $timeformat(-9, 0, " ns");

        passed = 0;
        failed = 0;

        // Reset the design.
        rst  <= 1'b1;
        go   <= 1'b0;
        data <= '0;
        for (int i = 0; i < 5; i++) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;

        // Perform NUM_TESTS number of random tests.
        for (int i = 0; i < NUM_TESTS; i++) begin
            data <= $random;
            go   <= 1'b1;
            @(posedge clk);
            go <= 1'b0;

            // Works for registered outputs, but not safe for glitches that may
            // occur from combinational logic outputs.
            // Test bit_diff_fsmd_2p for an example of where this fails.
            //@(posedge done);

            // Instead, wait until done is cleared on an edge, and then asserted 
            // on an edge.
            @(posedge clk iff (done == 1'b0));
            //$display("Done is 0 (time %0t).", $time);     
            @(posedge clk iff (done == 1'b1));
            //$display("Done is 1 (time %0t).", $time);

            // Similar strategy, but less concise
            /*while(1) begin
            @(posedge clk);
            if (done) break;        
         end */

            // Compare the output with the expected model.
            expected = model(data, WIDTH);
            if (result == expected) begin
                $display("Test passed (time %0t) for input = %h", $time, data);
                passed++;
            end else begin
                $display("Test failed (time %0t): result = %0d instead of %0d for input = %h.", $time, result, expected, data);
                failed++;
            end
        end

        $display("Tests completed: %0d passed, %0d failed", passed, failed);
        disable generate_clock;
    end

    // Check to make sure done cleared within a cycle. Go is anded with done
    // because go should have no effect when the circuit is already active.
    assert property (@(posedge clk) disable iff (rst) go && done |=> !done);

    // Check to make sure done is only cleared when go is asserted (i.e. done is
    // left asserted indefinitely).
    assert property (@(posedge clk) disable iff (rst) $fell(done) |-> $past(go, 1));

endmodule  // bit_diff_tb_basic


// First Look at TB with different processes with different tasks
// Issues: starts new test as soon as the previous test finishes -- never tests for delays between tests
module bit_diff_tb_no_heirarchy; #(
    parameter int NUM_TESTS = 1000, 
    parameter int WIDTH = 16,
    parameter bit TOGGLE_INPUTS_WHILE_ACTIVE = 1'b1,
    parameter bit LOG_START_MONITOR = 1'b1,
    parameter bit LOG_DONE_MONITOR = 1'b1,
    parameter int MIN_CYCLES_BETWEEN_TESTS = 0,
    parameter int MAX_CYCLES_BETWEEN_TESTS = 10
);

    logic clk = 1'b0, rst, go, done;
    logic [WIDTH-1:0] data;
    logic signed [$clog2(2*WIDTH+1)-1:0] result;

    // Testbench variables
    int passed, failed;

    // Create a class for our transaction object / item
    class bit_diff_item; 
        rand bit [WIDTH-1:0] data; 
    endclass

    // Create instances of mailboxes
    mailbox driver_mailbox = new; 
    mailbox scoreboard_data_mailbox = new; 
    mailbox scoreboard_result_mailbox = new; 

    // Instantiate the DUT
    bit_diff #(.WIDTH(WIDTH)) DUT (.*);

    // Reference model for getting the correct result.
    function int model(int data, int width);
        automatic int diff = 0;

        for (int i = 0; i < width; i++) begin
            diff = data[0] ? diff + 1 : diff - 1;
            data = data >> 1;
        end

        return diff;
    endfunction

    // Generate the clock.
    initial begin : generate_clock
        forever #5 clk <= ~clk;
    end

    initial begin : initialization
        rst <= 1'b1; 
        go  <= 1'b0; 
        data <= '0; 
        repeat(5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0; 
    end

    initial begin : generator
        bit_diff_item test; 
        for (int i = 0; i < NUM_TESTS; i++) begin 
            test = new(); 
            assert(test.randomize()) else $fatal(1, "Randomization failed.");
            // Mailbox is like a queue that is thread-safe and has blocking calls that waits
            // until there is something in the mailbox before activating
            driver_mailbox.put(test);
        end 

        
    end

    initial begin : driver
        bit_diff_item test; 

        @(posedge clk iff !rst); 

        forever begin 
            driver_mailbox.get(test);
            $display("[%0t] Driver starting a new test for %0d", $realtime, test.data);

            data <= test.data; 
            go <= 1'b1; 
            @(posedge clk);
            go <= 1'b0; 
            @(posedge clk);
            @(posedge clk iff done);

            
            // Tackles the limitation of monolithic testbenches not being able to toggle inputs while a test is running
            if (TOGGLE_INPUTS_WHILE_ACTIVE) begin 
                while (!done) begin 
                    data <= $urandom; 
                    go   <= $urandom; 
                    @(posedge clk);
                end
            end else begin 
                @(posedge clk iff (done == 1'b1));
            end

            // add a random delay between tests
            repeat ($urandom_range(MIN_CYCLES_BETWEEN_TESTS-1, MAX_CYCLES_BETWEEN_TESTS-1)) @(posedge clk);
        end
    end

    initial begin : start_monitor
        // create a case for the first test
        @(posedge clk iff !rst && go);
        scoreboard_data_mailbox.put(data);
        if (LOG_START_MONITOR) $display("[%0t] Start monitor detected test with data = %0h", $realtime, data);

        forever begin 
            @(posedge clk iff done && go);
            scoreboard_data_mailbox.put(data);
            if (LOG_START_MONITOR) $display("[%0t] Start monitor detected test with data=%0h", $realtime, data);
        end
    end

    initial begin : done_monitor
        forever begin
            @(posedge clk iff (done == 1'b0));
            @(posedge clk iff (done == 1'b1));
            scoreboard_result_mailbox.put(result);
            if (LOG_DONE_MONITOR) $display("[%0t] Done monitor detected completion with result = %0h", $realtime, result);
        end 
    end

    initial begin : scoreboard
        logic [WIDTH-1:0] data;
        logic signed [$clog2(2*WIDTH+1)-1:0] actual, expected;

        passed = 0; 
        failed = 0; 

        for (int i = 0; i < NUM_TESTS; i++) begin 
            scoreboard_data_mailbox.get(data);
            scoreboard_result_mailbox.get(actual);

            expected = model(data, WIDTH);

            if (actual == expected) begin
                $display("Test passed (time %0t) for input = %h", $time, data);
                passed++;
            end else begin
                $display("Test failed (time %0t): result = %0d instead of %0d for input = %h.", $time, actual, expected, data);
                failed++;
            end
        end

        $display("Tests completed: %0d passed, %0d failed", passed, failed);
        disable generate_clock;
    end

    // Check to make sure done cleared within a cycle. Go is anded with done
    // because go should have no effect when the circuit is already active.
    assert property (@(posedge clk) disable iff (rst) go && done |=> !done);

    // Check to make sure done is only cleared when go is asserted (i.e. done is
    // left asserted indefinitely).
    assert property (@(posedge clk) disable iff (rst) $fell(done) |-> $past(go, 1));

endmodule  // bit_diff_tb_no_heirarchy
