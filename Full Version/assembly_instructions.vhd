LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

package assembly_instructions is
    subtype instruction is std_logic_vector(15 downto 0);
    subtype opcode is std_logic_vector(3 downto 0);
    subtype reg_code is std_logic_vector(2 downto 0);
    subtype immediate is std_logic_vector(8 downto 0);

    constant Tail3 : std_logic_vector(2 downto 0) := "000";
    --constant nu3 : std_logic_vector(2 downto 0) := "000";


    constant iADD : opcode := "0000";
    constant iSUB : opcode := "0001";
    constant iAND : opcode := "0010";
    constant iOR : opcode := "0011";
    constant iXOR : opcode := "0100";
    constant iNOT : opcode := "0101";
    constant imov : opcode := "0110";
    constant iNOP : opcode := "0111";
    constant iLD : opcode := "1000";
    constant iST : opcode := "1001";
    constant iLDI : opcode := "1010";
    constant iNU : opcode := "1011";
    constant iBRZ : opcode := "1100";
    constant iBRN : opcode := "1101";
    constant iBRO : opcode := "1110";
    constant iBRA : opcode := "1111";

    constant R0 : reg_code := "000";
    constant R1 : reg_code := "001";
    constant R2 : reg_code := "010";
    constant R3 : reg_code := "011";
    constant R4 : reg_code := "100";
    constant R5 : reg_code := "101";
    constant R6 : reg_code := "110";
    constant R7 : reg_code := "111";
end package assembly_instructions;