library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;

-- This function merges (sorts) a sequence of numbers (plus payload),
-- The SORT_WIDTH is the number of entries to sort, and must be a
-- power of two. BIT_WIDTH is the number of bits used to represent the numbers,
-- plus any payload data, and COMPARISON_WIDTH (default 16) is the number of which
-- are used for the sort comparison. COMPARISON_WITH-1 downto 0 are the bits
-- used for the comparisons. PLUS indictates the sort direction of the sort.

entity bitonic_sort is
  generic (
    SORT_WIDTH : positive;  -- must be a power of 2
    BIT_WIDTH : positive;
    COMPARISON_WIDTH: positive := 16;
   -- The sort order. True means highest is at index 0.
    PLUS: boolean := true
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    sort_inputs : in sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
    sort_outputs : out sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0)
  );
end;

architecture rtl of bitonic_sort is
  constant SORT_WIDTH_2 : natural := SORT_WIDTH/2;
begin
  -- recursive generate
  recursive_gen: if SORT_WIDTH_2 > 0 generate
      signal intermed_a : sort_inputs_t(SORT_WIDTH_2-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermed_b : sort_inputs_t(SORT_WIDTH_2-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermediate_enable : std_logic;
    begin
      sortp_inst: entity work.bitonic_sort
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => true
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => intermediate_enable,
        sort_inputs => sort_inputs(SORT_WIDTH-1 downto SORT_WIDTH_2),
        sort_outputs => intermed_a
      );

      sortm_inst: entity work.bitonic_sort
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => false
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => open,
        sort_inputs => sort_inputs(SORT_WIDTH_2-1 downto 0),
        sort_outputs => intermed_b
      );

      merge_inst: entity work.bitonic_merge
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => intermediate_enable,
        ap_done => ap_done,
        in_a => intermed_a,
        in_b => intermed_b,
        out_a => sort_outputs(SORT_WIDTH-1 downto SORT_WIDTH_2),
        out_b => sort_outputs(SORT_WIDTH_2-1 downto 0)
      );

    else generate
      -- the recursion end case, SORT_WIDTH = 1, do nothing
      ap_done <= ap_start;
      sort_outputs <= sort_inputs;
    end generate recursive_gen; 
  

end architecture rtl;
