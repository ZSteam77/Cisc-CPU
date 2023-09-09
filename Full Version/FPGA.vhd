LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

entity FPGA is
    generic(N:integer:=3;M:integer:=2);
    port (in_put : in std_logic_vector(N-1 downto 0);
        WAddr, RA, RB : in std_logic_vector(M-1 downto 0);
        op_in : in std_logic_vector(2 DOWNTO 0);
        IE, reset, Write, ReadA, ReadB, OE, clock_board: in std_logic;
        out_put : out std_logic_vector(N-1 downto 0);
        Z_Flag, N_Flag, O_Flag : out std_logic);
end FPGA;

architecture board of FPGA is
  component datapath is
    Generic (N,M:integer);
    port (in_put : in std_logic_vector(N-1 downto 0);
        WAddr, RA, RB : in std_logic_vector(M-1 downto 0);
        op_in : in std_logic_vector(2 DOWNTO 0);
        IE, reset, Write, ReadA, ReadB, OE, clk: in std_logic;
        out_put : out std_logic_vector(N-1 downto 0);
        Z_Flag, N_Flag, O_Flag : out std_logic);
  end component datapath;
  component clk_divide is
      port (clk_in : in std_logic;
      clk_out : out std_logic);
  end component clk_divide;
  signal clk:std_logic;
  begin
    c1: clk_divide
      port map (clk_in => clock_board, clk_out => clk);
    d1: datapath
      generic map (N => N, M=>M)
      port map (in_put => in_put, WAddr => WAddr, RA => RA, RB => RB, op_in => op_in, IE => IE,
       reset => reset, Write => Write, ReadA => ReadA, ReadB => ReadB, OE => OE, clk => clk, out_put => out_put,
       Z_Flag => Z_Flag, N_Flag => N_Flag, O_Flag => O_Flag);
end board;
  