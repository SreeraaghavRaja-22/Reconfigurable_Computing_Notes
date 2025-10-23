- Previous Lecture was finished under the 10_15_25 Lecture

## Lab 4 Implementation 

- Pipeline the following code
```C
for(i=0, j=0; j < OUTPUT_SIZE; i+=4, j++){
	a[j] = b[i]*b[i+1]+b[i+2]*b[i+3];
}
```

- Step 1: Implement the Datapath 
	- Registers -> Multipliers -> registers -> adder -> registers -> output 
		- Could do this structurally 
		- **Try to do this behaviorally** since this is a simple pipeline and will be a lot less code 
		- Need **CLK, RST, and EN**
			- But the Enable should be hardcoded to '1'
			- This will help make the code useful for other use-cases 
- Step 2: Create a Testbench for the Entity 
	- There will be bugs 
	- Much easier to catch bugs 
	- We will try to find very thorough testbenches 
- Step 3: **Make Addr Generators**, **Controller**, and **Datapath**
	- Focus on one particular concept for each lab
- Step 4: Connect Addr Generators to RAMs 
	- **mem_in_rd_addr** comes from address generator
	- **mem_in_rd_data** provides data to datapath
	- No read_en means that we read every cycle 
		- input_valid signal is still useful for controller 
	- Input address generator never needs to be stalled, so its enable will always be '1'
	- Output address generator will not be enabled until the output address is valid 
- Step 5: Check when the first output is valid (Controller)
	- Get a shift register that check the when the **output is valid**
		- From Lab 0 
		- Valid_In -> Reg X delay -> Valid_Out
	- Input is valid 1 cycle after address is generated 
		- It goes through RAM, so that's a 1 cycle delay 
		- use the **addr_valid output signal**
- Step 6: Connections to avoid having a controller 
	- Connect Go from memory map to Go of address generators 
	- Connect Size of memory map to Size of address generators


--- 
### Memory Access Patterns of Input Stream

- Shift by 4 for every loop of pipeline
- **Address Generator is a counter** from 0 to Size - 1
	- **count value gives address location to RAM**
- **Example Interface for Address Generator**
```vhdl
	 inputs: 
	 go 
	 size 
	 
	 outputs:
	 addr 
	 addr_valid
	 done 
	```

