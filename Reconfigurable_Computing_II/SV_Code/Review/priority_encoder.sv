module priority_encoder #(
    // generic 
    parameter int NUM_INPUTS = 4;
)
(
    input logic [NUM_INPUTS-1:0] inputs, 
    output logic [$clog2(NUM_INPUTS)-1:0] result, 
    output logic valid
);

    localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS);

    always_comb begin 
        valid = 1'b1; 
        result = '0;  // (others => '0')

        for (int i = NUM_INPUTS-1; i >= 0; i--) begin 
            if(inputs[i]) begin 
                result = NUM_OUTPUTS'i; 
                valid = 1'b1; 
                break;
            end
        end
    end


endmodule // priority encoder 1


module priority_encoder_2 #(
    // generic 
    parameter int NUM_INPUTS = 4;
)
(
    input logic [NUM_INPUTS-1:0] inputs, 
    output logic [$clog2(NUM_INPUTS)-1:0] result, 
    output logic valid
);

    localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS);

    always_comb begin 
        valid = 1'b1; 
        result = '0;  // (others => '0')

        for (int i = 0; i < NUM_INPUTS; i++) begin 
            if(inputs[i]) begin 
                result = NUM_OUTPUTS'i; 
                valid = 1'b1; 
            end
        end
    end


endmodule // priority encoder 2

module priority_encoder_3 #(
    // generic 
    parameter int NUM_INPUTS = 4;
    localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS); // this will make sure that we can't override NUM_OUTPUTS when defining structurally
)
(
    input logic [NUM_INPUTS-1:0] inputs, 
    output logic [NUM_OUTPUTS-1:0] result, 
    output logic valid
);

    always_comb begin 
        valid = 1'b1; 
        result = '0;  // (others => '0')

        for (int i = 0; i < NUM_INPUTS; i++) begin 
            if(inputs[i]) begin 
                result = NUM_OUTPUTS'i; 
                valid = 1'b1; 
            end
        end
    end


endmodule // priority encoder 3