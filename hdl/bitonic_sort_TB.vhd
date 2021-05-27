library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sort_output_apxpack_pkg.all;

-- This sorts a sequence of WIDTh using a bitonic sort
-- The WIDTH must be a power of 2

entity bitonic_sort_TB is
end;

architecture behavioral of bitonic_sort_TB is
  -- must be a power of 2
  constant WIDTH : natural := 4;
  signal ap_clk : std_logic := '0';
  signal ap_start : std_logic := '0';
  signal ap_done : std_logic;
  signal sort_inputs : sort_inputs_t(0 to WIDTH-1) := (others => (others => '0'));
  signal sort_outputs : sort_inputs_t(0 to WIDTH-1);

begin
  DUV:  entity work.bitonic_sort
  generic map (
    WIDTH => WIDTH
  )
  port map (
    ap_clk => ap_clk,
    ap_start => ap_start,
    ap_done => ap_done,
    sort_inputs => sort_inputs,
    sort_outputs => sort_outputs
  );

  ap_clk <= not ap_clk after 4.167 ns;

  stimuli: process
  begin
    sort_inputs(0) <= 64ux"2";
    sort_inputs(1) <= 64ux"23";
    sort_inputs(2) <= 64ux"25";
    sort_inputs(3) <= 64ux"4";
    ap_start <= '1';
    wait until ap_clk = '1';
    sort_inputs(0) <= 64ux"3";
    sort_inputs(1) <= 64ux"7";
    sort_inputs(2) <= 64ux"25";
    sort_inputs(3) <= 64ux"9";
    ap_start <= '1';
    wait until ap_clk = '1';
    wait for 50 ns;
    std.env.finish;
  end process stimuli;

  checker:  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      report "New clock";
      for i in 0 to WIDTH-1 loop
        report "done: " & to_string(ap_done) & ", sort_outputs " & to_string(i) & ": " & to_hstring(sort_outputs(i));
      end loop;
    end if;
  end process checker; 

end architecture behavioral;
