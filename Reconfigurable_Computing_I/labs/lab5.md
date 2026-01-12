# Lab 5 Notes

---
## Part 1:  Dual-Flop Synchronizers 
- What are we doing?
	- Sending a single bit across clock domains 
- What should we use? 
	- Implement a dual flop synchronizer 
	- 2 mistakes in part 1 
		- in terms of synchronization 
		- good reason why it doesn't end up causing problems 
---
## Part 2: Handshake Synchronizers 
- Where is the issue? 
	- The issue is in the synchronization between domains for the **send** and **ack** signals 
	
--- 
## Part 3: FIFO Synchronizers 
- Same as Part 2, but replace the Handshake Synchronizers with FIFOs
- FIFO setup steps 
	- Click on IP Catalog 
	- Locate Memories & Storage Elements 
	- Click FIFOs
	- Select FIFO Generator 
	- Configure the FIFO 
		- Independent Clocks Block RAM 
		- First Word Fall Through
		- 32-bits wide
		- Write Depth is 64 (could be different for the lab)
	- Name the Component 
		- best to name it fifo_generator_32_in
	- Click Okay and Generate the component
- Generate IPs for the FIFOs
- Get the simulation libraries working for Lab 5 
- Find Stitt's tutorial 
---
