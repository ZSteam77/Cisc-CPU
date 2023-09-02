LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE work.all;

ENTITY full_adder IS
  PORT(a, b, cin : IN std_logic;
       sum, cout : OUT std_logic);
END full_adder;

ARCHITECTURE dataFlow OF full_adder IS begin
  sum <= a xor b xor cin;
  cout <= (a and b) or (cin and (a xor b));

END dataFlow;
