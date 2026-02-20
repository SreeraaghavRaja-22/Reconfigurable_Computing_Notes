`timescale 1ns / 10 ps

module ff_no_en_tb #(
    parameter int NUM_TESTS = 10000; 
);

    logic clk = 1'b0, rst, en, in, out; 

    ff DUT(
        .en(1'b1), 
        .*
    );

    initial begin : generate_clk
        forever #5 clk = ~clk; 
    end 

    initial begin : stimulus
        $timeformat(-9, 0, " ns");
        rst <= 1'b1; 
        in <= 1'b1; // this will cause first impliation assertion statement to fail can set to 1'b0 if you want it to be true;

        repeat(5) @(posedge clk);
        @(negedge clk); 
        rst <= 1'b0; 

        for (int i = 0; i < NUM_TESTS; i++) begin 
            in <= $urandom; 
            @(posedge clk);
        end

        disable generate_clk; 
        $display("Test Completed.");
    end 
    
    // a ##2 b ##2 c ##5 !d

    // concurrent assertion = assert property
    // assert property (@(posedge clk) in ##1 out); // will give errors but this is a sequence by itself (assumes in is asserted every cycle)
    // assert property (@(posedge clk) in |-> ##1 out); // |-> implication operator, input = true => output is vacuously true LOL

    assert property (@(posedge clk) disable iff (rst) in |-> ##1 out); // this condition only applies when reset is cleared -- can use sequences to define properties of you circuits
    assert property (@(posedge clk) disable iff (rst) in |=> out); // same thing as the statement above

    // sync reset // can still use this for async reset but can't tell if rst is cleared before the next rising edge
    assert property (@(posedge clk) rst |=> !out);

    // async reset
    always @(posedge rst) begin 
        #1; 
        assert (out == 1'b0)
    end 
endmodule

module ff_en_tb #(
    parameter int NUM_TESTS = 10000; 
);

    logic clk = 1'b0, rst, en, in, out; 

    ff DUT(.*);

    initial begin : generate_clk
        forever #5 clk = ~clk; 
    end 

    initial begin : stimulus
        $timeformat(-9, 0, " ns");

        rst <= 1'b1; 
        in <= 1'b0; 
        en <= 1'b0; 

        repeat(5) @(posedge clk);
        @(negedge clk); 
        rst <= 1'b0; 

        for (int i = 0; i < NUM_TESTS; i++) begin 
            in <= $urandom; 
            @(posedge clk);
        end

        disable generate_clk; 
        $display("Test Completed.");
    end 

    assert property (@(posedge clk) disable iff (rst) en |=> out == $past(in, 1)); // look back 1 cycle and use that value of input

    // assert property (@(posedge clk) disable iff (rst) out == $past(in, 1, en)); // might work

    assert property (@(posedge clk) disable iff (rst) !en |=> out = $past(out, 1));
    assert property (@(posedge clk) disable iff (rst) !en |=> $stable(out)); // equivalent to the statement above
    assert property (@(posedge clk) rst |=> !out);

    always @(posedge rst) #1 assert (out == 1'b0);

endmodule
    