LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

entity datapath is
    Generic (N,M:integer);
    port (in_put, Offset : in std_logic_vector(N-1 downto 0);
        WAddr, RA, RB : in std_logic_vector(M-1 downto 0);
        op_in : in std_logic_vector(2 DOWNTO 0);
        Bypass : IN std_logic_vector(1 downto 0);
        ab_invert, IE, reset, Write, ReadA, ReadB, OE, clk: in std_logic;
        out_put : out std_logic_vector(N-1 downto 0);
        Z_Flag, N_Flag, O_Flag : out std_logic);
end datapath;

architecture dp of datapath is
    component alu is
        Generic (N:integer);
        port (op: in std_logic_vector(2 downto 0);
        a, b: in std_logic_vector(N-1 downto 0);
        sum: out std_logic_vector(N-1 downto 0);
        z_flag, n_flag, o_flag: out std_logic);
        --PORT( op_in: IN std_logic_vector(2 DOWNTO 0);
        --a_in,b_in: IN std_logic_vector(N-1 DOWNTO 0);
        --sum_out: OUT std_logic_vector(N-1 DOWNTO 0);
        --z,n_out,o: OUT std_logic);
    end component alu;
    component Register_File is
        Generic (N,M:integer);
        port( WD : in std_logic_vector(N-1 downto 0);
        WADDR, RA, RB : std_logic_vector(M-1 downto 0);
        reset, write_in, clk, ReadA, ReadB : in std_logic;
        QA, QB : out std_logic_vector(N-1 downto 0));
    end component Register_File;
    signal QA, QB, sum_out, WD, alu_ain, alu_bin : std_logic_vector(N-1 DOWNTO 0);
    signal RA_in, RB_in, WAddr_in : std_logic_vector(M-1 downto 0);
    signal ReadA_in, in_write : std_logic;
    signal selectA : std_logic_vector(1 downto 0);
    begin
        selectA <= Bypass(0) & ab_invert;
        with IE select WD <=
            sum_out when '0',
            in_put when others;
        with selectA select alu_ain <=
            Offset when "10",
            QA when "00",
            QB when "01",
            Offset when "11",
            (others => 'X') when others;
        with Bypass(1) select alu_bin <=
            Offset when '1',
            QB when '0',
            (others => 'X') when others;
        with Bypass(1) select RA_in <=
            (others => '1') when '1',
            RA when '0',
            (others => 'X') when others;
        with Bypass(1) select ReadA_in <=
            '1' when '1',
            ReadA when '0',
            'X' when others;
        with Bypass(1) select WAddr_in <=
            (others => '1') when '1',
            WAddr when '0',
            (others => 'X') when others;
        with Bypass(1) select in_write <=
            '1' when '1',
            Write when '0',
            'X' when others;

        u1 : alu
            generic map (N=>N)
            --port map(op_in => op_in, a_in => alu_ain, b_in => alu_ain, sum_out => sum_out, z => Z_Flag,n_out => N_Flag, o => O_Flag);
            port map (op => op_in, a => alu_ain, b => alu_bin, sum => sum_out, z_flag => Z_Flag, n_flag => N_Flag, o_flag => O_Flag);
        u2 : Register_File
            generic map (N=>N,M=>M)
            port map (WD => WD, WADDR => WAddr_in, RA => RA_in, RB => RB, reset => reset, write_in => in_write, clk => clk, ReadA => ReadA_in,
            ReadB => ReadB, QA => QA, QB => QB);
        with OE select out_put <=
            (others => 'Z') when '0',
            sum_out when others;
    end dp;