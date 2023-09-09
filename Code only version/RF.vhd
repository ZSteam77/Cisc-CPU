LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

entity Register_File is
    Generic (N,M:integer);
    port( WD : in std_logic_vector(N-1 downto 0);
    WADDR, RA, RB : std_logic_vector(M-1 downto 0);
    reset, write_in, clk, ReadA,ReadB : in std_logic;
    QA, QB : out std_logic_vector(N-1 downto 0));
end Register_File;

architecture RF of Register_File is
    TYPE reg IS ARRAY (2**M-1 DOWNTO 0) OF std_logic_vector(N-1 downto 0);
    signal regist : reg;
    begin
    with ReadA select QA <=
      regist(to_integer(unsigned(RA))) when '1',
      (others => '0') when others;
    with ReadB select QB <=
      regist(to_integer(unsigned(RB))) when '1',
      (others => '0') when others;
    process (clk,reset)
    begin
        if (reset = '1') then
            regist <= (others => (others => '0'));
        elsif falling_edge(clk) then
            if (write_in = '1') then
                regist(to_integer(unsigned(WADDR))) <= WD;
            end if;
        end if;
    end process;
end RF;