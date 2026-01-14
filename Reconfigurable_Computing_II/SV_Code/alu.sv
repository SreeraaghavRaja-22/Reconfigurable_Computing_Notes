// ALU PRACTICE

// Module: alu_bad

module alu_bad #(
    parameter int WIDTH
)(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    input logic [1:0]       sel, 
    output logic            neg, 
    output logic            pos, 
    output logic            zero, 
    output logic [WIDTH-1:0] out
);

    always_comb begin 
        case(sel) 
            2'b00: begin 

                // ASSIGN THE OUTPUT 
                out = in0 + in1;

                // Update status flags 

                if(out == '0) begin 
                    pos = 1'b0; 
                    neg = 1'b0; 
                    zero = 1'b1; 
                end else if (out[WIDTH-1] == 1'b0) begin
                    pos = 1'b1; 
                    neg = 1'b0; 
                    zero = 1'b0; 
                end else begin
                    pos = 1'b0;
                    neg = 1'b1; 
                    zero = 1'b0; 
                end 
            end
            2'b01: begin 

                // ASSIGN THE OUTPUT 
                out = in0 - in1;

                // Update status flags 

                if(out == '0) begin 
                    pos = 1'b0; 
                    neg = 1'b0; 
                    zero = 1'b1; 
                end else if (out[WIDTH-1] == 1'b0) begin
                    pos = 1'b1; 
                    neg = 1'b0; 
                    zero = 1'b0; 
                end else begin
                    pos = 1'b0;
                    neg = 1'b1; 
                    zero = 1'b0; 
                end 
            end

            // since I don't assign the status flags in all possible cases, it will not synthesize to combinational logic
            // "inferred latches"
            // "all outputs must be defined on all paths through the process"
            // "or else the FPGA infers latches on outputs (bad since FPGAs aren't defined to support this)"
            2'b10: begin 
                out = in0 & in1; 
            end 

            2'b11: begin 
                out = in0 | in1; 
            end 
        endcase
    end
endmodule 