## Binding/Resource Sharing 
- Also covers material from 10_31_25
---
### Binding 
- During scheduling, we determined: 
	- When ops will execute 
	- How many resources are needed 
- We still need to decided which operations execute on which resources 
	- => Binding 
	- If multiple ops use the same resource 
		- => Resource Sharing
- Basic Idea - Map operations onto resources such that **operations in the same cycle don't use same resource** 
	- 2 ALUs (+/-), 2 Multipliers![[Pasted image 20251102220619.png]]
- Many possibilities 
	- Bad binding may increase resources, require huge steering logic, reduce clock, etc. 
- ILLEGAL BINDING ![[Pasted image 20251102220844.png]]
	- 2 ALUs are mapped on the same cycle 
	- 2 Multipliers are mapped on the same node 
- How to automate? 
	- More graph theory
- **Compatibility Graph**
	- Each node is an operation
	- Compatible - if two operations can share a resource
		- I.E. Operations that use same type of resources (ALU, mult, etc.) and are scheduled to **different cycles** ![[Pasted image 20251102221206.png]]
			- **Fully Connected Subgraphs can share a resource (all involved nodes are compatible**
			- Example 1: ![[Pasted image 20251102221743.png]]
			- Example 2: ![[Pasted image 20251102221818.png]]
	- **Binding:** find the minimum number of fully connected subgraphs 
		- Well-known problem: **Clique Partitioning (NP-Complete)**
			- Cliques = {{2, 8, 7, 4},{3}, {1, 5}, {6}}
				- ALU1 executes 2, 8, 7, 4
				- ALU2 executes 3 
				- MULT1 executes 1, 5
				- MULT2 executes 6
	- Translation to Datapath
		- 1) Add resources and registers 
		- 2) Add mux for each input 
		- 3) Add input to left mux for each left input in DFG
		- 4) Do same for right mux 
		- 5) If only 1 input, remove MUX (gets classified as a wire) ![[Pasted image 20251102224207.png]]
	- **Left Edge Algorithm**
		- Take scheduled DFG, rotate it 90 degrees 
		- 1) Initialize right_edge to 0 
		- 2) Find a node N whose left edge is >= right_edge 
		- 3) Bind N to a particular resource 
		- 4) Update right_edge to the right edge of N 
		- 5) Repeat from 2) for nodes using the same resource type until right_edge passes all nodes 
		- 6) Repeat from 1) until all nodes bound ![[Pasted image 20251102225024.png]]
	- **Extensions**
		- Algorithms presented so far find a valid binding 
			- But, do not consider amount of steering logic required 
			- Different bindings can require significantly different # of muxes 
		- One Solution 
			- Extend compatibility graph 
				- Use weighted edges/nodes - cost function representing steering logic 
				- Perform clique partitioning, finding the set of cliques that minimize weight 
	- **Binding Summary**
		- Binding maps operations onto physical resources 
			- Determines sharing among resources 
		- Binding may greatly affect steering logic 
		- Trivial for fully-pipelined circuits 
			- 1 resource per operation 
			- Straightforward translation from bound DFG to datapath 
	- **Main Steps**
		- Front-end (lexing/parsing) converts code into intermediate representation
			- Looked at CDFG
		- Scheduling assigns a start time for each operation in DFG
			- CFG node start defined by control dependencies 
			- Resource allocation determined by schedule 
		- Binding maps scheduled operations onto physical resources 
			- Determines how resources are shared 
		- Big Picture: 
			- Scheduled/Bound DFG can be translated into a datapath 
			- CFG can be translated to a controller 
			- => High-level synthesis can create a custom circuit for any CDFG! 
	- **Limitations**
		- Task-level Parallelism 
			- Parallelism in CDFG limited to individual control states 
				- Can't have multiple states executing concurrently 
			- **Potential Solution: use model other than CDFG**
				- Kahn Process Networks 
					- Nodes represent parallel processes/tasks
					- Edges represent communication between processes 
				- High-level synthesis can create a controller + datapath for each process
					- Must also consider communication buffers 
			- Challenge: 
				- **Most high-level does not have explicit parallelism** 
					- Difficult/impossible to extract task-level parallelism from code 
				- **Elastic Computing and Elastic IP (research this)**
					- HLS tool recognizes an algorithm and tries to find a more optimal one 
		- **Coding Practices limit circuit performance** 
			- languages often contain constructs not appropriate for circuit implementation 
				- Recursion, pointers, virtual functions, etc. 
		- **Potential Solution:** use specialized languages
			- Remove problematic constructs, add task-level parallelism
		- **Challenge:**
			- difficult to learn new languages 
			- Many designers can resist changes to tool flow 
		- **Alias Analysis** (Pointers are hard to solve)
		 ```C
			  int f(int* a, int* b){
			  .....
			  // we assume that a and b point to different locations in memory 
			  // assuming that a and b are not aliases of each other
			  *a = 10
			  *b = 5
			  return *a + *b
			  }
			  
			  // we should return 15 if a and b are not aliases of each other
			  // we return 5 if they are aliases 
			  // we have to prove if they are aliases are not and then optimize 
			  ```
		- **Expert Designers can achieve much better circuits**
			- High-level synthesis has to work with specification in code 
				- Can be difficult to automatically create efficient pipeline 
				- May require dozens of optimizations applied in particular order 
			- Expert designer can transform algorithm 
				- Synthesis can transform code, but can't change algorithm 
			- Potential Solutions: 
				- New Language 
				- New Methodology 
				- New tools