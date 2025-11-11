library ieee; 
use ieee.std_logic_1164.all; 

entity reg is 
    generic( 
        WIDTH : positive := 16
    );
    port(
        clk : in std_logic;
        rst : in std_logic; 
        en  : in std_logic; 
        input : in std_logic_vector(WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity reg;

architecture bhv of reg is 
    signal output_r : std_logic_vector(WIDTH-1 downto 0);
begin 
    process(clk, rst) 
    begin 
        if rst = '1' then 
            output_r <= (others => '0');
        elsif rising_edge(clk) then 
            if en = '1' then 
                output_r <= input; 
            end if; 
        end if; 
    end process; 
    output <= output_r; 
end architecture bhv; 
                
------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 

entity delay is 
    generic(CYCLES : natural := 8; -- need cycles to be natural so we can support a cycles value of 0
            WIDTH  : positive := 16);
    port(   
        clk       : in std_logic;
        rst       : in std_logic; 
        en        : in std_logic; 
        input     : in std_logic_vector(WIDTH-1 downto 0);
        output    : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity delay; 


architecture STR of delay is 
    type reg_array_t is array (0 to CYCLES) of std_logic_vector(WIDTH-1 downto 0); --  define array type
    signal d : reg_array_t; -- make a signal of array type 

begin

    -- special case for 0 cycles 
    U_CYCLES_EQ_0 : if CYCLES = 0 generate 
        output <= input; 
    end generate; 
   
    U_DELAY : for i in 0 to CYCLES-1 generate 
        d(0) <= input; 
        output <= d(CYCLES);

        U_REG : entity work.reg
        generic map(CYCLES)
        port map(
            clk => clk, 
            rst => rst, 
            en  => en, 
            input => d(i), 
            output => d(i+1)
        );
    end generate;
end architecture STR; 