LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL; -- defines "+", "-" and "*" for std_logic_vectors to be unsigned
USE ieee.std_logic_arith.ALL; -- defines conv_std_logic_vector and conv_integer
USE work.all;
USE std.TEXTIO.ALL;
LIBRARY modelsim_lib;
USE modelsim_lib.util.ALL; -- defines the spy_signal procedure
USE work.assembly_instructions.ALL; -- defines all assembly instruction codes used by the processor

entity test_fsm is
end test_fsm;

ARCHITECTURE test_cpu_advanced OF test_fsm IS
	COMPONENT cpu
		generic(N:integer;
				M:integer);
		port(clk,reset:IN std_logic;
			Din:IN std_logic_vector(N-1 downto 0);
			address:OUT std_logic_vector(N-1 downto 0);
			Dout:OUT std_logic_vector(N-1 downto 0);
			RW:OUT std_logic);
	END COMPONENT;
	CONSTANT N : INTEGER := 16;
	CONSTANT M : INTEGER := 3;
	SIGNAL clk, reset : STD_LOGIC := '0';
	SIGNAL Din : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL address : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL Dout, mem_Dout : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL RW : STD_LOGIC;
	SIGNAL rden, wren : STD_LOGIC;

	-- global test procedures
	PROCEDURE wait_for(N : INTEGER) IS
	BEGIN
		FOR i IN 1 TO N LOOP
			WAIT ON clk UNTIL clk = '1';
		END LOOP;
	END wait_for;
	PROCEDURE i(SIGNAL instr : OUT instruction; op : opcode;wr_reg, rd_reg1, rd_reg2 : reg_code) IS
	BEGIN
		Instr <= op & wr_reg & rd_reg1 & rd_reg2 & "000";
		wait_for(4);
	END i;
	PROCEDURE i(SIGNAL instr : OUT instruction; op : opcode;wr_reg : reg_code;imm : immediate) IS
	BEGIN
		Instr <= op & wr_reg & imm;
		wait_for(4);
	END i;
	-- branch instructions
	PROCEDURE i(SIGNAL instr : OUT instruction; op : opcode; immediate : INTEGER) IS
	BEGIN
		Instr <= op & conv_std_logic_vector(immediate, 12);
		wait_for(4);
	END i;

	-- test_signals in Modelsim (i.e., spy_signals)
	SIGNAL t_upc : STD_LOGIC_VECTOR(1 DOWNTO 0);
	TYPE rf_type IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL t_rf_mem : rf_type;
	SIGNAL t_z, t_n, t_o : STD_LOGIC;
BEGIN
	-- Clock and reset generation
	clk <= NOT(clk) AFTER 10 ns;
	reset <= '0', '1' AFTER 5 ns, '0' AFTER 16 ns;

	DUT : CPU
		Generic Map (N => N, M=>M)
		port map(clk => clk, reset => reset, Din => Din,
			address => address,	Dout => Dout, RW => RW);

	spy_process : -- Spy process connects signals inside the hierarchy to signals in the test_bench (simulator dependent - only works in Modelsim)
	PROCESS
	BEGIN
		init_signal_spy("/test_fsm/dut/upc", "/t_upc", 1);
		init_signal_spy("/test_fsm/dut/dp/u2/regist", "/t_rf_mem", 1);
		--init_signal_spy("/test/dut/z_flag","/t_z",1);
		--init_signal_spy("/test/dut/n_flag","/t_n",1);
		--init_signal_spy("/test/dut/o_flag","/t_o",1);
		init_signal_spy("/test_fsm/dut/r1/Z", "/t_z", 1);
		init_signal_spy("/test_fsm/dut/r1/N", "/t_n", 1);
		init_signal_spy("/test_fsm/dut/r1/O", "/t_o", 1);
		WAIT;
	END PROCESS spy_process;
	
	rden <= RW;
	wren <= NOT(RW);

	test_all_instructions :
	PROCESS
		PROCEDURE test_ST(SIGNAL instr : OUT instruction; wr_reg, rd_reg : INTEGER) IS
		BEGIN
			Instr <= iST & Tail3 & conv_std_logic_vector(wr_reg, 3) & conv_std_logic_vector(rd_reg, 3) & Tail3;
			wait_for(2);
			WAIT FOR 1 ps;
			ASSERT(Dout = t_rf_mem(7-rd_Reg)) REPORT "iST: Dout has the wrong value" SEVERITY failure;
			ASSERT(t_uPC = "10") REPORT "iST: Dout is set in the wrong clock cycle" SEVERITY failure;
			wait_for(2); -- skip PC+1
			WAIT FOR 1 ps;
			ASSERT(Address = t_rf_mem(7-wr_reg)) REPORT "iST: Address has the wrong value" SEVERITY failure;
			ASSERT(wren = '1') REPORT "iST: RW has the wrong value" SEVERITY failure;
			--wait_for(1); -- FI
		END test_ST;
		PROCEDURE test_LD(SIGNAL instr : OUT instruction; wr_reg, rd_reg : INTEGER) IS
		BEGIN
			Instr <= iLD & Tail3 & conv_std_logic_vector(wr_reg, 3) & conv_std_logic_vector(rd_reg, 3) & Tail3;
			wait_for(2);
			WAIT FOR 2 ns;
			ASSERT(Address = t_rf_mem(7-wr_Reg)) REPORT "iLD: Address has the wrong value" SEVERITY failure;
			ASSERT(t_uPC = "10") REPORT "iLD: Address is set in the wrong clock cycle" SEVERITY failure;
			ASSERT(rden = '1') REPORT "iLD: RW has the wrong value" SEVERITY failure;
			wait_for(1);
			Instr <= "1010101010101010"; -- fake memory response
			wait_for(1); -- skip PC+1
			WAIT FOR 5 ns;
			ASSERT(t_rf_mem(7-rd_reg) = "1010101010101010") REPORT "iLD: Loaded Data has the wrong value" SEVERITY failure;
			--wait_for(1); -- FI
		END test_LD;
	BEGIN
		WAIT UNTIL reset = '1';
		WAIT UNTIL reset = '0';
		ASSERT(t_uPC = "00") REPORT "Reset does not work" SEVERITY failure;
		ASSERT(address = "0000000000000000") REPORT "Memory Address reset does not work" SEVERITY failure;
		ASSERT(false) REPORT "test_reset OK" SEVERITY note;
		i(Din, iLDI, R0, "000000001");
		ASSERT(t_rf_mem(0) = "000000000000001") REPORT "LDI does not work" SEVERITY failure;
		ASSERT(address = "0000000000000001") REPORT "R7 - PC Address increment does not work";
		REPORT "LDI works OK";
		i(Din, iLDI, R1, "100000001");
		ASSERT(t_rf_mem(6) = "1111111100000001") REPORT "LDI sign extension does not work" SEVERITY failure;
		REPORT "LDI sign extension works OK";

		i(Din, iADD, R2, R1, R0);
		ASSERT(t_rf_mem(5) = "1111111100000010") REPORT "ADD does not work" SEVERITY failure;
		REPORT "ADD works OK";
		i(Din, iSUB, R3, R2, R1);
		ASSERT(t_rf_mem(4) = "0000000000000001") REPORT "SUB does not work" SEVERITY failure;
		REPORT "SUB works OK";
		test_ST(Din, 1, 0);
		REPORT "iST works OK";

		i(Din, iNOT, R4, R3, R0);
		ASSERT(t_rf_mem(3) = "1111111111111110") REPORT "NOT does not work" SEVERITY failure;
		REPORT "NOT works OK";
		i(Din, iOR, R5, R4, R3);
		ASSERT(t_rf_mem(2) = "1111111111111111") REPORT "OR does not work" SEVERITY failure;
		REPORT "OR works OK";
		i(Din, iAND, R6, R5, R2);
		ASSERT(t_rf_mem(1) = "1111111100000010") REPORT "AND does not work" SEVERITY failure;
		REPORT "AND works OK";
		i(Din, iXOR, R6, R6, R5);
		ASSERT(t_rf_mem(1) = "0000000011111101") REPORT "XOR does not work" SEVERITY failure;
		REPORT "XOR works OK";
		test_LD(Din, 4, 0);
		REPORT "iLD works OK";

		-- At this point, Z=0, N=0, O=0
		i(Din, iBRZ, -15);
		ASSERT(t_rf_mem(0) = "0000000000001011") REPORT "Z=0:BRZ does not work" SEVERITY failure;
		REPORT "BRZ with Z=0 works OK";
		i(Din, iBRN, 15);
		ASSERT(t_rf_mem(0) = "0000000000001100") REPORT "N=0:BRN does not work" SEVERITY failure;
		REPORT "BRN with N=0 works OK";
		i(Din, iBRO, -15);
		ASSERT(t_rf_mem(0) = "0000000000001101") REPORT "O=0:BRO does not work" SEVERITY failure;
		REPORT "BRO with O=0 works OK";

		-- Create Z=1
		i(Din, iXOR, R0, R0, R0);
		ASSERT(t_z = '1') REPORT "XOR Setting Z=1 does not work" SEVERITY failure;
		REPORT "XOR Setting Z=1 works";
		i(Din, iBRZ, -15);
		ASSERT(t_rf_mem(0) = "1111111111111111") REPORT "Z=1:BRZ does not work" SEVERITY failure;
		REPORT "BRZ with negative offset works OK";
		i(Din, iBRZ, +15);
		ASSERT(t_rf_mem(0) = "0000000000001110") REPORT "Z=1:BRZ does not work" SEVERITY failure;
		REPORT "BRZ with posititve offset works OK";

		-- Create Z=0, N=1
		i(Din, iXOR, R0, R5, R0);
		ASSERT(t_n = '1') REPORT "Setting N=1 does not work" SEVERITY failure;
		REPORT "XOR Setting N=1 works";
		i(Din, iBRN, -15);
		ASSERT(t_rf_mem(0) = "0000000000000000") REPORT "N=1:BRN does not work" SEVERITY failure;
		REPORT "BRN with negative address works OK";
		i(Din, iBRN, +15);
		ASSERT(t_rf_mem(0) = "000000000001111") REPORT "N=1:BRN does not work" SEVERITY failure;
		REPORT "BRN with positive address works OK";

		-- Create O=1
		i(Din, iLDI, R0, "011111111");
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		i(Din, iADD, R0, R0, R0);
		ASSERT(t_o = '1') REPORT "ADD setting O=1 does not work";
		REPORT "ADD setting O=1 works OK";
		i(Din, iBRO, -15);
		ASSERT(t_rf_mem(0) = "0000000000001001") REPORT "O=1:BRO does not work" SEVERITY failure;
		REPORT "BRO with negative address works OK";
		i(Din, iBRO, 15);
		ASSERT(t_rf_mem(0) = "0000000000011000") REPORT "O=1:BRO does not work" SEVERITY failure;
		REPORT "BRO with positive address works OK";

		i(Din, iBRA, -15);
		ASSERT(t_rf_mem(0) = "0000000000001001") REPORT "BRA does not work" SEVERITY failure;
		REPORT "BRA with negative address works OK";
		i(Din, iBRA, 57);
		ASSERT(t_rf_mem(0) = "0000000001000010") REPORT "BRA does not work" SEVERITY failure;
		REPORT "BRA with positive address works OK";
		WAIT ON clk UNTIL clk = '1';
		REPORT "CPU passes all tests.";
		ASSERT(false) REPORT "Ending Simulation." SEVERITY failure;
	END PROCESS;

END test_cpu_advanced;