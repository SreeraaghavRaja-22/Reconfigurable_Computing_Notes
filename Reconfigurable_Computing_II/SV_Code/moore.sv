
// State Machines

module moore_1p(
    input logic clk, 
    input logic rst, 
    input logic en, 
    output logic [3:0] out 
);

    // define an enum for each state 
    typedef enum logic [1:0]{
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
endmodule


module moore_1p_2(
    input logic clk, 
    input logic rst, 
    input logic en, 
    output logic [3:0] out 
);

    // define an enum for each state 
    typedef enum logic [1:0]{
        STATE0 = 2'b00, 
        STATE1 = 2'b01, 
        STATE2 = 2'b10, 
        STATE3 = 2'b11
    } state_t;

    // use a custom encoding for FSM
    (*syn_encoding = "gray" *) state_t state_r; // this is a tool specific attribute use (will work in Quartus but not Vivado)
    // (* fsM_encoding = "gray" *) state_t state_r; // will work in vivado and not quartus

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
endmodule

module moore_2p(
    input logic clk, 
    input logic rst, 
    input logic en, 
    output logic [3:0] out 
);

    // define an enum for each state 
    typedef enum logic [1:0]{
        STATE0, 
        STATE1, 
        STATE2, 
        STATE3
    } state_t;

    state_t state_r, next_state;

    always_ff @(posedge clk) begin 

        // q <= d; 
        state_r <= next_state; 

        // sync reset to target sync reset FPGAs
        if (rst) begin 
            state_r <= STATE0;
        end
    end

    always_comb begin 
        // need to preserve the value of the combination logic so we need to explicitly define all paths
        case(state_r)
            STATE0 : begin 
                out = 4'b0001;
                if (en) next_state = STATE1; 
                else next_state = STATE0;
            end 
            STATE1 : begin 
                out = 4'b0010;
                if (en) next_state = STATE2; 
                else next_state = STATE1;
            end 
            STATE2 : begin 
                out = 4'b0100;
                if (en) next_state = STATE3; 
                else next_state = STATE2;
            end 
            STATE3 : begin 
                out = 4'b1000;
                if (en) next_state = STATE0; 
                else next_state = STATE3;
            end 
            default : begin end
        endcase 
    end
endmodule 

module moore_2p_improved(
    input logic clk, 
    input logic rst, 
    input logic en, 
    output logic [3:0] out 
);

    // define an enum for each state 
    typedef enum logic [1:0]{
        STATE0, 
        STATE1, 
        STATE2, 
        STATE3
    } state_t;

    state_t state_r, next_state;

    always_ff @(posedge clk) begin 

        // q <= d; 
        state_r <= next_state; 

        // sync reset to target sync reset FPGAs
        if (rst) begin 
            state_r <= STATE0;
        end
    end

    always_comb begin 
        // need to preserve the value of the combination logic so we need to explicitly define all paths
        next_state = state_r; 

        case(state_r)
            STATE0 : begin 
                out = 4'b0001;
                if (en) next_state = STATE1; 
            end 
            STATE1 : begin 
                out = 4'b0010;
            end 
            STATE2 : begin 
                out = 4'b0100;
                if (en) next_state = STATE3; 
            end 
            STATE3 : begin 
                out = 4'b1000;
                if (en) next_state = STATE0; 
            end 
            default : begin 
                // out = '0; 
                // $fatal(1, "ERROR");
            end
        endcase 
    end
endmodule 


