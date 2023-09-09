LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

entity clk_divide is
    port (clk_in : in std_logic;
        clk_out : out std_logic);
end clk_divide;

architecture clk_divider of clk_divide is
    signal clock : std_logic:='0';
    begin
        process(clk_in)
        variable count : integer := 0;
        begin
        if rising_edge(clk_in) then
          count := count + 1;
          if (count = 50000) then
            count := 0;
            clock <= not clock;
          end if;
        end if;
        end process;
    clk_out <= clock;
end clk_divider;