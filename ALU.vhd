library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity ALU is
  generic (N: integer);
  port (op: in std_logic_vector(2 downto 0);
        a, b: in std_logic_vector(N-1 downto 0);
        sum: out std_logic_vector(N-1 downto 0);
        z_flag, n_flag, o_flag: out std_logic);
end ALU;

architecture behavioral of ALU is
  component ripple_carry_adder is
    generic(N: integer);
    port (a, b: in std_logic_vector(N-1 downto 0);
          cin: in std_logic;
          sum: out std_logic_vector(N-1 downto 0);
          cout: out std_logic);
  end component;

  signal rca_a, rca_b: std_logic_vector(N-1 downto 0);
	signal rca_cin: std_logic;
  signal rca_sum: std_logic_vector(N-1 downto 0);
  signal rca_cout: std_logic;
  signal y: std_logic_vector(N-1 downto 0);
  constant zeros: std_logic_vector(N-1 downto 0) := (others => '0');
begin
  RCA: ripple_carry_adder generic map(N => N) port map(a => rca_a, b => rca_b, cin => rca_cin, sum => rca_sum, cout => rca_cout);

  rca_a <= a;
  
  rca_b <= 
    b when (op = "000") else
    not b when (op = "001") else
    zeros;
  
  rca_cin <= '0' when (op = "000") else '1';
  
  with op select y <= 
    rca_sum when "000",
    rca_sum when "001",
    a and b when "010",
    a or b  when "011",
    a xor b when "100",
    rca_sum when "101",
    a       when "110",
    not a when "111",
    (others => '0') when others;
    --b       when others; --"111" 
  
  sum <= y;
  z_flag <= '1' when (y = zeros) else '0';
  n_flag <= y(N-1);
  o_flag <= (rca_a(N-1) xnor rca_b(N-1)) and (rca_a(N-1) xor rca_sum(N-1)) when (op = "000" or op = "001") else '0';
  
end behavioral;


        


