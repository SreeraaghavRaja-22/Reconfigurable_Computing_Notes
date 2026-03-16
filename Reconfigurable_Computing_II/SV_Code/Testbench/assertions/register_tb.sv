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
			// SystemVerilog will evaluate all undefined values to false, so 
			if (1'bX) $display("123456789"); // will evaluate to false
			if (!1'bX) $display("123456789"); // will also evaluate to false...why?
			// What's the opposite of an undefined value?? -- AN UNDEFINED VALUE!!
			// == and === logical vs. case 
			// != and !== logical vs. case (compares explicit values)
			// case operators are not synthesizable
			
			// Common Gotchas
			
			// 4'b0010 == 4'b0100
			// 4'bX010 != 4'b0100 	=>  4'bXXXX => false
			// 4'bX100 != 4'b0100   =>  false
			// 4'bX100 !== 4'b0100  =>  true
			
			
			
            if (prev_en === 1'b1 && prev_in !== out) $error("[%0t] out = %d instead of %d.", $time, out, prev_in);
            if (prev_en !== 1'b1 && out !== prev_out) $error("[%0t] out = %d instead of %d.", $time, out, prev_out); 
			// be really careful with conditions when you have undefines because prev_en !== 1'b1 reports errors, but prev_en === 1'b0 doesn't report errors
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

/*----------------------------- ASSERTIONS -----------------------------*/
`timescale 1 ns / 10 ps

// Module: reigster_no_en_tb_bad
// Description: This module implements a testbench for the register using 
// assertions, with the simplifying assumption that enable is always asserted. 
// This module shows how there can be subtle testbench problems that cause 
// assertion failures.

module register_no_en_tb_bad #(
    parameter int NUM_TESTS = 10000,
    parameter WIDTH = 8
);
    logic clk, rst;
    logic [WIDTH-1:0] in, out;

    register #(
        .WIDTH(WIDTH)
    ) DUT (
        .en(1'b1),
        .*
    );

    // Generate the clock.
    initial begin : generate_clock
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    // Drive the inputs.
    initial begin : drive_inputs
        $timeformat(-9, 0, " ns");

        rst <= 1'b1;
        in  <= 1;  // Purposely set to 1 here to expose assertion error.;
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;

        // Perform the tests.
        for (int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom;
            @(posedge clk);
        end

        disable generate_clock;
        $display("Tests completed.");
    end

    // This is how we verified the earlier FF example, but there is actually one 
    // minor problem with this. This assertion will fail if in is not equal to 0 
    // during reset. This problem occurs because $past tracks the previous inputs
    // during reset. So in the cycle after reset (when the assertion is no longer
    // disabled), out will be 0, but in will be whatever its previous value was.
    assert property (@(posedge clk) disable iff (rst) out == $past(in, 1))
    else $error("[%0t] actual = %0d, expected = %0d", $realtime, $sampled(out), $past(in, 1));

    // Verify reset.
    assert property (@(posedge clk) rst |=> out == '0);
endmodule


// Module: reigster_no_en_tb1
// Description: This module demonstrates several ways of adjusting the earlier 
// assertion to prevent the failure.

module register_no_en_tb1 #(
    parameter int NUM_TESTS = 10000,
    parameter WIDTH = 8
);
    logic clk, rst;
    logic [WIDTH-1:0] in, out;

    register #(
        .WIDTH(WIDTH)
    ) DUT (
        .en(1'b1),
        .*
    );

    // Generate the clock.
    initial begin : generate_clock
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    // Drive the inputs.
    initial begin : drive_inputs
        $timeformat(-9, 0, " ns");

        rst <= 1'b1;
        in  <= 1;  // Purposely set to 1 here to expose assertion error.
        repeat (5) @(posedge clk);
        @(negedge clk);
        rst <= 1'b0;

        // Perform the tests.
        for (int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom;
            @(posedge clk);
        end

        disable generate_clock;
        $display("Tests completed.");
    end

    // One potential solution is to extend the disable until the condition is valid. 
    // Although overkill in this situation, it can be useful to have custom disables 
    // for assertions that should only be applied in specific situations.
    // Here, we delay the rst by one cycle to avoid the problem we saw.
    logic delayed_rst = 1'b1;
    always_ff @(negedge clk) delayed_rst <= rst;
    assert property (@(posedge clk) disable iff (delayed_rst) out == $past(in, 1));

    // Alternatively, we can use implication to delay the comparison as much as we
    // want. To do this, we need an "antecedent" (i.e. trigger condition) that defines
    // when then "consequent" should be checked. Note that if the antecedent is false, 
    // the entire implication becomes "vacuously true." This basically means than if 
    // the antecedent is false, we don't care about the consequent. In this case, 
    // we want to evaluate the condition every cycle starting 1 cycle after the reset 
    // is cleared. This translates to:
    assert property (@(posedge clk) disable iff (rst) 1 |-> ##1 out == $past(in, 1));

    // or alternatively:
    assert property (@(posedge clk) disable iff (rst) 1 |=> out == $past(in, 1));

    // Normally, you wouldn't have a constantly true trigger condition, but it makes
    // sense in this context because without the trigger condition, we can't have
    // the implication, which gives us the ability to ignore one cycle after reset.

    // Alternatively, you could do the following where we basically integrate the
    // "disable iff rst" into the antecedent, which effectively acts as a disable.
    assert property (@(posedge clk) !rst |=> out == $past(in, 1));

    // Verify reset.
    assert property (@(posedge clk) rst |=> out == '0);
endmodule


// Module: reigster_no_en_tb2
// Description: This module demonstrates some unexpected issues with disabling
// the assertion when the disable condition changes on the same clock edge that
// samples the assertion's variables.

module register_no_en_tb2 #(
    parameter int NUM_TESTS = 10000,
    parameter WIDTH = 8
);
    logic clk, rst;
    logic [WIDTH-1:0] in, out;

    register #(
        .WIDTH(WIDTH)
    ) DUT (
        .en(1'b1),
        .*
    );

    // Generate the clock.
    initial begin : generate_clock
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    // Drive the inputs.
    initial begin : drive_inputs
        $timeformat(-9, 0, " ns");

        rst <= 1'b1;
        in  <= 1;  // Purposely set to 1 here to expose assertion error.        
        repeat (5) @(posedge clk);

        // Here we clear reset on the rising edge of the clock to demonstrate
        // a weird behavior with the disable construct.
        //@(negedge clk);
        rst <= 1'b0;

        // Perform the tests.
        for (int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom;
            @(posedge clk);
        end

        disable generate_clock;
        $display("Tests completed.");
    end

    // Here we have similar assertions as the previous module, but to get them not to fail,
    // we need to wait for 2 cycles after reset. After looking over the simulation, the disable
    // is functioning differently than expected.
    //
    // Each assertion samples values on the rising clock edge. In the code above,
    // the reset is cleared *after* a rising clock edge. However, on the edge where the reset
    // is cleared, these assertions are still being evaluated. This suggests that the disable
    // is evaluating a version of the rst signal that is updated after the edge where the
    // values are sampled.
    //
    // Looking over the 1800-2017 LRM, page 423 says: "The values of variables 
    // used in the disable condition are those in the current simulation cycle, 
    // i.e., not sampled." Also, "If the disable condition is true at anytime 
    // between the start of the attempt in the Observed region, inclusive, and 
    // the end of the evaluation attempt, inclusive, then the overall evaluation of
    // the property results in disabled." The combination of these two statements
    // is exactly what we are seeing. The reset is being cleared before the end
    // of the assertion, which causes it to be enabled, even though reset was
    // asserted at the beginning of the assertion.
    //
    // There are several ways to fix this: 1) wait two cycles instead of one before applying 
    // the consequent, 2) make sure to clear the disable condition at a time that does not
    // coincide with a clock edge, or 3) use the $sampled function for the reset    
    // this edge case isn't evaluated. In the previous example, we did 2 because we were 
    // clearing reset on a falling clock edge. Here, we will try 1 and 3.
    //
    // Both of the following wait two cycles after the reset to enable the assertion.
    logic [1:0] delayed_rst = '1;
    always_ff @(posedge clk) delayed_rst <= {delayed_rst[0], rst};
    assert property (@(posedge clk) disable iff (delayed_rst[1]) out == $past(in, 1));    
    assert property (@(posedge clk) disable iff (rst) 1 |-> ##2 out == $past(in, 1));

    // Still wait 1 cycle, but use the sampled version of reset for the disable.
    // This is dangerous because if rst is sampled in any region where it is disabled, the whole thing is true
    assert property (@(posedge clk) disable iff ($sampled(rst)) 1 |-> ##1 out == $past(in, 1));

    // Interestingly, this assertion still works with just a 1-cycle delay because
    // reset is outside the disable region, and is therefore sampled on the
    // clock edge.
    assert property (@(posedge clk) !rst |=> out == $past(in, 1));

    // Verify reset.
    assert property (@(posedge clk) rst |=> out == '0);
endmodule


// Module: register_en_tb
// Description: This testbench extends the previous one with an enable. 

module register_en_tb #(
    parameter int NUM_TESTS = 10000,
    parameter WIDTH = 8
);
    logic clk, rst, en;
    logic [WIDTH-1:0] in, out;

    register #(.WIDTH(WIDTH)) DUT (.*);

    // Generate the clock.
    initial begin : generate_clock
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    // Drive the inputs.
    initial begin : drive_inputs
        $timeformat(-9, 0, " ns");

        rst <= 1'b1;
        in  <= 1;
        en  <= 1'b0;
        repeat (5) @(posedge clk);
        rst <= 1'b0;

        // Perform the tests.
        for (int i = 0; i < NUM_TESTS; i++) begin
            in <= $urandom;
            en <= $urandom;
            @(posedge clk);
        end

        disable generate_clock;
        $display("Tests completed.");
    end

    // Notice how simple this testbench is compared to the example in the basic section 
    // of the tutorial. Three lines of code capture the entire behavior of a register.
    assert property (@(posedge clk) !rst && en |=> out == $past(in, 1));
    assert property (@(posedge clk) disable iff (rst) !en |=> $stable(out));
    assert property (@(posedge clk) rst |=> out == '0);

/*----------------------------- ASSERTIONS -----------------------------*/
