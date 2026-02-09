module adder_4bit #(
    parameter int WIDTH = 8;
)(
    input logic [WIDTH-1:0] x, 
    input logic {WIDTH-1:0] y, 
    input logic             cin, 
    output logic [WIDTH-1:0] sum, 
    output logic             cout
);

    // need an extra bit size for the circuit 
    // look for opportunities to exploit a pattern and use a for-generate to display that pattern
    logic [WIDTH:0] carry;

    generate 
        for(genvar i = 0; i < WIDTH; i++) begin : l_ripple_carry
            full_adder FA(
                .x(x[i]),
                .y(y[i]) 
                .cin(carry[i]),
                .s(sum[i]),
                .cout(carry[i + 1])
            )
        end 
    endgenerate

    assign carry[0] = cin; 
    assign cout = carry[WIDTH];

endmodule