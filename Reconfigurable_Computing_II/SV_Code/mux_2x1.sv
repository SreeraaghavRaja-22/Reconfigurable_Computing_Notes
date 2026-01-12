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

