# Testbenches

## Common Testbench Types

- A **simple testbench** is a testbench is provide a stimulus to your design by **driving inputs into the DUT** waiting some time and **verifying output**

### Monolithic Testbench

- **Definition**: a testbench that has all its process happen in the same process

## Common Testbench Tips

1. Always use **non-blocking assignments** to drive a DUT
2. Use explicit times for testbench instead of using timescale (good for certain things) but mainly use timescale
3. 