module mealy_2p(
    input logic clk, 
    input logic rst, 
    input logic go, 
    input logic ack, 
    input logic en, 
    output logic done
);

    typedef enum logic [1:0] {
        START, 
        COMPUTE, 
        RESTART,
        WAIT
    } state_t; 

    state_t state_r, next_state; 

    always @(posedge clk) begin 
        state_r <= next_state; 
        if (rst) state_r <= START; 
    end 

    always_comb begin 
        next_state = state_r; 
        case(state_r) begin 
            START : begin 
                if(go) begin 
                    done = 1'b0; 
                    en = 1'b0;
                end else begin
                    done = 1'b0; 
                    en = 1'b0; 
                end
            end 
        end
        endcase
    end
endmodule