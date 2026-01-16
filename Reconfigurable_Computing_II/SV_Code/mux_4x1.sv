module mux_4x1(
    input logic [3:0] inputs, 
    input logic [1:0] sel, 
    output logic out
);

    logic [1:0] mux_out; // intermediate signals

    mux_4x1 MUX1(
        .in0(inputs[0]), 
        .in1(inputs[1]),
        .sel(sel[0]),
        .out(mux_out[0])
    );

    mux_4x1 MUX2(
        .in0(inputs[2]), 
        .in1(inputs[3]), 
        .sel(sel[0]),
        .out(mux_out[1])
    );

    mux_4x1 MUX3(
        .in0(mux_out[0]),
        .in1(mux_out[1]),
        .sel(sel[1]), 
        .out(out)
    );
endmodule 