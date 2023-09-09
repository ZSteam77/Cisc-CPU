LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.assembly_instructions.ALL;
USE work.ALL;

ENTITY FSM IS
    GENERIC (
        N : INTEGER := 16;
        M : INTEGER := 3);
    PORT (
        clk, reset : IN STD_LOGIC;
        Din : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        address : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        Dout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        RW : OUT STD_LOGIC);
END FSM;

ARCHITECTURE fsm_arc OF FSM IS
    COMPONENT ROM
        PORT (
            IR_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            Z_flag, N_flag, O_flag, reset, clk : IN STD_LOGIC;
            upc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            offset_in : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            ab_invert, IE, Write, ReadA, ReadB, OE, read_nwrite, address_out, dout_out : OUT STD_LOGIC;
            Bypass : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
    END COMPONENT;

    COMPONENT datapath
        GENERIC (N, M : INTEGER);
        PORT (
            in_put, Offset : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            WAddr, RA, RB : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
            op_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Bypass : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            ab_invert, IE, reset, Write, ReadA, ReadB, OE, clk : IN STD_LOGIC;
            out_put : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            Z_Flag, N_Flag, O_Flag : OUT STD_LOGIC);
    END COMPONENT;
    SIGNAL IR, Offset, dp_out : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL op : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL upc, Bypass : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL ab_invert, IE, Write, ReadA, ReadB, OE, read_nwrite, address_out, dout_out, Z_flag, N_flag, O_flag : STD_LOGIC := '0';
BEGIN
   with upc select IR <=
    Din when "00",
    IR when others;
  
    r1 : ROM
    PORT MAP(
        IR_in => IR(15 DOWNTO 12), Z_flag => Z_flag, N_flag => N_flag, O_flag => O_flag, reset => reset, clk => clk, upc => upc, offset_in => IR(11 DOWNTO 0),
        ab_invert => ab_invert, IE => IE, Write => Write, ReadA => ReadA, ReadB => ReadB, OE => OE, read_nwrite => read_nwrite, address_out => address_out, dout_out => dout_out,
        Bypass => Bypass, offset_out => Offset, op => op);

    dp : datapath
    GENERIC MAP(N => N, M => M)
    PORT MAP(
        in_put => Din, Offset => Offset, WAddr => IR(11 DOWNTO 9), RA => IR(8 DOWNTO 6), RB => IR(5 DOWNTO 3), op_in => op, Bypass => Bypass,
        ab_invert => ab_invert, IE => IE, reset => reset, Write => Write, ReadA => ReadA, ReadB => ReadB, OE => OE, clk => clk, out_put => dp_out,
        Z_flag => Z_flag, N_flag => N_flag, O_flag => O_flag);
    
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            upc <= "00";
        ELSIF (rising_edge(clk)) THEN
          IF(to_integer(unsigned(Din)) = 0) then
          else
            IF (upc = "11") THEN
                upc <= "00";
            ELSE
                upc <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(upc)) + 1, 2));
            END IF;
          END IF;
        END IF;
    END PROCESS;
    Process (clk, reset)
      begin
        IF (reset = '1') THEN
            address <= (others => '0');
            Dout <= (others => '0');
            RW <= '1';
        ELSIF (falling_edge(clk)) then
          RW <= read_nwrite;
          IF (dout_out = '1') THEN
            Dout <= dp_out;
          ELSE
          END IF;
          IF (address_out = '1') THEN
            address <= dp_out;
          ELSE
          END IF;
      end if;
    end process;
END fsm_arc;