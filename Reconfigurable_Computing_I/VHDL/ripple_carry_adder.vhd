library ieee;
use ieee.std_logic_1164.all; 

entity full_adder is 
port(
    x, y, cin : in std_logic; 
    s, cout   : out std_logic
    );
end entity full_adder;

architecture default_arch of full_adder is
begin
    s <= x xor y xor cin; 
    cout <= (x and y) or (cin and (x xor y));
end architecture default_arch;

---------------------------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all;

entity ripple_carry_adder is
    generic(
        WIDTH : positive := 9
    );
    port(
        x, y : in std_logic_vector(WIDTH-1 downto 0);
        cin  : in std_logic;
        sum  : out std_logic_vector(WIDTH-1 downto 0);
        cout : out std_logic
    );
    end entity ripple_carry_adder; 


    architecture default_arch of ripple_carry_adder is 
        signal carry : std_logic_vector(WIDTH downto 0); -- we want one extra carry 
    begin 
        carry(0) <= cin; 
        RIPPLE_CARRY : for i in 0 to WIDTH-1 generate
            U_FA : entity work.full_adder port map(
                x => x(i) ,
                y => y(i), 
                cin => carry(i),
                s => sum(i),
                cout => carry(i + 1) 
            );
            end generate; 
            cout <= carry(WIDTH);
    end default_arch; 
