library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sort_output_apxpack_pkg.all;

-- This sorts a sequence of WIDTh using a bitonic sort
-- The WIDTH must be a power of 2

entity bitonic_sort is
  generic (
    WIDTH: natural;
    -- the generic below is only meant for the recursive calls,
    -- not for the user to use directly
    PLUS: boolean := true
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    sort_inputs : in sort_inputs_t(WIDTH-1 downto 0);
    sort_outputs : out sort_inputs_t(WIDTH-1 downto 0)
  );
end;

architecture rtl of bitonic_sort is
  constant WIDTH_2 : natural := WIDTH/2;
begin
  -- recursive generate
  recursive_gen: if WIDTH_2 > 0 generate
      signal intermed_a : sort_inputs_t(WIDTH_2-1 downto 0);
      signal intermed_b : sort_inputs_t(WIDTH_2-1 downto 0);
      signal intermediate_enable : std_logic;
    begin
      sortp_inst: entity work.bitonic_sort
      generic map (
        WIDTH => WIDTH_2,
        PLUS => true
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => intermediate_enable,
        sort_inputs => sort_inputs(WIDTH-1 downto WIDTH_2),
        sort_outputs => intermed_a
      );

      sortm_inst: entity work.bitonic_sort
      generic map (
        WIDTH => WIDTH_2,
        PLUS => false
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => open,
        sort_inputs => sort_inputs(WIDTH_2-1 downto 0),
        sort_outputs => intermed_b
      );

      merge_inst: entity work.bitonic_merge
      generic map (
        WIDTH => WIDTH_2,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => intermediate_enable,
        ap_done => ap_done,
        in_a => intermed_a,
        in_b => intermed_b,
        out_a => sort_outputs(WIDTH-1 downto WIDTH_2),
        out_b => sort_outputs(WIDTH_2-1 downto 0)
      );

    else generate
      -- the recursion end case, WIDTH = 1, do nothing
      ap_done <= ap_start;
      sort_outputs <= sort_inputs;
    end generate recursive_gen; 
  

end architecture rtl;
