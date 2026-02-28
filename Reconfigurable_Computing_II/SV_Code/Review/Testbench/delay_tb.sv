	`timescale 1 ns / 100 ps

	module delay_tb1 #(
		parameter int NUM_TESTS = 1000, 
		parameter int CYCLES = 4, 
		parameter int WIDTH = 8
	); 
	
		logic clk = 1'b0; 
		logic rst, en; 
		logic [WIDTH-1:0] data_in; 
		logic [WIDTH-1:0] data_out; 
		
		delay #(
			.CYCLES(CYCLES), 
			.WIDTH(WIDTH)
		) DUT (
			.*
		);
		
		initial beign : generate_clock
			forever #5 clk <= ~clk; 
		end 
		
		initial begin 
			$timeformat(-9, 0, " ns"); 
			
			// Initialize the circuit 
			rst 	<= 1'b1;
			en  	<= 1'b0; 
			data_in <= '0; 
			repeat(5) @(posedge clk); 
			
			@(negedge clk); 
			rst <= 1'b0; 
			
			// Generate NUM_TESTS random tests. 
			for (int i = 0; i < NUM_TESTS; i++) begin 
				data_in <= $urandom; 
				en      <= $urandom; 
				@(posedge clk); 
			end 
			
			// Stop the always blocks.
			disable generate_clock;
			$display("Tests Completed"); 
		end
			
			
		// In the code below, we create our dealy model and verify the DUT
		
		// Round up the buffer to the next power of 2, which is necessary beacuse 
		// of the addressing logic
		localparam int BUFFER_SIZE = 2 ** $clog2(CYCLES); 
		
		// Reset the buffer contents.
		logic [WIDTH-1:0] buffer[BUFFER_SIZE] = '{default: '0};
		
		// Reset the buffer contents. 
		logic [$clog2(CYCLES)-1:0] wr_addr = 0; 
		logic [$clog2(CYCLES)-1:0] rd_addr; 
		
		logic[WIDTH-1:0] correct_out; 
		// The read address should be offset from the write address by CYCLES + 1; 
		assign rd_addr = wr_addra - CYCLES + 1; 
		
		// Verify the outputs by comparing the actual output with the model's output. 
		initial begin : check_output 
			forever begin
				@(posedge clk); 
				if (data_out != correct_out) $error("[%0t] out = %0h instead of %0h.", $realtime, data_out, correct_out);
			end 
		end 
		
		// Note that instead of the check_output initial block, we could have just done this:
		assert property(@(posedge clk) disable iff (rst) data_out == correct_out);
		
		// Create the reference model.
		generate 
			if (CYCLES == 0) begin 
				assign correct_out = data_in; 
			end else begin 
				// Imitate a memory with one-cycle read dealy to store the correct outputs. 
				always @(posedge clk, posedge rst) begin 
					if (rst) correct_out <= '0; 
					else if (en) begin
						buffer[wr_addr] = data_in; 
						correct_out <= buffer[rd_addr];
						wr_addr <= wr_addr + 1'b1; 
					end 
				end 
			end 
		endgenerate 
	endmodule 
	
	module delay_tb2 #(
		parameter int NUM_TESTS = 1000, 
		parameter int CYCLES = 4, 
		parameter int WIDTH = 8
	); 
	
		logic clk = 1'b0; 
		logic rst, en; 
		logic [WIDTH-1:0] data_in; 
		logic [WIDTH-1:0] data_out; 
		
		delay #(
			.CYCLES(CYCLES), 
			.WIDTH(WIDTH)
		) DUT (
			.*
		);
		
		initial beign : generate_clock
			forever #5 clk <= ~clk; 
		end 
		
		initial begin 
			$timeformat(-9, 0, " ns"); 
			
			// Initialize the circuit 
			rst 	<= 1'b1;
			en  	<= 1'b0; 
			data_in <= '0; 
			repeat(5) @(posedge clk); 
			
			@(negedge clk); 
			rst <= 1'b0; 
			
			// Generate NUM_TESTS random tests. 
			for (int i = 0; i < NUM_TESTS; i++) begin 
				data_in <= $urandom; 
				en      <= $urandom; 
				@(posedge clk); 
			end 
			
			// Stop the always blocks.
			disable generate_clock; 
			$display("Tests Completed"); 
		end
		
		
		// in this testbench, we model the delay using a queue. A queue is declared 
		// in a way that is similar to an unpacked array, but uses $ for the range
		logic [WIDTH-1:0] model_queue[$]; 
		
		always_ff @(posedge clk or posedge rst) begin
			if(rst) begin 
				// on reset, initialize the queue with CYCLES 0 value sto mimic
				// the reset behavior of the delay.
				model_queue = {};
				for(int i = 0; i < CYCLES; i++) model_queue.push_back('0);
				
				// or, alternatively: 
				// for (int i = 0; i < CYCLES; i++) model_queue = {model_queue, WIDTH'(0)};
			end else if (en) begin
				// Update the queue by popping the front and pushing the new input. 
				// Note that these are blocking assignments 
				
				// void cast is not required but is useful when we don't want the simulator
				// to throw and error when we don't want a return value
				void'(model_queue.pop_front()); 
				model_queue.push_back(data_in); 
				
				// Or, alternatively:
				// model_queue = {model_queue[1:$], in}; // takes slice from 1 to end and appends
				// in to end of it
			end 
		end
			
		// The output should simply always be the gront of the reference queue. 
		// IMPORTANT: In previous examples, we saw the race conditions being caused by
		// one process writing with blocking assignments, and another process reading
		// those values. There is no race condition here because an assert 
		// always samples the "preponed" values of the referenced signals. In other
		// words, you can think of the sampled values as the ones before the 
		// simulator updates anything on a clock edge. Alternatively, you can think
		// of those values as the ones just before the posedge of the clock. 
		// Interestingly, this means that any reference to the clock here will always 
		// be 0, because the clock is always 0 before a rising clock edge. 
		assert property (@(posedge clk) data_out == model_queue[0]); 
	endmodule 
	
	module delay_tb3 #(
		parameter int NUM_TESTS = 1000, 
		parameter int CYCLES = 4, 
		parameter int WIDTH = 8
	); 
		
		logic clk = 1'b0; 
		logic rst, en; 
		logic [WIDTH-1:0] data_in; 
		logic [WIDTH-1:0] data_out; 
		
		delay #(
			.CYCLES(CYCLES), 
			.WIDTH(WIDTH)
		) DUT (
			.*
		);
		
		initial begin : generate_clock
			forever #5 clk <= ~clk; 
		end 
		
		initial begin 
			$timeformat(-9, 0, " ns"); 
			
			// Initialize the circuit 
			rst 	<= 1'b1;
			en  	<= 1'b0; 
			data_in <= '0; 
			repeat(5) @(posedge clk); 
			
			@(negedge clk); 
			rst <= 1'b0; 
			
			// Generate NUM_TESTS random tests. 
			for (int i = 0; i < NUM_TESTS; i++) begin 
				data_in <= $urandom; 
				en      <= $urandom; 
				@(posedge clk); 
			end 
			
			// Stop the always blocks.
			disable generate_clock; 
			$display("Tests Completed"); 
		end
		
		// Incorrect Attempt 1: 
		// Although this correctly checks if output matches the input from CYCLES
		// previous cycles, it ignores the value of reset, which could cause failures
		// when reset is asserted. 
		
		// assert property(@(posedge clk) data_out == $past(data_in, CYCLES)); 
		
		// Incorrect Attempt 2: 
		// This assertion disables checks during reset. However, despite working for
		// small CYCLES values, it only works coincidentally because the testbench 
		// uses an input that matches the rest value for the output. As soon as the
		// CYCLES exceed teh number of cycles for rests, this starts failing. 
		
		// assert property(@(posedge clk) disable iff (rst) data_out == $past(data_in, CYCLES)); 
		
		// Utimately, we need to check the output in 2 states: 
		// 1) When all the outputs are based on the reset, and 
		// 2) When the output actually corresponds to a delayed input. 
		
		// To determine what state we are in, we'll add a counter that simply counts
		// until reaching CYCLES. When count < CYCLES, we know that an input hasn't
		// reached the output yet. When count == CYCLES, we can safely use $past. 
		int count; 
		always_ff @(posedge clk or posedge rst)
			if (rst) count <= '0; 
			else if (count < CYCLES) count <= count + 1; 
			
		// Don't check for the output matching the dealyed input until an input 
		// has reached the output. 
		assert property (@(posedge clk) disable iff (rst || count < CYCLES) data_out == $past(data_in, CYCLES));
		
		// Check for correct outputs during reset and until inputs reach the output. 
		assert property (@(posedge clk) disable iff (count == CYCLES) data_out == '0); 
	endmodule
	
	module delay_tb4 #(
		parameter int NUM_TESTS = 1000, 
		parameter int CYCLES = 4, 
		parameter int WIDTH = 8
	); 
		
		logic clk = 1'b0; 
		logic rst, en; 
		logic [WIDTH-1:0] data_in; 
		logic [WIDTH-1:0] data_out; 
		
		delay #(
			.CYCLES(CYCLES), 
			.WIDTH(WIDTH)
		) DUT (
			.*
		);
		
		initial begin : generate_clock
			forever #5 clk <= ~clk; 
		end 
		
		initial begin 
			$timeformat(-9, 0, " ns"); 
			
			// Initialize the circuit 
			rst 	<= 1'b1;
			en  	<= 1'b0; 
			data_in <= '0; 
			repeat(5) @(posedge clk); 
			
			@(negedge clk); 
			rst <= 1'b0; 
			
			// Generate NUM_TESTS random tests. 
			for (int i = 0; i < NUM_TESTS; i++) begin 
				data_in <= $urandom; 
				en      <= $urandom; 
				@(posedge clk); 
			end 
			
			// Stop the always blocks.
			disable generate_clock; 
			$display("Tests Completed"); 
		end
			
		int count; 
		always_ff @(posedge clk or posedge rst) begin 
			if (rst) count <= '0; 
			else if (en && count < CYCLES) count <= count + 1;
		end
			
			// Here, we simply add a gating parameter to the $past signal using the
			// en signal. This causes the $past to ignore values in cycles when en 
			// is 0.  
			assert property (@(posedge clk) disable iff (rst) count == CYCLES |-> data_out == $past(data_in, CYCLES, en));
			
			// Conceptually identical to the above assertion, this assertion fails 
			// on the clock edge where count becomes CYCLES. Disable does not sample valus. 
			// As a result, the assertion is enabled earlier than expected due to count
			// changing immediately after the clock edge where the other values were sampled.
			
			// assert property(@(posedge clk) disable iff (rst || count < CYCLES) data_out == $past(data_in, CYCLES, en)); 
			
			// To fix it, we can do the following, which ends up identical to the first assertion: 
			
			// assert property (@(posedge clk) disable iff (rst || $sampled(count) < CYCLES) data_out == $past(data_in, CYCLES, en));
			
			assert property (@(posedge clk) disable iff (rst) count < CYCLES |-> data_out == '0); 
			
			// Check to make sure the output doesn't change when not enable 
			assert property (@(posedge clk) disable iff (rst) !en |=> $stable(data_out)); 
			
	endmodule 
	
	
	// Improves on the previous testbench by eliminating the 
	// need for a counter to determine when to enable previous assertions. 
	module delay_tb5 #(
		parameter int NUM_TESTS = 1000, 
		parameter int CYCLES = 4, 
		parameter int WIDTH = 8
	); 
		logic clk = 1'b0; 
		logic rst, en; 
		logic [WIDTH-1:0] data_in; 
		logic [WIDTH-1:0] data_out; 
		
		delay #(
			.CYCLES(CYCLES), 
			.WIDTH(WIDTH)
		) DUT (
			.*
		);
		
		initial begin : generate_clock
			forever #5 clk <= ~clk; 
		end 
		
		initial begin 
			$timeformat(-9, 0, " ns"); 
			
			// Initialize the circuit 
			rst 	<= 1'b1;
			en  	<= 1'b0; 
			data_in <= '0; 
			repeat(5) @(posedge clk); 
			
			@(negedge clk); 
			rst <= 1'b0; 
			
			// Generate NUM_TESTS random tests. 
			for (int i = 0; i < NUM_TESTS; i++) begin 
				data_in <= $urandom; 
				en      <= $urandom; 
				@(posedge clk); 
			end 
			
			// Stop the always blocks.
			disable generate_clock; 
			$display("Tests Completed"); 
		end
		
		// en[->CYCLES] replaces the previous counter by doing the same thing in
		// much less code. This operator is called the "go to" repetition operator. 
		// It causes thea antecedent to trigger after en has been asserted in CYCLES
		// cycles, which do not have to be consecutive. 
		assert property (@(posedge clk) disable iff (rst) en [-> CYCLES] |=> data_out == $past(data_in, CYCLES, en));
		
		// To verify the reset, we can check to make sure the data_out is 0 
		// throughout the entire window of time between when reset is cleared 
		// until en has been aserted in CYCLES times. The following assertion
		// accomplishes this concisely.
		
		assert property(@(posedge clk) $fell(rst) |-> data_out == '0 through en[-> CYCLES]);
		
		// Verify the output during reset. 
		assert property (@(posedge clk) rst |=> data_out == '0);
		
		// Check to make sure the output doesn't change when not enabled. 
		assert property (@(posedge clk) disable iff (rst) !en |=> $stable(data_out)); 
		
		// Common Mistakes: 
		// The following assertion is similar to the one we used above. However, it 
		// does not use implication based on the misunderstanding that en[->CYCLES]
		// will stop after CYCLES assertions of en. While each instance of
		// en[-> CYCLES] stops at that time, the assertion generates a window for 
		// *every* possible of CYCLES enables during the entire sim. So, this 
		// assertion will fail after the first test because data_out will clearly 
		// clearly not be after 0 at later points in the simulaton. The above version
		// wored becuase it was only triggered once when rst fell.
		
		// assert property (@(posedge clk) disable iff (rst) data_out == '0 throughout en [-> CYCLES]); 
		
		// The following is another potential solution that has common misunderstanding. 
		// Whemn reading this in English, it sounds like what we want: wait until 
		// reset falls, that check that data_out is 0 **until the beginning** of a window
		// of time between 0 and CYCLES enables. Because that window starts immediately, 
		// this assertion actually doesn't check anything. This is dangerous because 
		// it always succeeds even when our DUT is wrong. Test this yourself by
		// setting the reset value of the dealy to a non-zero value. Thi assertion
		// will still succeed. 
		
		// assertion property (@(posedge clk) disable iff (rst) $fell(rst) |-> data_out == '0 until en[-> CYCLES]);
		
		// DEBUGGING TIPS
		// One challenge with complex assertions is that you have to verify the
		// assertion itself. While failures are reported automatically, sometimes
		// it is useful to analyze when assertion succeeds. You can do this as follows. In Questa, I get following
		// for CYCLES=4: 
		// ** Info: [85 ns] Assertion Succeeded for data_out = 0
		// #    Time: 85 ns Started: 55 ns Scope: ....
		
		// Notice the "Time" of 85 ns (when the assertion finished) and the 
		// "Started" (when the assertion is triggered). This corresponds to exactly
		// the first clock after reset, and the clock after CYCLES enables. 
		// This tells me it is checking the exact range of time I wanted. 
		
		// assert property (@posedge(clk) $fell(rst) |-> data_out == '0 throughout en [->CYCLES]) begin 
		//  $info([%0t] Assertion Succeeded for data_out = %0h", $realtime, $sampled(data_out));
		// end
		
		// Similarly, on assertion failure, it can help to print out the variables
		// used in the assertion. This can be done by adding an "else" to the 
		// assertion. Make sure to use $sampled when priting variables.
		// Otherwise, you will see updated value that often cause confusion. 
		// YOu can also print with $past();
		
		// assert property (@(posedge clk) disable iff (rst) data_out == '0 throughout en [-> CYCLES])
		// else $error("[%0t]: actual data_out = %0d, exepcted 0", $realtime,, $sampled(data_out)); 
		
	endmodule 