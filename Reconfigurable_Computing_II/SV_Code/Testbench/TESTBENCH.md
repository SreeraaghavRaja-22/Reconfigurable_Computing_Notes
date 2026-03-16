# Testbenches

## What are Assertions?

- Assertions are different tests that we can do to verify proper functionality
- Assertion Properties (kinda like combinational assertions) use sequencies for the sake of verification

## What is Coverage?

- Coverage is how many tests we need to fully test our design

### Types of Coverage Statements

**Cover Property**: checks if something is covered once
**Cover Group**: checks if something is covered more than once

### Ways to Increase Coverage

We can add more **Random Tests** or more **Directed Tests**

## Static vs. Automatic

**Static**: only one copy of a value for every call of that function
**Automatic**: (re-entrant) a new instance of a variable put onto the stack for every call of that function (kinda like **volatile**)

## Constrained Random Verification (CRV)

- We can somehow get 100% coverage with a smaller number of the tests that we used beforehand

## Universal Verification Method (UVM)

### Project Structure

- often need **Makefiles** to compile design

### Heirarchy

- Normal Interface has the following items as separate:
  - Transaction "item"
  - Generator
  - Scoreboard
- **Tests**
  - Transaction "item" => Sequence item have **Sequences of sequence items**
  - **Environment**
    - Scoreboard
    - a lot of other stuff
    - **Agent: encapsulates all functionality for an instance of an interface**
      - Driver
      - Monitor(s)
      - Sequencer: delivers transction items to the driver
- Once we make an agent, we can reuse it for any functionality

### Phasing System

**Build Phase**: all objects are created and initialized
**Connect Phase**: the components that were created in the build phase are connected together
**End of Elaboration Phase**: final setup and checks are done
**Run Phase**: the testbench actively performs the stimulus generation
**Report Phase**: the results of the verification process are generated and reported

### UVM Configuration Database

Central mechanism for managing and sharing configuration data across different components of the testbench

### UVM Factory

- UVM uses the factory to create objects in the testbench
- Need to register different types with the factory to use them in other places
