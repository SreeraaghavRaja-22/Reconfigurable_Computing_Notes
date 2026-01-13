module add #(
    parameter int WIDTH = 8;
)
(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    output logic [WIDTH-1:0] sum
);

    assign sum = in0 + in1; 

endmodule 


module add_carry_out_bad #(
    parameter int WIDTH = 16;
)
(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    output logic [WIDTH-1:0] sum,
    output logic carry_out
);

    logic [WIDTH:0] full_sum; 

    // using non-blocking operators, concatenating in0 and in1 with 0 at start (to match width of full_sum), 
    // and assigning result and carry out at the end with non-blocking operator
    // Non-blocking assignments only update the value at the end of a timestamp
    // end of assignment == end of always block
    always_comb begin 
        full_sum <= {1'b0, in0} + {1'b0, in1};
        sum <= full_sum[WIDTH-1:0];
        carry_out <= full_sum[WIDTH];
    end

endmodule 

module add_carry_out_1 #(
    parameter int WIDTH = 16;
)
(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    output logic [WIDTH-1:0] sum,
    output logic carry_out
);

    logic [WIDTH:0] full_sum; 

    // blocking assignments update immediately
    always_comb begin 
        full_sum = {1'b0, in0} + {1'b0, in1};
        sum = full_sum[WIDTH-1:0];
        carry_out = full_sum[WIDTH];
    end

endmodule 

module add_carry_out_2 #(
    parameter int WIDTH = 16;
)
(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    output logic [WIDTH-1:0] sum,
    output logic carry_out
);

    // kinda like the concatenation of the left size
    // SV will look at the max size of the operation on the right side
    assign {carry, sum} = in0 + in1; 

endmodule 

module add_carry_out_inout #(
    parameter int WIDTH = 16;
)
(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    input logic carry_in,
    output logic [WIDTH-1:0] sum,
    output logic carry_out
);

assign {carry_out, sum} = in0 + in1 + carry_in; 

endmodule 

module add_carry_out_inout_overflow #(
    parameter int WIDTH = 16;
)
(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    input logic carry_in,
    output logic [WIDTH-1:0] sum,
    output logic carry_out
);

assign {carry_out, sum} = in0 + in1 + carry_in; 

// overflow is avoided if carry bit is preserved
assign overflow = (in0[WIDTH-1] == in1[WIDTH-1]) && (carry_out != in0[WIDTH-1]);

endmodule 