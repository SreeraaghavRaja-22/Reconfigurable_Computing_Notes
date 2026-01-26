
// Implementation of architectures from architectures.pdf

module arch1 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    always_ff @(posedge clk) begin 
        out1 <= in1 + in2; 
        out2 <= in3;

        if(rst) begin 
            out1 <= '0; 
            out2 <= '0;
        end 
    end

endmodule


module arch2 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r;

    always_ff @(posedge clk) begin 
        in1_r <= in1;
        in2_r <= in2;
        out1 <= in1_r + in2_r; 
        out2 <= in3
        

        if(rst) begin 
            in1_r <= '0;
            in2_r <= '0;
            out1 <= '0; 
            out2 <= '0;
        end 
    end

endmodule

module arch3 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r, add_out1_r, add_out2_r;

    always_ff @(posedge clk) begin 
        in1_r <= in1;
        in2_r <= in2; 
        in3_r <= in3; 
        add_out1_r <= in1_r + in2_r; 
        add_out2_r <= add_out1_r; 
        

        if(rst) begin 
            in1_r <= '0;
            in2_r <= '0;
            in3_r <= '0;
            add_out1_r <= '0;
            add_out2_r <= '0;
            // out1 <= '0; 
            // out2 <= '0; notice that we don't need to reset these anymore
        end 
    end

    assign out1 = add_out1_r; 
    assign out2 = add_out2_r + in3_r; 

endmodule

module arch4_warnings #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r, add_out;


    always_ff @(posedge clk) begin // change always_ff to always block

        // logic [WIDTH-1:0] add_out -- adding this here is the safe way of doing a blocking operation on a rising clock edge
        add_out = in1_r + in2_r; // this is a blocking assignment (comb logic) in an always_ff block (synthesis tool should report warnings)
        {out1, out2} <= add_out * in3_r; 
        in1_r <= in1;
        in2_r <= in2; 
        in3_r <= in3; 
        

        if(rst) begin 
            out1 <= '0;
            out2 <= '0; 
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0; 
        end 
    end

endmodule

module arch4_warnings #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r, add_out;


    always_ff @(posedge clk) begin 
        {out1, out2} <= add_out * in3_r; 
        in1_r <= in1;
        in2_r <= in2; 
        in3_r <= in3; 
        

        if(rst) begin 
            out1 <= '0;
            out2 <= '0; 
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0; 
        end 
    end

    assign add_out = in1_r + in2_r; 

endmodule


module arch5 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r;

    always_ff @(posedge clk) begin

        add_out = in1_r + in2_r; 
        out2 <= add_out * in3_r; 
        in1_r <= in1; 
        in2_r <= in2; 
        in3_r <= in3; 

        if(rst) begin 
            //out1 <= '0;
            out2 <= '0; 
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0; 
        end 
    end

    assign out1 = add_out; // really dangerous because there will be a race condition (if that's not a problem then it's okay)
endmodule

module arch5_2 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r;
    logic [WIDTH-1:0] add_out; 

    always_ff @(posedge clk) begin

        // add_out = in1_r + in2_r; risk
        out1 <= add_out; 
        out2 <= add_out * in3_r; 
        in1_r <= in1; 
        in2_r <= in2; 
        in3_r <= in3; 

        if(rst) begin 
            //out1 <= '0;
            out2 <= '0; 
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0; 
        end 
    end

    // the risk with the blocking assignment here is that add_out is declared outside the always block, so it could be used somewhere else and could be a blocking assignment

    // Solution 
    assign add_out = in1_r + in2_r; 
endmodule

module arch5_3 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r;
    

    always_ff @(posedge clk) begin
        logic [WIDTH-1:0] add_out; // another solution because the scope of add_out is limited to always block
        // super safe if done this way

        // add_out = in1_r + in2_r; risk
        out1 <= add_out; 
        out2 <= add_out * in3_r; 
        in1_r <= in1; 
        in2_r <= in2; 
        in3_r <= in3; 

        if(rst) begin 
            //out1 <= '0;
            out2 <= '0; 
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0; 
        end 
    end
endmodule

module arch6_bad #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r; 

    always_ff @(posedge clk) begin
        out1 = in1_r + in2_r;
        out2 <= out1 * in3_r; 
        in1_r <= in1; 
        in2_r <= in2; 
        in3_r <= in3; 


        if(rst) begin
            /// out1 <= '0; 
            out2 <= '0;
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0;
        end
    end 

endmodule

module arch6 #(
    parameter int WIDTH = 8;
)(
    input logic clk, 
    input logic rst, 
    input logic [WIDTH-1:0] in1, 
    input logic [WIDTH-1:0] in2, 
    input logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out1, 
    output logic [WIDTH-1:0] out2
);

    logic [WIDTH-1:0] in1_r, in2_r, in3_r; 
    logic [WIDTH-1:0] add_out;

    always_ff @(posedge clk) begin
        
        out2 <= add_out * in3_r; 
        in1_r <= in1; 
        in2_r <= in2; 
        in3_r <= in3; 


        if(rst) begin
            /// out1 <= '0; 
            out2 <= '0;
            in1_r <= '0;
            in2_r <= '0; 
            in3_r <= '0;
        end
    end 

    assign add_out = in1_r + in2_r; 
    assign out1 = add_out;

endmodule