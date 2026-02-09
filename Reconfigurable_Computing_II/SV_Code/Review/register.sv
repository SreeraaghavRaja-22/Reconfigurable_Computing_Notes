module register_async_rst 
#(
    parameter int WIDTH;
)
(
    input logic clk,
    input logic rst, 
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0]
);


    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin 
            out <= '0; // (others => '0')
        end else begin 
            // RISING EDGE

            // SYNTHESIS RULE: Any non-blocking assignment to a signal on a rising clock edge will be synthesized as a register. 
            out <= in;
        end 
    end
endmodule 


module register_async_rst2 #(
    parameter int WIDTH;
)(
    input logic     clk, 
    input logic     rst, 
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0] out
);

    always_ff @(posedge clk or posedge rst) begin 
        out <= in; 
        if(rst) out <= '0;
    end 
endmodule

module register_sync_rst
#(
    parameter int WIDTH;
)
(
    input logic clk,
    input logic rst, 
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0]
);


    always_ff @(posedge clk) begin 
        if(rst) begin 
            out <= '0; // (others => '0')
        end else begin 
            // RISING EDGE

            // SYNTHESIS RULE: Any non-blocking assignment to a signal on a rising clock edge will be synthesized as a register. 

            // IMPORTANT: Make sure to use a NON-BLOCKING ASSIGNMENT
            out <= in;
        end 
    end
endmodule

module register_sync_rst2 #(
    parameter int WIDTH;
)(
    input logic     clk, 
    input logic     rst, 
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0] out
);

    always_ff @(posedge clk)begin 
        out <= in; 
        if(rst) out <= '0;
    end 
endmodule

module register_async_rst_en
#(
    parameter int WIDTH;
)
(
    input logic clk,
    input logic rst, 
    input logic en,
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0]
);


    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin 
            out <= '0; // (others => '0')
        end else if(en) begin
            out <= in; 
        end 
    end
endmodule

module register_async_rst_en2
#(
    parameter int WIDTH;
)
(
    input logic clk,
    input logic rst, 
    input logic en,
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0]
);


    always_ff @(posedge clk or posedge rst) begin 
        if(en) out <= in; 

        // END OF BLOCK RESET still works with additional register functionality
        if(rst) out <= '0;
    end
endmodule 

module register_sync_rst_en
#(
    parameter int WIDTH;
)
(
    input logic clk,
    input logic rst, 
    input logic en,
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0]
);


    always_ff @(posedge clk) begin 
        if(rst) begin 
            out <= '0; // (others => '0')
        end else if(en) begin 
            // RISING EDGE

            // SYNTHESIS RULE: Any non-blocking assignment to a signal on a rising clock edge will be synthesized as a register. 

            // IMPORTANT: Make sure to use a NON-BLOCKING ASSIGNMENT
            out <= in;
        end 
    end
endmodule


module register_sync_rst2 #(
    parameter int WIDTH;
)(
    input logic     clk, 
    input logic     rst, 
    input logic     en,
    input logic [WIDTH-1:0] in, 
    output logic [WIDTH-1:0] out
);

    always_ff @(posedge clk)begin 
        if(en) out <= in; 
        if(rst) out <= '0;
    end 
endmodule