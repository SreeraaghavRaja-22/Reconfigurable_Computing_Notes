## Introduction: 
- Designers specify timing constraints related to circuit 
	- *Desired Clock Frequency*
- Synthesis Tool verifies if designs meet all timing constraints 
	- *Uses Static Timing Analysis (STA)*
- If constraints are not met, designer performs **timing optimization/closure**
	- *A design "meets timing" or "closes timing"* when all constraints are met 
	- Hard problem to figure out
---
## How to Determine Timing Constraints
- Designer specifies timing constraints based on use case: 
	- FPGA board provides fixed clock frequency 
		- Constraint: achieved clock must match or exceed the board's frequency
	- Design has real-time constraints 
		- Signal-processing circuit produces outputs every 1000 cycles for 44.1 kHz audio 
		- Constraint: achieved clock must be $\geq$ 44.1 MHz
	- Design has bandwidth requirements 
		- use a 32-bit (4 byte) bus, a circuit requires 1.6 GB/s of input bandwidth 
		- Constraint: achieved clock must be $\geq$ 1.6 GB/s / 4 bytes = 400 MHz
	- Maximize Performance 
		- pick an aggressive constraint, optimize until met (Timing Optimization), repeat until we can improve clock frequency anymore 
		- or, pick super aggressive constraint and use clock reported by timing analyzer
			- issue is that timing analyzer will give a "pessimistic" clock frequency for a super aggressive constraint 
	- Other stuff 
---
## Clock Frequency 
- Requirement: data must arrive at each FF before next cycle 
- Clock period ($T_{clk}$) is a deadline ($T_{deadline}$) for delay between FFs ($T_{FF-to-FF}$) 
- $T_{FF-to-FF} \leq T_{deadline}$ where $T_{deadline} = T_{clk}$
	- $T_{deadline}$ should be $\leq T_{clk}$
	- Simplified Definition
- Example Image: ![[Pasted image 20251130132804.png]]

---
## FF-to-FF Delays 
- FF-to-FF ($T_{FF-to-FF}$) determined by summation of: 
	- "Cell" delays ($T_c$)
		- any non-interconnect resource (FFs, CLBs, LUTs, RAM, DSP, etc.)
		- Note that FFs have a **Clk-to-Q delay: time between clock edge and appearance of output Q**
	- Interconnect Delays ($T_{IC}$)
		- Connections between cells (wires, connection boxes, switch boxes, etc.)
	- Example Image: ![[Pasted image 20251130133352.png]]
	- There are frequently multiple paths between same FFs 
		- Must consider the path with the **maximum delay**
		- Interconnect delays often vary across paths due to routing differences 
		- Example Image: ![[Pasted image 20251130133548.png]]
			- Considers the longer path since that is the constraint for timing 
---
## Maximum Clock Frequency 
- Maximum clock frequency ($f_{max}$) defined by longest delay between all FFs 
	- Referred to as "critical path"
- Example Image: ![[Pasted image 20251130134037.png]]
- Critical path delay ($T_{CP}$) is 10 ns (between FF3 and FF4)
	- Clock period ($T_{clk}$) must be $\geq T_{CP}$ or data won't be available yet on FF4
	- $f_{max} = \frac{1}{T_{CP}} = \frac{1}{10} = \text{100 MHz}$
---
## Setup Times 
- Flip-flops have a *setup time* ($T_{setup}$)
	- Window of time **before** rising clock edge where changing input causes **metastable** output 
- Data must arrive at flip-flop **before** setup window of next clock 
- Example Image: ![[Pasted image 20251130134234.png]]
- Most important concepts 
	- Deadline Time has to be less than or equal to Tclk - Tsetup 
---
## Clock Skew
- Clocks are high-fanout signals
	- Not possible to deliver clock to every FF at the same time 
	- Difference in clock arrival times between FFs known as **clock skew**
- Clock skew affects available time before setup violation 
- Example Image: ![[Pasted image 20251130134807.png]]
	- Positive skew increases deadline = Helps avoid setup violations
---
## Setup Slack 
- Setup Slack ($S_{setup}$) 
	- Time between setup deadline and data arrival 
- Example Image: ![[Pasted image 20251130135014.png]]
	- Large positive slack can help with optimizing other paths (e.g. retiming)
---
## Hold Times 
- FF hold time ($T_{hold}$) is window of time **after rising clock edge**
	- Input changing within hold window causes **metastable FF output**
- New data must **not** arrive at flip flop during hold window 
- Example Image: ![[Pasted image 20251130135621.png]]
---
## Hold Slack 
- Hold Slack ($S_{hold}$) = time between data arrival and hold violation 
- Example Image: ![[Pasted image 20251130135804.png]]
--- 
## Timing Optimization Preview 
- Focus on setup violations 
- To avoid setup violations, ensure that: 
	- $T_{C} + T_{IC} \leq T_{clk} + T_{skew} - T_{setup}$
	- AKA $T_{FF-to-FF} \leq T_{deadline}$
- $T_{deadline}$ generally out of control of designer
- Timing optimization focuses primarily on reducing $T_{FF-to-FF}$
	- Two options: 
		- Reduce cell/logic delays ($T_C$)
		- Reduce interconnect delays ($T_{IC}$)