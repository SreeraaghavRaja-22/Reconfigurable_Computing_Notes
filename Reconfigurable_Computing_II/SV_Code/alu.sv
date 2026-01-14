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

module alu1 #(
    parameter int WIDTH
)(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    input logic [      1:0] sel, 
    output logic            neg, 
    output logic            pos, 
    output logic            zero, 
    output logic [WIDTH-1:0] out
);
    always_comb begin 
        case (sel)
            // Addition
            2'b00: out = in0 + in1; 
            // Subtraction 
            2'b01: out = in0 - in1; 
            // AND 
            2'b10: out = in0 & in1; 
            // OR
            2'b11: out = in0 | in1; 
        endcase

        // By moving the status flags outside the case statements, we guarantee all the flags are define on all paths 
        // NO LATCHES
        if(out == '0) begin // could also do out == 0 but that would lead to automatic truncation
            pos = 1'b0; 
            neg = 1'b0; 
            zero = 1'b1; 
        end else if(out[WIDTH-1] == 1'b0) begin 
            pos = 1'b1;
            neg = 1'b0;
            zero = 1'b0;
        end else begin 
            pos = 1'b0; 
            neg = 1'b1; 
            zero = 1'b0; 
        end 
    end
endmodule   


module alu2 #(
    parameter int WIDTH
)(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    input logic [      1:0] sel, 
    output logic            neg, 
    output logic            pos, 
    output logic            zero, 
    output logic [WIDTH-1:0] out
);
    always_comb begin 
        // default values 
        pos = 1'b0; 
        neg = 1'b0; 
        zero = 1'b0; 

        case (sel)
            // Addition
            2'b00: out = in0 + in1; 
            // Subtraction 
            2'b01: out = in0 - in1; 
            // AND 
            2'b10: out = in0 & in1; 
            // OR
            2'b11: out = in0 | in1; 
        endcase    

        if (out == '0) begin 
            zero = 1'b1; 
        end else if (out[WIDTH-1:0] == 1'b0) begin 
            pos = 1'b1; 
        end else begin 
            neg = 1'b1; 
        end
    end
endmodule 

module alu3 #(
    parameter int WIDTH
)(
    input logic [WIDTH-1:0] in0, 
    input logic [WIDTH-1:0] in1, 
    input logic [      1:0] sel, 
    output logic            neg, 
    output logic            pos, 
    output logic            zero, 
    output logic [WIDTH-1:0] out
);

    // Define meaningful constant names w/ hardcoded values 
    localparam logic [1:0] ADD_SEL = 2'b00;
    localparam logic [1:0] SUB_SEL = 2'b01; 
    localparam logic [1:0] AND_SEL = 2'b10; 
    localparam logic [1:0] OR_SEL  = 2'b11;

    // operations with repeated code can be simplified with functions or tasks
    task update_flags();
        pos = 1'b0; 
        neg = 1'b0; 
        zero = 1'b0; 
        if(out == '0) zero = 1'b1; 
        else if(out[WIDTH-1] == 1'b0) pos = 1'b1; 
        else neg = 1'b1; 
    endtask

    always_comb begin
        neg = 1'bx;
        pos = 1'bx; 
        zero = 1'bx; 

        case(sel)
            ADD_SEL: out = in0 + in1; 
            SUB_SEL: out = in0 - in1; 
            AND_SEL: out = in0 & in1; 
            OR_SEL : out = in0 | in1; 
        endcase

        // would this work since I'm basically doing the same update but at the end?
        update_flags();
    end

endmodule