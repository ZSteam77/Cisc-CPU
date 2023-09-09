LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.assembly_instructions.ALL;
USE work.ALL;

entity CPU is
    GENERIC (
        N : INTEGER := 16;
        M : INTEGER := 3);
    port(reset : in std_logic;
        clk : in std_logic;
        --clock : in std_logic;
        PIO : out STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
end CPU;

architecture cpu_arc of CPU is
    COMPONENT FSM
        GENERIC (
            N : INTEGER;
            M : INTEGER);
        PORT (
            clk, reset : IN STD_LOGIC;
            Din : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            address : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            Dout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            RW : OUT STD_LOGIC);
    end component FSM;

    COMPONENT GPIO
        PORT (
            clk, reset, rw : IN STD_LOGIC;
            Din, address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    end component GPIO;

    COMPONENT ram IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
    END COMPONENT ram;
    
  COMPONENT clk_divide is
      port (clk_in : in std_logic;
          clk_out : out std_logic);
  END COMPONENT clk_divide;
    
    signal Dout_FSM, Din_FSM, address_FSM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal address_mem : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal RW, wren : STD_LOGIC;
    --signal clk : STD_LOGIC;
begin
    address_mem <= address_FSM(7 downto 0);
    wren <= not(RW);
    u1 : FSM
        generic map(N => N, M=> M)
        port map(
            clk => clk, reset => reset, Din => Din_FSM, Dout => Dout_FSM, address => address_FSM, RW => RW
        );
    u2 : GPIO
        port map(
            clk => clk, reset => reset, Din => Dout_FSM, Dout => PIO, address => address_FSM, RW => RW
        );
    u3 : ram
        port map(
            address => address_mem, clock => clk, data => Dout_FSM,  wren => wren, rden => RW, q => Din_FSM
        );
    --u4 : clk_divide
      --port map (clk_in => clock, clk_out => clk);
    
end cpu_arc;