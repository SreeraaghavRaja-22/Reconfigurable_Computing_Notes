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

- Don't use it
