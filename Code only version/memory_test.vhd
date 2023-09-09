LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.assembly_instructions.ALL;
USE work.ALL;
LIBRARY modelsim_lib;
USE modelsim_lib.util.ALL; -- defines the spy_signal procedure
USE work.assembly_instructions.ALL; -- defines all assembly instruction codes used by the processor

entity fake_memory is
end fake_memory;

ARCHITECTURE fake OF fake_memory IS
    type program is array(0 to 255) of std_logic_vector(15 downto 0);
    signal RAM:program:=(
    (iLDI & R5 & B"1_0000_0000"),
    (iADD & R5 & R5 & R5 & Tail3),
    (iADD & R5 & R5 & R5 & Tail3),
    (iADD & R5 & R5 & R5 & Tail3),
    (iADD & R5 & R5 & R5 & Tail3),
    (iLDI & R6 & B"0_0010_0000"),
    (iLDI & R3 & B"0_0000_0011"),
    (iST  & Tail3 & R6 & R3 & Tail3),
    (iLDI & R1 & B"0_0000_0001"),
    (iLDI & R0 & B"0_0000_1110"),
    (iMOV & R2 & R0 & Tail3 & Tail3),
    (iADD & R2 & R2 & R1 & Tail3),
    (iSUB & R0 & R0 & R0 & Tail3),
    (iBRZ & X"003"),
    (iNOP & Tail3 & Tail3 & Tail3 & Tail3),
    (iBRA & X"0FC"),
    (iST & Tail3 & R6 & R2 & Tail3),
    (iST & Tail3 & R5 & R2 & Tail3),
    (iBRA & X"000"),
    (iNOP & Tail3 & Tail3 & Tail3 & Tail3),
    (iNOP & Tail3 & Tail3 & Tail3 & Tail3),
    others=>(iNOP & R0 & R0 & R0 & Tail3));

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
    signal Dout_FSM, Din_FSM, address_FSM, PIO : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal address_mem : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal RW : STD_LOGIC;
    signal clk, reset : STD_LOGIC := '0';
    TYPE rf_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL t_rf_mem : rf_type;
begin
    clk <= not clk after 5ns;
    address_mem <= address_FSM(7 downto 0);
    u1 : FSM
    generic map(N => 16, M=> 3)
    port map(
        clk => clk, reset => reset, Din => Din_FSM, Dout => Dout_FSM, address => address_FSM, RW => RW
    );
    u2 : GPIO
    port map(
        clk => clk, reset => reset, Din => Dout_FSM, Dout => PIO, address => address_FSM, RW => RW
    );

    spy_process : -- Spy process connects signals inside the hierarchy to signals in the test_bench (simulator dependent - only works in Modelsim)
	PROCESS
	BEGIN
		init_signal_spy("/fake_memory/u1/dp/u2/regist", "/t_rf_mem", 1);
		WAIT;
	END PROCESS spy_process;

    testbegin:
    process
        variable i : integer := 0;
    begin
        wait until rising_edge(clk);
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        while (i < 255) loop
            Din_FSM <= RAM(i);
            i := i + 1;
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
    end process;
end fake;