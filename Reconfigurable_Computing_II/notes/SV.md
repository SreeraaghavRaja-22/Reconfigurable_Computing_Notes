# SV

## Recommendations

- Methodology: design the circuit before coding it
- Write SV with a **linter** to not run into stupid errors
  - Run linter on vivado before synthesizing code
- Combinational logic synthesizes efficiently when described behaviorally
  - usually don't describe other logic this way

## Combinational Logic

- use **always_comb**
- use blocking assignments for combinational logic
  - blocking assignments are kinda like variables in vhdl
  - updated immediately
- use non-blocking assignments are like signals in vhdl
  - updated at end of time stamp

### What is the difference between always @(*) and always_comb?

- always_comb will always change at time 0 regardless of the inputs changing
- always @(*) will only execute when the inputs change

### Unique Keyword

- Makes sure you don't have multiple instances of the same case (case overlap)
- Requires you to **define all paths for a case statement**

### Priority Keyword

- If you don't define all paths and we use priority assignment, it will turn into a don't care (X)
- Don't use it

### Parameters

- don't have to define a type for a parameter
  - it will get its type from when it's assigned
- should usually specify the type for parameter

### What kind of circuit does a for loop synthesize into?

- Elaboration will fully unroll the for loop
  - By the time we get to synthesis, there will no longer be any for loop

### Structural Logic

- Always draw out structural logic before writing code
  - This will help figure out what to do (ex: look at mux4x1_design.png)
  
## Sequential Logic

### Main Code Structure

```sv
  always_ff @(posedge clk or posedge rst) begin 
    if(rst) begin 
      out <= '0; 
    end else begin 
      out <= in;
    end

    // or 

  always_ff @(posedge clk or posedge rst) begin 
      out <= in;
      if(rst) out <= '0;

```

- Use **always_ff** block to catch sequential logic errors
- Synchronous reset may take more resources than an async reset
  - uses a mux
- ALWAYS USE NONBLOCKING ASSIGNMENTS
