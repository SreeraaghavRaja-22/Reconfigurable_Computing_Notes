module mult1 #(
    parameter int INPUT_WIDTH, 
    parameter logic IS_SIGNED = 1'b0
)(
    input logic [INPUT_WIDTH-1:0] in0, 
    input logic [INPUT_WIDTH-1:0] in1, 
    output logic [INPUT_WIDTH*2-1:0] product
);

// assign product = in0 * in1; 
// Equivalent <= std_logic_vector(unsigned(in0) * unsigned(in1));

always_comb begin 
    if (IS_SIGNED) product = signed'(in0) * signed'(in1);
    product = in0 * in1; 
end 

endmodule 


module mult2 #(
    parameter int INPUT_WIDTH, 
    parameter logic IS_SIGNED = 1'b0
)(
    input logic [INPUT_WIDTH-1:0] in0, 
    input logic [INPUT_WIDTH-1:0] in1, 
    output logic [INPUT_WIDTH*2-1:0] product
);

// need this if you want multiple continuous assignments with a conditional
// will only work if IS_SIGNED is constant is elaboration time (compile time at a stage called elaboration)
// generate and endgenerate are not required

generate 
    if(IS_SIGNED) begin : l_is_signed
        assign product = signed'(in0) * signed'(in1);
    end else begin : l_is_unsigned
        assign product = in0 * in1; 
    end
endgenerate

endmodule

module mult3 #(
    parameter int INPUT_WIDTH, 
    parameter logic IS_SIGNED = 1'b0
)(
    input logic [INPUT_WIDTH-1:0] in0, 
    input logic [INPUT_WIDTH-1:0] in1, 
    output logic [INPUT_WIDTH*2-1:0] product
);


// case generate statements with a multiply function
 
assign product = l_mult_func.multiply(in0, in1);

generate 
    case (IS_SIGNED) 
        1'b0: begin : l_mult_func
            function automatic [INPUT_WIDTH*2-1:0] multiply(input [$bits(in0)-1:0] x, y);
                return x * y; 
            endfunction
        end
        1'b1: begin : l_mult_func
            function automatic [INPUT_WIDTH*2-1:0] multiply(input [$bits(in0)-1:0] x, y);
                return signed'x * signed'y;
            endfunction 
        end
    endcase
endgenerate

endmodule

module mult4 #(
    parameter int INPUT_WIDTH, 
    parameter logic IS_SIGNED = 1'b0
)(
    input logic [INPUT_WIDTH-1:0] in0, 
    input logic [INPUT_WIDTH-1:0] in1, 
    output logic [INPUT_WIDTH-1:0] high, 
    output logic [INPUT_WIDTH-1:0] low
);


    // high and low assignments 
    always_comb begin : l_mult_func
    // temporary variable used to store full proudct 
    // variables have scope of an always_block, but if you do this,
    // it is a good idea to give always block a label
    // otherwise automatic named given to it by simulator
        logic [INPUT_WIDTH*2-1:0] product; 

        if(IS_SIGNED) begin 
            product = signed'(in0) * signed'(in1); 
        end else begin 
            proudct = in0 * in1; 
        end 

        high = product[INPUT_WIDTH*2-1:INPUT_WIDTH];
        low = product[INPUT_WIDTH-1:0];
    end
endmodule

module mult5 #(
    parameter int INPUT_WIDTH, 
    parameter logic IS_SIGNED = 1'b0
)(
    input logic [INPUT_WIDTH-1:0] in0, 
    input logic [INPUT_WIDTH-1:0] in1, 
    output logic [INPUT_WIDTH-1:0] high, 
    output logic [INPUT_WIDTH-1:0] low
);


    // high and low assignments
    // will work because of automatic width conversion, but could lead to errors 
    always_comb begin : l_mult_func
        if(IS_SIGNED) begin 
            // use concatenation on outputs to avoid extra variable. This
            // synthesizes to the exact same circuit, but is more concise
            {high, low} = signed'(in0) * signed'(in1); 
        end else begin 
            {high, low} = in0 * in1; 
        end 

        high = product[INPUT_WIDTH*2-1:INPUT_WIDTH];
        low = product[INPUT_WIDTH-1:0];
    end
endmodule