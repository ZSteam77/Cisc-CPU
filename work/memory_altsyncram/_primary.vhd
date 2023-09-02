library verilog;
use verilog.vl_types.all;
entity memory_altsyncram is
    port(
        address_a       : in     vl_logic_vector(7 downto 0);
        clock0          : in     vl_logic;
        data_a          : in     vl_logic_vector(15 downto 0);
        q_a             : out    vl_logic_vector(15 downto 0);
        wren_a          : in     vl_logic
    );
end memory_altsyncram;
