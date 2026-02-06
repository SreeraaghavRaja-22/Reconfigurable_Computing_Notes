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
        XXX = 'x // CLIFFORD CUMMINGS PAPER 
    } state_t;

    state_t state_r; 

    logic [$bits(data)-1:0]             data_r; 
    logic [$bits(result)-1:0]           result_r; 
    logic [$clog2(WIDTH)-1:0]           count_r;
    logic signed [$bits(result)-1:0]    diff_r; 
    logic                               done_r;
    
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

            default : begin 
                state_r <= XXX; // make errors and bugs as visible as possible
                //$fatal(1, "Illegal State")
            end 
        endcase

        if(rst) begin 
            state_r     <= START; 
            done_r      <= 1'b0; 
            result_r    <= '0; 
            diff_r      <= '0; 
            data_r      <= '0;
        end
    end

    
endmodule

module bit_diff_fsmd_1p_2 #(
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
        XXX = 'x 
    } state_t;

    state_t state_r; 

    logic [$bits(data)-1:0]             data_r; 
    logic [$bits(result)-1:0]           result_r; 
    logic [$clog2(WIDTH)-1:0]           count_r;
    logic signed [$bits(result)-1:0]    diff_r, next_diff; 
    logic                               done_r;
    
    assign result = result_r; 
    assign done   = done_r;


    always_ff @(posedge clk) begin 
        case(state_r) 
            START : begin 
                count_r <= '0; 
                diff_r  <= '0;
     
                data_r  <= data; 

                if(go) begin
                    // data_r <= data; -- this is worse for timing optimization since data_r will now be a function of go and we don't want that as it will increase the number of LUTs (bottleneck)
                    state_r <= COMPUTE; 
                    done_r  <= 1'b0; 
                end
            end

            COMPUTE : begin 
                // logic signed [$bits(result)-1:0]    next_diff // read next diff in the 
                // next_diff = data_r[0] ? diff_r + 1'b1 : diff_r - 1'b1;
                data_r <= data_r >> 1; 
                diff_r <= next_diff;

                // count_r is always one iteration ahead when at this check, so we have to decrement WIDTH by 1 to get the correct number of cycles
                if (count_r == WIDTH - 1) begin 
                    state_r <= START;
                    done_r <= 1'b1; 
                    result_r <= diff_r; // incorrect because we get previous value of diff_r
                end
            end

            default : begin 
                state_r <= XXX; // make errors and bugs as visible as possible
                //$fatal(1, "Illegal State")
            end 
        endcase

        if(rst) begin 
            state_r     <= START; 
            done_r      <= 1'b0; 
            result_r    <= '0; 
            diff_r      <= '0; 
            data_r      <= '0;
        end
    end

    assign next_diff = data_r[0] ? diff_r + 1'b1 : diff_r - 1'b1;
 

endmodule


module bit_diff_fsmd_2p#(
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
        XXX = 'x 
    } state_t;

    state_t state_r, next_state; 

    logic [$bits(data)-1:0]             data_r, next_data;
    logic [$bits(result)-1:0]           result_r, next_result;
    logic [$clog2(WIDTH)-1:0]           count_r, next_cout;
    logic signed [$bits(result)-1:0]    diff_r, next_diff; 
    logic                               done_r, next_done; 

    assign result = result_r;
    assign done = done_r;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin 
            result_r <= '0;
            done_r <= 1'b0;
            diff_r <= '0;
            count_r <= '0; 
            data_r <= '0; 
            state_r <= START; 
        end else begin 
            result_r <= next_result; 
            done_r <= next_done; 
            diff_r <= next_diff; 
            data_r <= next_data; 
            state_r <= next_state; 
        end
    end

    always_comb begin
        next_result = result_r; 
        next_done = done_r; 
        next_diff = diff_r; 
        next_data = data_r; 
        next_count = count_r;
        next_state = state_r;

        case (state_r) 
            START: begin 
                next_done = 1'b0; 
                next_result = '0;
                next_diff = '0; 
                next_data = data; 
                next_count = '0; 

                if(go) next_state = COMPUTE;
            end

            COMPUTE: begin 
                next_diff = data_r[0] ? diff_r + 1 : diff_r - 1; 
                next_data = data_r >> 1; 
                next_count = count_r + 1'b1; 
                // don't use next count because it increases the length of path to adder and comparator
                if (count_r == WIDTH - 1) begin 
                    next_state = RESTART; 
                    next_result = next_diff; 
                    next_done = 1'b1; 
                end
            end

            RESTART : begin 
                next_diff = '0; 
                next_count = '0; 
                next_data = data; 

                if(go) begin 
                    next_done = 1'b0; 
                    next_diff = '0; 
                    next_count = '0;
                end
            end
    
        endcase
    end
endmodule

// remove done from everything; 
module bit_diff_fsmd_2p_2 #(
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
        XXX = 'x 
    } state_t;

    state_t state_r, next_state; 

    logic [$bits(data)-1:0]             data_r, next_data;
    logic [$bits(result)-1:0]           result_r, next_result;
    logic [$clog2(WIDTH)-1:0]           count_r, next_cout;
    logic signed [$bits(result)-1:0]    diff_r, next_diff; 
    // logic                               done_r, next_done; 

    assign result = result_r;
    // assign done = done_r;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin 
            result_r <= '0;
            // done_r <= 1'b0;
            diff_r <= '0;
            count_r <= '0; 
            data_r <= '0; 
            state_r <= START; 
        end else begin 
            result_r <= next_result; 
            // done_r <= next_done; 
            diff_r <= next_diff; 
            data_r <= next_data; 
            state_r <= next_state; 
        end
    end

    always_comb begin
        next_result = result_r; 
        // next_done = done_r; 
        next_diff = diff_r; 
        next_data = data_r; 
        next_count = count_r;
        next_state = state_r;
        done = 1'b0;

        case (state_r) 
            START: begin 
                // next_done = 1'b0; 
                next_result = '0;
                next_diff = '0; 
                next_data = data; 
                next_count = '0; 
                done = 1'b0; 

                if(go) next_state = COMPUTE;
            end

            COMPUTE: begin 
                done = 1'b0; 
                next_diff = data_r[0] ? diff_r + 1 : diff_r - 1; 
                next_data = data_r >> 1; 
                next_count = count_r + 1'b1; 
                // don't use next count because it increases the length of path to adder and comparator
                if (count_r == WIDTH - 1) begin 
                    next_state = RESTART; 
                    next_result = next_diff; 
                    // next_done = 1'b1; 
                end
            end

            RESTART : begin 
                next_diff = '0; 
                next_count = '0; 
                next_data = data; 
                done = 1'b1; 

                if(go) begin 
                    // next_done = 1'b0; 
                    next_diff = '0; 
                    next_count = '0;
                end
            end
    
        endcase
    end
endmodule

