module register #(
    parameter int WIDTH = 8
)(
    input logic clk, 
    input logic rst, 
    input logic en, 
    input logic [WIDTH-1:0] in, 
    otuput logic [WIDTH-1:0] out
);

    always_ff @(posedge clk or posedge rst) begin
        if(rst) out <= '0; 
        else if(clk) begin 
            if (en) out <= in; 
        end
    end


module delay #(
    parameter int CYCLES = 4, 
    parameter int = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic en, 
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0] out
); 

    // convention for unpacked and packed arrays
    // type 2d_array_t is array of (0 to CYCLES-1) is std_logic_vector(WIDTH-1 downto 0);
    // signal my_array : 2d_array_t;
    logic [WIDTH-1:0] regs [CYCLES+1];



    for (genvar i = 0; i < CYCLES; i++) begin : l_regs
        register #(.WIDTH(WIDTH)) reg(
            .clk(clk), 
            .rst(rst), 
            .en(en),
            .in(regs[i]),
            .out(regs[i + 1])
        );
    end

    assign regs[0] = in; 
    assign out = regs[CYCLES+1];
endmodule // register_async_reset
