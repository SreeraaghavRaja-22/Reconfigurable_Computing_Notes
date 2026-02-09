
// Verilog and SV have a unitless time by default so use timescale
// timescale defines the default time unit
`timescale 1ns/100ps

//#10; // wait for 10ns
//#10.1; // wait for 10.1ns


// `timescale 1ns/1ns
// #10; wait for 10 ns 
// #10.1; wait for 10ns 
// #10.6; wait for 11ns (freaky)

module mux2x1_tb    

    logic in0;
    logic in1;
    logic sel;
    logic out;

    mux2x1 DUT(
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    // Monolithic Testbench (doing everything in one place)
    // Coverage: how much we're testing on a TB
    // Simple Module: exhaustive testbench that covers everything
    initial begin
        $timeformat(-9, 0, "ns", 0);

        in0 <= 1'b1; 
        in1 <= 1'b1; 
        sel <= 1'b1; 
        #10; 

        expected_out = sel ? in1 : in0;
        if (out != expected_out) begin 
            $display("ERROR: [%0t] out = %b instead of %b", $time, out, expected_out);
            $error("out = %b instead of %b", out, expected_out);
        end
    end
endmodule