LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.assembly_instructions.ALL;
USE work.ALL;

ENTITY GPIO IS
    PORT (
        clk, reset, rw : IN STD_LOGIC;
        Din, address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END GPIO;

ARCHITECTURE GPIO_behav OF GPIO IS
    SIGNAL content : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            Dout <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (address = x"F000" AND rw = '1') THEN
                content <= Din;
                Dout <= Din;
            ELSIF (address = x"F000") THEN
                content <= Din;
            ELSIF (rw = '1') THEN
                Dout <= content;
            ELSE
            END IF;
        END IF;
    END PROCESS;
END GPIO_behav;