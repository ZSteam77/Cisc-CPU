library verilog;
use verilog.vl_types.all;
entity memory_altsyncram1 is
    port(
        address_a       : in     vl_logic_vector(7 downto 0);
        address_b       : in     vl_logic_vector(7 downto 0);
        clock0          : in     vl_logic;
        clock1          : in     vl_logic;
        data_a          : in     vl_logic_vector(15 downto 0);
        data_b          : in     vl_logic_vector(15 downto 0);
        q_a             : out    vl_logic_vector(15 downto 0);
        q_b             : out    vl_logic_vector(15 downto 0);
        wren_a          : in     vl_logic;
        wren_b          : in     vl_logic
    );
end memory_altsyncram1;
