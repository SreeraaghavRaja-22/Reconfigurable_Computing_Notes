
// State Machines

module moore_1p(
    input logic clk, 
    input logic rst, 
    input logic en, 
    output logic [3:0] out 
);

    // define an enum for each state 
    typdef enum logic [1:0]{
        STATE0, 
        STATE1, 
        STATE2, 
        STATE3
    } state_t;

    state_t state_r;

    always_ff @(posedge clk) begin 
        case(state_r)
            STATE0: begin
                out <= 4'b0001; 
                if (en) state_r <= STATE1; 
            end
            STATE1: begin 
                out <= 4'b0010;
                if (en) state_r <= STATE2; 
            end 
            STATE2: begin 
                out <= 4'b0100; 
                if (en) state_r <= STATE3; 
            end
            STATE3: begin 
                out <= 4'b1000; 
                if (en) state_r <= STATE0;
            end
        endcase
    end