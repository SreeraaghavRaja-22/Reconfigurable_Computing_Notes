`timescale 1ns / 100ps

module register_tb1;

    localparam int NUM_TESTS = 10000; 
    localparam int WIDTH = 8; 
    logic clk = 1'b0, rst, en; 
    logic [WIDTH-1:0] in, out; 

    register #(.WIDTH(WIDTH)) DUT (.*);

    initial begin : generate_clk
        forever #5 clk <= !clk; 
    end 

    initial begin 
        rst <= 1'b1; 
        in  <= '0; 
        en  <= 1'b0; 
        // for (int i = 0; i < 5; i++) @(posedge clk)
        repeat(5) @(posedge clk);
        @(negedge clk); 
        rst <= 1'b0; 
        repeat(2) @(posedge clk);

        for (int i = 0; i < NUM_TESTS; i++) begin 
            in <= $urandom; // don't ever use random beacuse the distribution is not uniform (urandom might be uniform random, so provides a more unifrom distro than random)
            en <= 1'b1; 
            @(posedge clk);

            // verify that everything is working properly

            if(out !== in) $error("ERROR!!!");
        end

        $display("Tests Completed!");
        disable generate_clk; // necessary to stop the simulation
    end
endmodule 


module register_tb2;
    localparam int NUM_TESTS = 10000; 
    localparam int WIDTH = 8; 
    logic clk=1'b0, rst, en; 
    logic [WIDTH-1:0] in, out;
    logic [WIDTH-1:0] prev_in, prev_out;
    logic prev_en;  

    register #(.WIDTH(WIDTH)) DUT(.*);

    initial begin : generate_clk; 
        forever #5 clk <= !clk; 
    end

    initial begin : provide_stimulus
        rst <= 1'b1; 
        in <= '0;
        en <= 1'b0; 
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        repeat (2) @(posedge clk);

        for(int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom; 
            en <= $urandom; 
            @(posedge clk);
        end 
        
        $display("Tests completed.");
        disable generate_clk; 
    end 

    initial begin : check_outputs
        forever begin 
            @(posedge clk);
            prev_in = in; // can use blocking assignment becuase no race conditions / prev_in is not being used in any other process
            prev_en = en; 
            prev_out = out;
            @(negedge clk); // not the best solution either #1 is also bad usually check stuff on a rising clock edge
            if (prev_en && prev_in != out) $error("[%0t] out = %d instead of %d.", $time, out, prev_in);
            if (!prev_en && out != prev_out) $error("[%0t] out = %d instead of %d.", $time, out, prev_out);
            if (out != in) $error("Expected=%0h, Actual=%0h", prev_in, out); // module to check outputs
        end 
    end

endmodule 

module register_tb3;
    localparam int NUM_TESTS = 10000; 
    localparam int WIDTH = 8; 
    logic clk=1'b0, rst, en; 
    logic [WIDTH-1:0] in, out;
    logic [WIDTH-1:0] prev_in, prev_out;
    logic prev_en;  

    register #(.WIDTH(WIDTH)) DUT(.*);

    initial begin : generate_clk; 
        forever #5 clk <= !clk; 
    end

    initial begin : provide_stimulus
        rst <= 1'b1; 
        in <= '0;
        en <= 1'b0; 
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        repeat (2) @(posedge clk);

        for(int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom; 
            en <= $urandom; 

            // starting tests earlier by doing it this way
            prev_en <= en; 
            prev_in <= in; 
            prev_out <= out; 
            @(posedge clk);
        end 
        
        $display("Tests completed.");
        disable generate_clk; 
    end 

    initial begin : check_outputs
        forever begin 
            @(posedge clk);
            if (prev_en && prev_in != out) $error("[%0t] out = %d instead of %d.", $time, out, prev_in);
            if (!prev_en && out != prev_out) $error("[%0t] out = %d instead of %d.", $time, out, prev_out);
            if (out != in) $error("Expected=%0h, Actual=%0h", prev_in, out); // module to check outputs
        end 
    end

endmodule 


module register_tb4;
    localparam int NUM_TESTS = 10000; 
    localparam int WIDTH = 8; 
    logic clk=1'b0, rst, en; 
    logic [WIDTH-1:0] in, out;
    logic [WIDTH-1:0] expected; 

    register #(.WIDTH(WIDTH)) DUT(.*);

    initial begin : generate_clk; 
        forever #5 clk <= !clk; 
    end

    initial begin : provide_stimulus
        rst <= 1'b1; 
        in <= '0;
        en <= 1'b0; 
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        repeat (2) @(posedge clk);

        for(int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom; 
            en <= $urandom; 

            // starting tests earlier by doing it this way
            prev_en <= en; 
            prev_in <= in; 
            prev_out <= out; 
            @(posedge clk);
        end 
        
        $display("Tests completed.");
        disable generate_clk; 
    end 

    // this is still overkill for a register
    initial begin : monitor
        @(posedge clk iff !rst); // wait until we're out of reset / for a valid output
        forever begin 
            // Check for some condition where there is a valid output
            expected <= en ? in : out; 
            @(posedge clk); 
        end
    end

    initial begin : check_outputs
        @(posedge clk iff !rst);
        forever begin 
            @(posedge clk); // need this to wait until we have our actual output and verify it
            // if (expected != out) $error("Expected=%0h, Actual=%0d", expected, out);
            assert(expected == out) else $error("Expected=%0h, Actual=%0d", expected, out); // immediate assertions don't save much code compared to if statement

        end            
    end
endmodule 




