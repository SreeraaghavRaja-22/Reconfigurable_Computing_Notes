module full_adder #(
)(
    input logic x, 
    input logic y, 
    input logic cin, 
    input logic s, 
    input logic cout
);

    assign {cout, s} = x + y + cin; 
endmodule 