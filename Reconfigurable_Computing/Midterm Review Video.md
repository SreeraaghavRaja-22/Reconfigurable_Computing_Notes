- Make sure to join Zoom before taking the test on honorlock

#### Question 1: Pipelining Example 1

 ```VHDL
 unsigned short a[100000]; //unsigned short; 16 bits 
unsigned short b[100004];
 for int i=0; i < 100000; i++){
 a[i] = b[i] * 10 + b[i+1] * 20 + b[i+2] * 20 + b[i + 3] * 40
 }
memory bandwidth: 128 bits/cycle 

with no unrolling: 4 inputs * 16 bits = 64 bits

bits remaining for unrolling = 128 - 64 = 64 bits 

Each unrolling takes 16 bits 
# of unrolling: 64/16 = 4
parallel iterations: unrolling + 1 = 5 

total cycles with unrolling: cycles for first iteration + (remaining iterations / # of parallel iterations)

remaining iterations = total iterations - parallel iterations

total cycles = 5 + 99995 / 5 = 20004 cycles


Microprocessor: 
25 instructions per iteration 
100k iterations 
CPI = 1.5 
Clock = 10x faster than FPGA

Total cycles = total # of iterations * instructions per iteration * CPI = 100000 * 25 * 1.5 = 3750000

Speedup = CPU cycles / FPGA cycles / clock ratio
Clock Ratio = CPU Clock Speed / FPGA Clock Speed
Speedup = 3750000 / 20004 / 10
```

- **Variable Rules:**
	- If a variable is assigned on a rising clock edge it could become either a signal or a wire
		- **If there exists a path where the design reads from a variable before assigning it, then it will become a register
		- If you always assign variable before reading from it, then it will always get synthesized into a wire
- Understand Testbenches, FSM, Device Tradeoffs 
	- throw out designs that can't meet constraints 
- Know how to come up with a bit file
- NP-complete has not been solved in polynomial time 