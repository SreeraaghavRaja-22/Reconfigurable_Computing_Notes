// perfect square calculator 


module fsmd_1p #(
	parameter int INPUT_WIDTH = 8
)(
	input logic clk, 
	input logic rst, 
	input logic go, 
	input logic [INPUT_WIDTH-1:0] n, 
	output logic done, 
	output logic out	 
);

	
	// 1P FSMD with a synchronous reset
	typedef enum logic [1:0]{
		START = 2'b00,
		SQUARE = 2'b01, 
		DONE = 2'b10, 
		XXX = 'x
	} state_t; 
	
	state_t state_r; 
	logic [INPUT_WIDTH-1:0] n_r, k_r;
	logic [2*INPUT_WIDTH-1:0] square_r;
	logic done_r, out_r;  
	
	
	always_ff @(posedge clk) begin 
		
		case (state_r)
			START : begin 
				n_r <= n; 
				k_r <= INPUT_WIDTH'(1);
				
				if (go) begin 
					done_r 		<= '0; 
					square_r 	<= '0; 
					state_r 	<= SQUARE;
				end
			end 
			
			SQUARE : begin 
				out_r <= 1'b0; 
				if(square_r < n_r) begin 
					square_r <= k_r ** 2;
					k_r <= k_r + 1'b1; 
					state_r <= SQUARE;
				end else if (square_r == n_r) begin 
					out_r <= 1'b1; 
					done_r <= 1'b1; 
					state_r <= START; 
				end 
			end	
			
			default : begin state_r <= XXX; end
		endcase 
	
		if (rst) begin
			state_r 	<= START; 
			square_r 	<= '0; 
			n_r 		<= '0; 
			k_r 		<= '0; 
			done_r 		<= 1'b0; 
			out_r 		<= 1'b0;
		end
	end 

	assign out = out_r; 
	assign done = done_r; 
	
endmodule 