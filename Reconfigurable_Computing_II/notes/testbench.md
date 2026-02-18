# Testbenches

## Common Testbench Types

- A **simple testbench** is a testbench is provide a stimulus to your design by **driving inputs into the DUT** waiting some time and **verifying output**

### Monolithic Testbench

- **Definition**: a testbench that has all its process happen in the same process

## Common Testbench Tips

1. Always use **non-blocking assignments** to drive a DUT
2. Use explicit times for testbench instead of using timescale (good for certain things) but mainly use timescale


## Race Conditions

- Several examples on SV tutorial
- Definition:
  - ordering of parallel processes could lead to properly functionality and could causes bugs later

### How to Fix Race Conditions

- Sequentialize ordering
- Any processed that is synced up to a rising clock edge can resume before any other process
- Fix for certain race conditions
  - Every signal driving the DUT has to be a **non-blocking assignment**
    - Why?
- **Rule:** If a signal is assigned in one process and read in another, where both are synchronized to the same event, and the assignment is blocking, then you have a race condition.
  - Most common version of race condition
- Ways to Not Fix Race Conditions
  - Add a wait (#time)
    - Cons: adds delays that make everything unsychronized
    - Every process has to finish for one timestep before moving to the next timestep
  - When dealing with a bunch of race conditions with a bunch of processes, use a **clocking block**
  - try to avoid using this until you understand race conditions
- Preferred Solution: **non-blocking assignments**

- **Rule:** Always drive inputs with non-blocking assignments
- 