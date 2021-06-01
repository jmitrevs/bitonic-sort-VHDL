library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;

-- This function merges (sorts) a bitonic sequence,
-- The bitonic sequence is actually already split in two
-- so the a parts and the b parts are the two half-sequences
-- and the SORT_WIDTH is the size of that half-sequence.
-- BIT_WIDTH is the number of bits used to represent the numbers,
-- plus any payload data, and COMPARISON_WIDTH is the number
-- of bits used for the sort comparison. COMPARISON_WITH-1
-- downto 0 is used for the comparisons.
entity bitonic_merge is
  generic (
    SORT_WIDTH : positive;
    BIT_WIDTH : positive;
    COMPARISON_WIDTH: positive;
    PLUS: boolean
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    in_a : in sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
    in_b : in sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
    out_a : out sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
    out_b : out sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0)
  );
end;

architecture rtl of bitonic_merge is
  constant SORT_WIDTH_2 : natural := SORT_WIDTH/2;
begin
  -- recursive generate
  recursive_gen: if SORT_WIDTH_2 > 0 generate
      signal intermed_a : sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermed_b : sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermediate_enable : std_logic;
    begin
      split_inst: entity work.bitonic_split
      generic map (
        SORT_WIDTH => SORT_WIDTH,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => intermediate_enable,
        in_a => in_a,
        in_b => in_b,
        out_a => intermed_a,
        out_b => intermed_b
      );

      seqa_inst: entity work.bitonic_merge
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
        in_a => intermed_a(SORT_WIDTH-1 downto SORT_WIDTH_2),
        in_b => intermed_a(SORT_WIDTH_2-1 downto 0),
        out_a => out_a(SORT_WIDTH-1 downto SORT_WIDTH_2),
        out_b => out_a(SORT_WIDTH_2-1 downto 0)
      );

      seqb_inst: entity work.bitonic_merge
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => intermediate_enable,
        ap_done => open,
        in_a => intermed_b(SORT_WIDTH-1 downto SORT_WIDTH_2),
        in_b => intermed_b(SORT_WIDTH_2-1 downto 0),
        out_a => out_b(SORT_WIDTH-1 downto SORT_WIDTH_2),
        out_b => out_b(SORT_WIDTH_2-1 downto 0)
      );
    else generate
      -- the recursion end case
      split_inst: entity work.bitonic_split
      generic map (
        SORT_WIDTH => 1,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => ap_done,
        in_a => in_a,
        in_b => in_b,
        out_a => out_a,
        out_b => out_b
      );
    end generate recursive_gen; 
  

end architecture rtl;
