`timescale 1 ns / 10 ps

module perfect_square_calculator_tb #(
	parameter int NUM_TESTS = 1000,
	string ARCH = "fsm_d"
);

	localparam INPUT_WIDTH = 8;
	logic clk = 0, rst, go, done; 
	logic out; 
	logic [INPUT_WIDTH-1:0] n;

	function automatic logic perf_square(logic [WIDTH-1:0] n_in);
		logic [WIDTH-1:0] k; 
		logic [(2*WIDTH-1):0] square; 
		
		k = INPUT_WIDTH'(1); 
		square = '0; 
		
		while (square < n_in) begin 
			square = k*k; 
			k++; 
		end 
		
		return (square == n_in) ? 1'b1 : 1'b0;
	endfunction
	
	generate 
		if (ARCH == "fsmd") begin : DUT_GEN 
			is_perfect_square #(.INPUT_WIDTH(INPUT_WIDTH)) DUT (.*);
		end else if (ARCH == "fsm_d") begin : DUT_GEN 
			is_perfect_square_fsm_d #(.INPUT_WIDTH(INPUT_WIDTH)) DUT (.*);
		end 
	endgenerate

	initial begin : generate_clk 
		forever #5 clk <= ~clk; 	
	end 
	
	initial begin : generate_stim
		int valid_out = 0; 
		int output_t = 0; 
		int output_f = 0; 
		
		// Reset 
		rst <= 1'b1; 
		go 	<= 1'b0; 
		n  	<= '0; 
		
		repeat(5) @(posedge clk); 
		@(negedge clk); 
		rst <= 1'b0;
		
		for (int i = 1; i < NUM_TESTS; i++) begin
			n <= INPUT_WIDTH'(i) // Explicit width casting 
			
			// start conversion 
			go <= 1'b1; 
			@(posedge clk); 
			@(negedge clk); 
			go <= 1'b0; 
			
			// wait for done
		
		end 
		
		
	end
	
	
	
endmodule 





