// This file illustrates how to create a testbench for a simple pipeline
// with an enable. Notice how concise the testbench is. More importantly,
// notice how to make it work most pipelines, you only need to change the
// model. I personally use this as a template for pipeline testbenches in
// the vast majority of my pipelines.

`timescale 1 ns / 100 ps

// Module: simple_pipeline_with_en_tb_bad.
// Description: This testbench demonstrates a concise way of testing all the
// functionality of a pipeline, but with a subtle bug that is common.

module simple_pipeline_with_en_tb_bad #(
    parameter int NUM_TESTS = 10000,
    parameter int WIDTH = 8
);
    logic clk = 1'b0, rst, en, valid_in, valid_out;
    logic [WIDTH-1:0] data_in[8];
    logic [WIDTH-1:0] data_out;

    simple_pipeline_with_en #(.WIDTH(WIDTH)) DUT (.*);

    initial begin : generate_clock
        forever #5 clk <= ~clk;
    end

    initial begin
        $timeformat(-9, 0, " ns");

        // Reset the circuit.
        rst      <= 1'b1;
        en       <= 1'b0;
        valid_in <= 1'b0;
        data_in  <= '{default: '0};
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        @(posedge clk);

        // Run the tests.      
        for (int i = 0; i < NUM_TESTS; i++) begin
            en <= $urandom;
            for (int j = 0; j < 8; j++) data_in[j] <= $urandom;
            valid_in <= $urandom;
            @(posedge clk);
        end

        $display("Tests completed.");
        disable generate_clock;
    end

    // Although this function is a correct reference model for the pipeline,
    // when it is used as part of the assertion, it provides incorrect
    // results because the out variable has already been updated with the new
    // output value, but the in input corresponds to the old sampled value provided
    // by the assertion.
    //
    // IMPORTANT: avoid reading from variables that aren't provided as parameters
    // from the assertion itself. Assertions sample values on clock edges, whereas
    // other variable can be updated at any time.
    function automatic logic is_out_correct(logic [WIDTH-1:0] data_in[8]);
        logic [WIDTH-1:0] sum = 0;
        for (int i = 0; i < 4; i++) sum += data_in[i*2] * data_in[i*2+1];
        return sum == data_out; // data_out looks like it's correct but changes immediately after, so you will get an error 
    endfunction

    // Verify data_out and valid_out. 
    // Can access parameters in the DUT if you're not careful
	// Have someone else write a testbench for your module to prevent bias from how you write your module 
	// White-Box Test because we use information from our module to test it (slight bias)
	// Black-Box Testing is much more common 
    assert property (@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> is_out_correct($past(data_in, DUT.LATENCY, en)));
    assert property (@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> valid_out == $past(valid_in, DUT.LATENCY, en));

    // Verify the reset clears the outputs until the pipeline has filled.
    assert property (@(posedge clk) $fell(rst) |-> data_out == '0 throughout en [-> DUT.LATENCY]);
    assert property (@(posedge clk) $fell(rst) |-> !valid_out throughout en [-> DUT.LATENCY]);

    // Verify enable stalls the outputs.
    assert property (@(posedge clk) !en |=> $stable(data_out) && $stable(valid_out));

    // Make sure all pipeline stages are reset.
    assert property (@(posedge clk) rst |=> data_out == '0);

endmodule

// Module: simple_pipeline_with_en_tb1.
// Description: This testbench corrects the bug from the previous module.

module simple_pipeline_with_en_tb1 #(
    parameter int NUM_TESTS = 10000,
    parameter int WIDTH = 8
);
    logic clk = 1'b0, rst, en, valid_in, valid_out;
    logic [WIDTH-1:0] data_in[8];
    logic [WIDTH-1:0] data_out;

    simple_pipeline_with_en #(.WIDTH(WIDTH)) DUT (.*);

    initial begin : generate_clock
        forever #5 clk <= ~clk;
    end

    initial begin
        $timeformat(-9, 0, " ns");

        // Reset the circuit.
        rst      <= 1'b1;
        en       <= 1'b0;
        valid_in <= 1'b0;
        data_in  <= '{default: '0};
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        @(posedge clk);

        // Run the tests.      
        for (int i = 0; i < NUM_TESTS; i++) begin
            en <= $urandom;
            for (int j = 0; j < 8; j++) data_in[j] <= $urandom;
            valid_in <= $urandom;
            @(posedge clk);
        end

        $display("Tests completed.");
        disable generate_clock;
    end

    // In this version, all values we need to compare are provided as inputs from
    // the sampled values in the assertion.
	// Pass in data_in and data_out so we get the asserted value of data_out to compare to sum
    function automatic logic is_out_correct(logic [WIDTH-1:0] data_in[8], logic [WIDTH-1:0] data_out);
        logic [WIDTH-1:0] sum = 0;
        for (int i = 0; i < 4; i++) sum += data_in[i*2] * data_in[i*2+1];
        return sum == data_out;
    endfunction

    // Verify data_out and valid_out
    assert property (@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> is_out_correct($past(data_in, DUT.LATENCY, en), data_out)); // reads sampled data_out value
    assert property (@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> valid_out == $past(valid_in, DUT.LATENCY, en));

    // Verify the reset clears the outputs until the pipeline has filled.
    assert property (@(posedge clk) $fell(rst) |-> data_out == '0 throughout en [-> DUT.LATENCY]);
    assert property (@(posedge clk) $fell(rst) |-> !valid_out throughout en [-> DUT.LATENCY]);

    // Verify enable stalls the outputs.
    assert property (@(posedge clk) !en |=> $stable(data_out) && $stable(valid_out));
	
	/* Use Separate Assertions for More Error Messages
	assert property (@(posedge clk) !en |=> $stable(data_out));
	assert property (@(posedge clk) !en |=> $stable(valid_out));
	*/

    // Make sure all pipeline stages are reset.
    assert property (@(posedge clk) rst |=> data_out == '0);
	assert property (@(posedge clk) rst |=> !valid);

endmodule

// Module: simple_pipeline_with_en_tb2
// Description: Create a model to compare with DUT
module simple_pipeline_with_en_tb2 #(
    parameter int NUM_TESTS = 10000,
    parameter int WIDTH = 8
);
    logic clk = 1'b0, rst, en, valid_in, valid_out;
    logic [WIDTH-1:0] data_in[8];
    logic [WIDTH-1:0] data_out;

    simple_pipeline_with_en #(.WIDTH(WIDTH)) DUT (.*);

    initial begin : generate_clock
        forever #5 clk <= ~clk;
    end

    initial begin
        $timeformat(-9, 0, " ns");

        // Reset the circuit.
        rst      <= 1'b1;
        en       <= 1'b0;
        valid_in <= 1'b0;
        data_in  <= '{default: '0};
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        @(posedge clk);

        // Run the tests.      
        for (int i = 0; i < NUM_TESTS; i++) begin
            en <= $urandom;
            for (int j = 0; j < 8; j++) data_in[j] <= $urandom;
            valid_in <= $urandom;
            @(posedge clk);
        end

        $display("Tests completed.");
        disable generate_clock;
    end

    // Create a model to compare with DUT
    function automatic logic model(logic [WIDTH-1:0] data_in[8]);
        logic [WIDTH-1:0] sum = 0;
        for (int i = 0; i < 4; i++) sum += data_in[i*2] * data_in[i*2+1];
        return sum;
    endfunction

    // Use this comparison
    assert property(@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> data_out == model($past(data_in, DUT.LATENCY, en))); 

    // Verify data_out and valid_out
    assert property (@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> is_out_correct($past(data_in, DUT.LATENCY, en), data_out)); // reads sampled data_out value
    assert property (@(posedge clk) disable iff (rst) en [-> DUT.LATENCY] |=> valid_out == $past(valid_in, DUT.LATENCY, en));

    // Verify the reset clears the outputs until the pipeline has filled.
    assert property (@(posedge clk) $fell(rst) |-> data_out == '0 throughout en [-> DUT.LATENCY]);
    assert property (@(posedge clk) $fell(rst) |-> !valid_out throughout en [-> DUT.LATENCY]);

    // Verify enable stalls the outputs.
    assert property (@(posedge clk) !en |=> $stable(data_out) && $stable(valid_out));
	
	/* Use Separate Assertions for More Error Messages
	assert property (@(posedge clk) !en |=> $stable(data_out));
	assert property (@(posedge clk) !en |=> $stable(valid_out));
	*/

    // Make sure all pipeline stages are reset.
    assert property (@(posedge clk) rst |=> data_out == '0);
	assert property (@(posedge clk) rst |=> !valid);

endmodule


// Instead of DUT.LATENCY do this to get rid of white box testing
package simple_pipeline_with_en_pkg; 
    function automatic int latency//(num_inputs);
        return 4; // could also be 4 * num_inputs;
    endfunction
endpackage

// Module: simple_pipeline_with_en_tb3
// Description: Package Example
module simple_pipeline_with_en_tb2 
    import simple_pipeline_with_en_pkg::latency;
#(
    parameter int NUM_TESTS = 10000,
    parameter int WIDTH = 8
);
    logic clk = 1'b0, rst, en, valid_in, valid_out;
    logic [WIDTH-1:0] data_in[8];
    logic [WIDTH-1:0] data_out;

    localparam int latency = simple_pipeline_with_en_pkg::latency();

    simple_pipeline_with_en #(.WIDTH(WIDTH)) DUT (.*);

    initial begin : generate_clock
        forever #5 clk <= ~clk;
    end

    initial begin
        $timeformat(-9, 0, " ns");

        // Reset the circuit.
        rst      <= 1'b1;
        en       <= 1'b0;
        valid_in <= 1'b0;
        data_in  <= '{default: '0};
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;
        @(posedge clk);

        // Run the tests.      
        for (int i = 0; i < NUM_TESTS; i++) begin
            en <= $urandom;
            for (int j = 0; j < 8; j++) data_in[j] <= $urandom;
            valid_in <= $urandom;
            @(posedge clk);
        end

        $display("Tests completed.");
        disable generate_clock;
    end

    // Create a model to compare with DUT
    function automatic logic model(logic [WIDTH-1:0] data_in[8]);
        logic [WIDTH-1:0] sum = 0;
        for (int i = 0; i < 4; i++) sum += data_in[i*2] * data_in[i*2+1];
        return sum;
    endfunction

    // Use this comparison
    //assert property(@(posedge clk) disable iff (rst) en [-> latency] |=> data_out == model($past(data_in, latency, en))); 

    // The assertion above works really well when our model returns a value that "makes sense / are meaningful"
    // Solution: we need a flag to determine when our input is valid / defined
    assert property (@(posedge clk) disable iff (rst) valid_in |-> en[-> latency] ##1 data_out == model($past(data_in, latency, en)));

    // test valid_in
    // Common: assert property (@(posedge clk) disable iff (rst) en[-> latency] |=> valid_out == $past(valid_in, latency, en));

    // New Method: Define Property where you look at something when it occurs and saving it and looking back at it later
    property check_output_p; 
        logic [WIDTH-1:0] correct_data_out;
        @(posedge clk) disable iff (rst) (valid_in && en, correct_data_out = model(data_in)) |-> en [-> latency] ##1 data_out == correct_data_out;
    endproperty

    // assert the property
    assert property (check_output_p);

    // Common Bugs

    // 1: Forgetting the en when defining the property 
    // 2: 
    
    // What to look at next 
    // FIFO_TB 
    // make sure to read through the whole thing

endmodule