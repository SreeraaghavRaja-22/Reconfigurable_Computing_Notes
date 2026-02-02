module bit_diff_fsmd_1p #(
    parameter int WIDTH
)(
    input logic clk,
    input logic rst,
    input logic go, 
    input logic [WIDTH-1:0] data,

    // the range of results can be from WIDTH to -WIDTH, which is 2*WIDTH + 1 possible values
    // the +1 includes 0
    output logic signed [$clog2(2*WIDTH+1)-1:0] result, 
    output logic                                done
);

    typedef enum [1:0]{
        START, 
        COMPUTE,
        RESTART,
        XXX = 'x
    } state_t;

    state_t state_r; 

    logic [$bits(data)-1:0]             data_r; 
    logic [$bits(result)-1:0]           result_r; 
    logic [$clog2(WIDTH)-1:0]           count_r;
    logic signed [$bits(result)-1:0]    diff_r; 
    logic                               done;
    
    assign result = result_r; 
    assign done   = done_r;


    always_ff @(posedge clk) begin 
        case(state_r) 
            START : begin 
                count_r <= '0; 
                diff_r  <= '0;
                done_r  <= 1'b0; 
                data_r  <= data; 

                if(go) begin
                    // data_r <= data; -- this is worse for timing optimization since data_r will now be a function of go and we don't want that as it will increase the number of LUTs (bottleneck)
                    state_r <= COMPUTE; 
                end
            end

            COMPUTE : begin 
                data_r <= data_r[0] ? diff_r + 1'b1 : diff_r - 1'b1;
                // count_r++ -- count_r = count_r + 1 which is a BLOCKING ASSIGNMENT WHICH IS BAD HERE
                // is there no overloaded non-blocking version of the postfix increment operator because nonblocking assignments are a newer construct compared to blocking assignments in SV?
                count_r <= count_r + 1'b1; 
                data_r <= data_r >> 1; 

                // count_r is always one iteration ahead when at this check, so we have to decrement WIDTH by 1 to get the correct number of cycles
                if (count_r == WIDTH - 1) begin 
                    state_r <= RESTART;
                end
            end

            RESTART : begin 
                result_r <= diff_r; 
                count_r  <= '0; 
                data_r   <= data; 
                done_r   <= 1'b1; 
            
                if(go) state_r <= COMPUTE;
            end
        endcase
    end

    if(rst) begin 
        state_r     <= START; 
        done_r      <= 1'b0; 
        result_r    <= '0; 
        diff_r      <= '0; 
        data_r      <= '0;
    end
endmodule