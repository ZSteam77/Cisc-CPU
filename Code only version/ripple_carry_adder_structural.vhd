LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE work.all;

ENTITY ripple_carry_adder IS
  Generic (N: integer);
  PORT (a, b: IN std_logic_vector(N-1 downto 0);
        cin: IN std_logic;
        sum: OUT std_logic_vector(N-1 downto 0);
        cout: OUT std_logic);
END ripple_carry_adder;

ARCHITECTURE structural OF ripple_carry_adder IS
  COMPONENT full_adder IS
    PORT (a, b, cin: IN std_logic;
          sum, cout: OUT std_logic);
  END COMPONENT;
  SIGNAL carries: std_logic_vector(N-2 downto 0);
  
BEGIN
  gen_outer: FOR i IN 0 TO N-1 GENERATE
    gen_inner_LSB: IF (i = 0) GENERATE
      FA_LSB: full_adder 
      PORT MAP( a => a(i), b => b(i), cin => (cin), sum => sum(i), cout=> carries(i));
    END GENERATE gen_inner_LSB;
    gen_inner_middle: IF ((i > 0) and (i < N-1)) GENERATE
      FA_middle: full_adder 
      PORT MAP( a => a(i), b => b(i), cin => carries(i-1), sum => sum(i), cout=> carries(i));
    END GENERATE gen_inner_middle;
    gen_inner_MSB: IF (i = N-1) GENERATE
      FA_MSB: full_adder 
      PORT MAP( a => a(i), b => b(i), cin => (carries(i-1)), sum => sum(i), cout=> cout);
    END GENERATE gen_inner_MSB;
  END GENERATE gen_outer;
END structural;

        