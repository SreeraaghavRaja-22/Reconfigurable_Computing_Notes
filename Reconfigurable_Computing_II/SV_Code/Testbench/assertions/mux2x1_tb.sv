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

    localparam int PERIOD = 10;
    localparam time TIME_PERIOD = 10ns;

    // Monolithic Testbench (doing everything in one place)
    // Coverage: how much we're testing on a TB
    // Simple Module: exhaustive testbench that covers everything

    // always begin
    //     forever #5 clk <= !clk;
    // end 

    // will make it easier to stop
    initial begin : generate_clk
        forever #5 clk <= !clk;
    end
    
    initial begin
        $timeformat(-9, 0, "ns", 0);

        for(int i = 0; i < 8; i++) begin 
            /*
                BIG TB RULE: Always drive the DUT with non-blocking assignments!!!!
            */



            in0 <= i[0]; // could change all of these to blocking assignments but this is super duper dangerous
            in1 <= i[1]; 
            sel <= i[2]; 

            // #10; 
            // #PERIOD; 
            //#TIME_PERIOD
        //     @(posedge clk)

        //     //expected_out = sel ? in1 : in0;
        //     expected_out = i[2] ? i[1] : i[0];

        //     // if (out != expected_out) begin 
        //     //     $display("ERROR: [%0t] out = %b instead of %b", $time, out, expected_out);
        //     //     $error("out = %b instead of %b", out, expected_out);
        //     // end
        //     assert (out !== expected_out) else $error("out = %b instead of %b", out, expected_out);
        // end
        end
        $display("Tests completed");
            // turn off the generate clk process
        disable generate_clk;
    end

    initial begin : verify_output
        forever begin 
            @(posedge clk)
            expected_out = sel ? in1 : in0; 
            assert(out == expected_out) else $error("out = %b instead of %b", out, expected_out);
        end
    end 

endmodule
    