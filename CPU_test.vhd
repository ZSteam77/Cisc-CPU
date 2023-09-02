library IEEE;
use work.all;
use ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;
LIBRARY modelsim_lib;
USE modelsim_lib.util.ALL; -- defines the spy_signal procedure
USE work.assembly_instructions.ALL; -- defines all assembly instruction codes used by the processor


entity test_cpu is end test_cpu;

architecture sim of test_cpu is
  
component CPU is 
port(
	CLK, RESET : in std_logic;
	PIO : out std_logic_vector(15 downto 0)
);
end component;
  
signal CLK : std_logic := '0';
signal RESET : std_logic := '1';

signal PIO : std_logic_vector(15 downto 0);
signal test_dinfsm : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal test_address_FSM : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal test_IR_FSM : STD_LOGIC_VECTOR(15 DOWNTO 0);
TYPE rf_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL t_rf_mem : rf_type;
begin
  
comp : CPU port map(CLK => CLK, RESET => RESET, PIO => PIO);
  clk <= not clk after 5 ns;
  reset <= '0' after 48 ns;
  
  spy_process : -- Spy process connects signals inside the hierarchy to signals in the test_bench (simulator dependent - only works in Modelsim)
	PROCESS
	BEGIN
		init_signal_spy("/test_cpu/comp/Din_FSM", "/test_dinfsm", 1);
		init_signal_spy("/test_cpu/comp/address_FSM", "/test_address_FSM", 1);
		init_signal_spy("/test_cpu/comp/u1/dp/u2/regist", "/t_rf_mem", 1);
		init_signal_spy("/test_cpu/comp/u1/IR", "/test_IR_FSM", 1);
		WAIT;
	END PROCESS spy_process;
end sim;