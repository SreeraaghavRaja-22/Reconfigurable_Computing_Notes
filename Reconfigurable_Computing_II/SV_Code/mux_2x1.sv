module mux2x1_assign(
    // direction, kind, range, data_type, name
    // only care about direction, data_type, name
    input logic in0, 
    input logic in1, 
    input logic sel, 
    output logic out
);

// continuous assignment / concurrent assignment
assign out = sel ? in1 : in0;
// assign out = sel == 1'b1 ? in1 : in0;
// 1 is 32-bits wide -> leads to automatic truncation

endmodule 


module mux2x1_if(
    input logic in0, 
    input logic in1, 
    input logic sel, 
    output logic out
); 

    always @(*) begin 
        if (sel) begin 
            out = in1; 
        end else begin 
            out = in0;
        end 
    end 

endmodule

module mux2x1_if2(
    input logic in0, 
    input logic in1, 
    input logic sel, 
    output logic out
); 
    // Advice: use blocking aassignments for combinational logic
    // can still work with non-blocking assignments
    // make explicit intent for combinational logic
    always_comb begin 
        if(sel) begin 
            out = in1; 
        end else begin
            out = in0; 
        end 
    end

endmodule 

module mux2x1_case(
    input logic in0, 
    input logic in1, 
    input logic sel, 
    output logic out  
)

    always_comb begin 
        case (sel):
            1'b0 : out = in0; 
            1'b1 : out = in1; 
            // default :
        endcase
    end 

endmodule 

module mux_2x1(
    input logic in0, 
    input logic in1, 
    input logic sel, 
    output logic out
);

    mux2x1_assign(.*);
    // mux2x1_if(.*);
    // mux2x1_if2(.*);
    // mux2x1_case(.*);

endmodule
