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

-- This version is II=2 to save area

entity bitonic_merge_ii2 is
  generic (
    SORT_WIDTH : positive;
    BIT_WIDTH : positive;
    COMPARISON_WIDTH: positive;
    PLUS : in std_logic
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

architecture rtl of bitonic_merge_ii2 is
  constant SORT_WIDTH_2 : natural := SORT_WIDTH/2;
begin
  -- recursive generate
  recursive_gen: if SORT_WIDTH_2 > 0 generate
      signal intermed_a : sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermed_b : sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermed_b_latched : sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermed : sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermediate_enable : std_logic_vector(1 downto 0) := "00";
      signal out_part : sort_inputs_shr_t(1 downto 0)(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal done_part : std_logic_vector(1 downto 0) := "00";
    begin

      intermed <= intermed_a when intermediate_enable(0) = '1' else intermed_b_latched;

      split_inst: entity work.bitonic_split_ii2
      generic map (
        SORT_WIDTH => SORT_WIDTH,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => intermediate_enable(0),
        in_a => in_a,
        in_b => in_b,
        out_a => intermed_a,
        out_b => intermed_b
      );

      intermed_proc : process (ap_clk)
      begin
        if rising_edge(ap_clk) then
          intermediate_enable(1) <= intermediate_enable(0);
          intermed_b_latched <= intermed_b;
        end if;
      end process intermed_proc;

      seq_inst: entity work.bitonic_merge
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH
      )
      port map (
        ap_clk => ap_clk,
        ap_start => or intermediate_enable,
        ap_done => done_part(0),
        in_a => intermed(SORT_WIDTH-1 downto SORT_WIDTH_2),
        in_b => intermed(SORT_WIDTH_2-1 downto 0),
        out_a => out_part(0)(SORT_WIDTH-1 downto SORT_WIDTH_2),
        out_b => out_part(0)(SORT_WIDTH_2-1 downto 0),
        plus => PLUS
      );

      ap_done <= done_part(1);
      out_a <= out_part(1);
      out_b <= out_part(0);

      shift_out_proc : process (ap_clk)
      begin
        if rising_edge(ap_clk) then
          out_part(1) <= out_part(0);
          done_part(1) <= done_part(0) and not done_part(1);
        end if;
      end process shift_out_proc;
  
    else generate
      -- the recursion end case
      split_inst: entity work.bitonic_split
      generic map (
        SORT_WIDTH => 1,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => ap_done,
        in_a => in_a,
        in_b => in_b,
        out_a => out_a,
        out_b => out_b,
        plus => PLUS
      );
    end generate recursive_gen; 
  

end architecture rtl;
