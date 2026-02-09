module priority_encoder_4in_if(
    input logic [3:0] in,
    output logic [1:0] result, 
    output logic valid
);

    always_comb begin
        // assign default value for all outputs
        valid = 1'b1; 
        result = 2'b00; 

        if (input[3]) result = 2'b11;
        else if(input[2]) result = 2'b10;
        else if(input[1]) result = 2'b01;
        else if(input[0]) result = 2'b00; 
        else valid = 1'b0;
    end
endmodule

module priority_encoder_case(
    input logic [3:0] in, 
    output logic [1:0] result, 
    output logic valid
)

    always_comb begin 
        valid = 1'b1;

        case (in) 
            4'b0000 : begin 
                        result = 2'b00;
                        valid = 1'b0;
            end
            4'b0001 : result = 2'b00;
            4'b0010 : result = 2'b01;
            4'b0011 : result = 2'b01;
            4'b0100 : result = 2'b10; 
            4'b0101 : result = 2'b10; 
            4'b0110 : result = 2'b10; 
            4'b0111 : result = 2'b10; 
            4'b1000 : result = 2'b11; 
            4'b1001 : result = 2'b11; 
            4'b1010 : result = 2'b11; 
            4'b1011 : result = 2'b11; 
            4'b1100 : result = 2'b11; 
            4'b1101 : result = 2'b11;
            4'b1110 : result = 2'b11; 
            4'b1111 : result = 2'b11;
        endcase
    end
endmodule 

// Both modules will synthesize to the same circuit because the technology mapping is the same 
// Since they have the same number of inputs and outputs, they will use the same number of LUTs / CLBs


module priority_encoder_case2(
    input logic [3:0] in, 
    output logic [1:0] result, 
    output logic valid
)

    always_comb begin 
        valid = 1'b1;

        case (in) 
            4'b0000 : begin 
                        result = 2'b00;
                        valid = 1'b0;
            end
            4'b0001 : result = 2'b00;
            4'b0010, 4'b0011 : result = 2'b01;
            4'b0100, 4'b0101, 4'b0110, 4'b0111 : result = 2'b10; 
            4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111 : result = 2'b11; 
        endcase
    end
endmodule 


module priority_encoder_case_inside(
    input logic [3:0] in, 
    output logic [1:0] result, 
    output logic valid
)
    // use case inside construct to specify ranges
    always_comb begin 
        valid = 1'b1;

        case (in) inside 
            4'b0000 : begin 
                        result = 2';
                        valid = 1'b0;
            end
            4'b0001 : result = 2'b00;
            [4'b0010 : 4'b0011] : result = 2'b01;
            [4'b0100 : 4'b0111] : result = 2'b10; 
            [4'b1000 : 4'b1111] : result = 2'b11; 
        endcase
    end
endmodule 

module priority_encoder_case_dc(
    input logic [3:0] in, 
    output logic [1:0] result, 
    output logic valid
)

    // can use don't cares for SV too with a casez statement
    always_comb begin 
        valid = 1'b1;

        casez (in) 
            4'b1??? : result = 2'b11; 
            4'b01?? : result = 2'b10; 
            4'b001? : result = 2'b01; 
            4'b0001 : result = 2'b00; 
            4'b0000 : begin 
                        result = 2'b00; 
                        valid = 1'b0;
            end
        endcase
    end
endmodule 