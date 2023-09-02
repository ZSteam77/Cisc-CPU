LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.assembly_instructions.ALL;
USE work.ALL;

ENTITY ROM IS
    PORT (
        IR_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        Z_flag, N_flag, O_flag, reset, clk : IN STD_LOGIC;
        upc : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        offset_in : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        ab_invert, IE, Write, ReadA, ReadB, OE, read_nwrite, address_out, dout_out : OUT STD_LOGIC;
        Bypass : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ROM;

ARCHITECTURE ROM_arc OF ROM IS
    SIGNAL Z, N, O : STD_LOGIC := '0';
BEGIN
    WITH IR_in SELECT offset_out <=
        STD_LOGIC_VECTOR(resize(signed(offset_in(8 DOWNTO 0)), offset_out'length)) WHEN iLDI,
        STD_LOGIC_VECTOR(resize(signed(offset_in), offset_out'length)) WHEN OTHERS;
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            op <= "000";
            IE <= '0';
            OE <= '0';
            ReadA <= '0';
            ReadB <= '0';
            Bypass <= "00";
            Write <= '0';
            address_out <= '0';
            dout_out <= '0';
            read_nwrite <= '1';
            ab_invert <= '0';
        ELSIF (rising_edge(clk)) THEN
            CASE upc IS
                WHEN "11" =>
                    CASE IR_in IS
                        WHEN iST =>
                            op <= "110";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            read_nwrite <= '1';
                            ab_invert <= '0';
                        WHEN OTHERS =>
                            op <= "110";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            read_nwrite <= '1';
                            ab_invert <= '0';
                    END CASE;
                WHEN "00" =>
                    CASE IR_in IS
                        WHEN iAdd =>
                            op <= "000"; --add
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iSUB =>
                            op <= "001"; --sub
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iAND =>
                            op <= "010"; --and
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iOR =>
                            op <= "011"; --or
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iXOR =>
                            op <= "100"; --xor
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iNOT =>
                            op <= "111"; --not
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iMOV =>
                            op <= "110"; --mov
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '1';
                            ReadA <= '1';
                            ReadB <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iNOP =>
                            op <= "000";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                        WHEN iLD =>
                            op <= "110"; --LD
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            ReadA <= '1';
                            ReadB <= '0';
                            OE <= '1';
                            address_out <= '1';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iST =>
                            op <= "110"; --ST
                            IE <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            ReadA <= '0';
                            ReadB <= '1';
                            OE <= '1';
                            dout_out <= '1';
                            address_out <= '0';
                            ab_invert <= '1';
                            --read_nwrite <= '1';
                        WHEN iLDI =>
                            op <= "110"; --LDI
                            IE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "01";
                            Write <= '1'; -- '1';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iNU =>
                            op <= "000";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iBRZ =>
                            IF (Z = '1') THEN
                                Bypass <= "10";
                                Write <= '1';
                                op <= "000";
                                ReadB <= '0';
                                IE <= '0';
                                address_out <= '0';
                                dout_out <= '0';
                                --read_nwrite <= '1';
                            ELSE
                                Bypass <= "10";
                                Write <= '1';
                                op <= "101";
                                ReadB <= '0';
                                IE <= '0';
                                address_out <= '0';
                                dout_out <= '0';
                                --read_nwrite <= '1';
                            END IF;
                        WHEN iBRN =>
                            IF (N = '1') THEN
                                Bypass <= "10";
                                Write <= '1';
                                op <= "000";
                                ReadB <= '0';
                                IE <= '0';
                                address_out <= '0';
                                dout_out <= '0';
                                --read_nwrite <= '1';
                            ELSE
                                Bypass <= "10";
                                Write <= '1';
                                op <= "101";
                                ReadB <= '0';
                                IE <= '0';
                                address_out <= '0';
                                dout_out <= '0';
                                --read_nwrite <= '1';
                            END IF;
                        WHEN iBRO =>
                            IF (O = '1') THEN
                                Bypass <= "10";
                                Write <= '1';
                                op <= "000";
                                ReadB <= '0';
                                IE <= '0';
                                address_out <= '0';
                                dout_out <= '0';
                                --read_nwrite <= '1';
                            ELSE
                                Bypass <= "10";
                                Write <= '1';
                                op <= "101";
                                ReadB <= '0';
                                IE <= '0';
                                address_out <= '0';
                                dout_out <= '0';
                                --read_nwrite <= '1';
                            END IF;
                        WHEN iBRA =>
                            Bypass <= "10";
                            Write <= '1';
                            op <= "000";
                            ReadB <= '0';
                            IE <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN OTHERS =>
                            op <= "000";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                    END CASE;
                WHEN "01" =>
                    CASE IR_in IS
                        WHEN iAdd | iSUB | iAND | iOR | iXOR | iNOT | iMOV =>
                            Bypass <= "10";
                            Write <= '1';
                            op <= "101";
                            ReadA <= '1';
                            ReadB <= '0';
                            IE <= '0';
                            OE <= '1';
                            address_out <= '1';
                            dout_out <= '0';
                            ab_invert <= '0';
                            --read_nwrite <= '1';
                        WHEN iNOP | iLD | iST | iLDI | iNU =>
                            Bypass <= "10";
                            Write <= '1';
                            op <= "101";
                            ReadA <= '1';
                            ReadB <= '0';
                            IE <= '0';
                            OE <= '1';
                            address_out <= '1';
                            dout_out <= '0';
                            ab_invert <= '0';
                        WHEN iBRZ | iBRN | iBRO | iBRA =>
                            Bypass <= "10";
                            Write <= '0';
                            op <= "110"; --alu_out = a = pc
                            ReadA <= '1';
                            ReadB <= '0';
                            IE <= '0';
                            OE <= '1';
                            address_out <= '1';
                            dout_out <= '0';
                            ab_invert <= '0';
                            --read_nwrite <= '1';
                        WHEN OTHERS =>
                            op <= "000";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            ab_invert <= '0';
                            --read_nwrite <= '1';
                    END CASE;
                WHEN "10" =>
                    CASE IR_in IS
                        WHEN iLD =>
                            Bypass <= "00";
                            Write <= '1';
                            op <= "110";
                            ReadA <= '0';
                            ReadB <= '0';
                            IE <= '1';
                            OE <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                        WHEN iST =>
                            Bypass <= "00";
                            Write <= '0';
                            op <= "110";
                            ReadA <= '1';
                            ReadB <= '0';
                            IE <= '0';
                            OE <= '1';
                            address_out <= '1';
                            dout_out <= '0';
                            read_nwrite <= '0';
                            --read_nwrite <= '1';
                        WHEN OTHERS =>
                            op <= "000";
                            IE <= '0';
                            OE <= '0';
                            ReadA <= '0';
                            ReadB <= '0';
                            Bypass <= "00";
                            Write <= '0';
                            address_out <= '0';
                            dout_out <= '0';
                            --read_nwrite <= '1';
                    END CASE;
                WHEN OTHERS =>
            END CASE;
        END IF;
    END PROCESS;
    PROCESS (clk)
      begin
        if falling_edge(clk) then
            CASE upc IS
                WHEN "01" =>
                    CASE IR_in IS
                        WHEN iAdd | iSUB | iAND | iOR | iXOR | iNOT | iMOV =>
                            Z <= Z_flag;
                            N <= N_flag;
                            O <= O_flag;
                        WHEN others =>
                    end case;
                WHEN others =>
            end case;
        end if;
    end process;
END ROM_arc;