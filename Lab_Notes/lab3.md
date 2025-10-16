# Lab 3 notes

## Part 1

### Definitions

- **wrapper:** *Top-level entity* for the entire project
  - Entity that will be instantiated from within the AXI peripheral code
  - Instantiates the *user_app* entity
- **user_app:** a simple, *memory-map* interface that is much more modular / portable than the *AXI interface*
- **config_pkg.vhd:** contains constants and types that are used for configuring the virtual board interface
- **user_pkg.vhd:** provides contraints/constants used throughout the application
  - similar to a *Header File* in C
- **user_app_tb.vhd:** shows how to send inputs and read outputs to/from the memory map
  - Interfaces memory map and is_perfect_sq together
  - *memory_map* provides the inputs to *is_perfect_square*
  - *is_perfect_square* connects to *memory_map* through *done* and *output* signals
- **memory_map.vhd:** implements the memory map entity that enables application-specific communication with FPGA resources

---

### Processor Information

- **wr_en:** asserted by memory_map when the processor is trying to store something
- **wr_data:** specifies what data is being written
- **rd_en:** asserted by memory_map when the processor is trying to do a read instruction
- **rd_data:** sent out one cycle after rd_en is asserted for this lab

---

### Memory Map Information

- Make registers for all inputs
- Read from both *outputs* and *inputs*
  - Inputs is especially important
  
``` vhdl
architecture BHV of memory_map is 
    signal go_r : std_logic; 
    signal n_r  : std_logic_vector(15 downto 0);
begin 
    process(clk, rst)
    begin 
        if write 
            see wr_addr
            -- case(wr_addr)
            assign wr_data to appropriate destination
            e.g. if wr_addr = C_GO_ADDR then go_r <= wr_data(0);
            e.g. if wr_addr = C_N_ADDR then n_r <= wr_data(15 downto 0);
        end if; 

        if read 
            see rd_addr 
            provide corresponding data on rd_data (1 cycle later)

            if(rd_addr = 2) then 1 cycle later rd_data should get output
            -- probably clock read data to get that delay
    end process; 

    go <= go_r; 
    n  <= n_r; 
```
