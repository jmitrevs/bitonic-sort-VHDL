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

-- This version is II=2 to save area

entity bitonic_sort_ii2 is
  generic (
    SORT_WIDTH : positive;  -- must be a power of 2
    BIT_WIDTH : positive;
    COMPARISON_WIDTH: positive := 16
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    ap_ready : out std_logic;
    sort_inputs : in sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
    sort_outputs : out sort_inputs_t(SORT_WIDTH-1 downto 0)(BIT_WIDTH - 1 downto 0);
    -- The sort order. True means highest is at index 0.
    plus : in std_logic := '1'
  );
end;

architecture rtl of bitonic_sort_ii2 is
  constant SORT_WIDTH_2 : natural := SORT_WIDTH/2;
  signal ready : std_logic := '1';
begin
  ap_ready <= ready;

  -- recursive generate
  recursive_gen: if SORT_WIDTH_2 > 0 generate
      signal inputs : sort_inputs_shr_t(1 downto 0)(SORT_WIDTH_2-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal inputs_plus : std_logic_vector(1 downto 0) := "00";
      signal intermediate_shr : sort_inputs_shr_t(1 downto 0)(SORT_WIDTH_2-1 downto 0)(BIT_WIDTH - 1 downto 0);
      signal intermediate_enable : std_logic_vector(1 downto 0);
      signal intermediate_first : std_logic := '0';  -- the first of two
      signal outputs : sort_inputs_shr_t(1 downto 0)(SORT_WIDTH_2-1 downto 0)(BIT_WIDTH - 1 downto 0);
    begin

      input_proc : process (ap_clk)
      begin
        if rising_edge(ap_clk) then
          if ap_start = '1' and ready = '1' then
            ready <= '0';
            inputs(1) <= sort_inputs(SORT_WIDTH-1 downto SORT_WIDTH_2);
            inputs(0) <= sort_inputs(SORT_WIDTH_2-1 downto 0);
            inputs_plus <= "10";
          else
            ready <= '1';
            inputs(1) <= inputs(0);
            inputs_plus(1) <= inputs_plus(0);
          end if;
        end if;
      end process input_proc;

      sort_inst: entity work.bitonic_sort
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH
      )
      port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => intermediate_enable(0),
        sort_inputs => inputs(1),
        sort_outputs => intermediate_shr(0),
        plus => inputs_plus(1)
      );

      intermed_proc: process(ap_clk)
      begin
        if rising_edge(ap_clk) then
          intermediate_first <= intermediate_enable(0) and not intermediate_first;
          intermediate_enable(1) <= intermediate_enable(0);
        end if;
      end process intermed_proc;

      merge_inst: entity work.bitonic_merge_ii2
      generic map (
        SORT_WIDTH => SORT_WIDTH_2,
        BIT_WIDTH => BIT_WIDTH,
        COMPARISON_WIDTH => COMPARISON_WIDTH
      )
      port map (
        ap_clk => ap_clk,
        ap_start => intermediate_enable(1) and not intermediate_first,
        ap_done => ap_done,
        in_a => intermediate_shr(0),
        in_b => intermediate_shr(1),
        out_a => sort_outputs(SORT_WIDTH-1 downto SORT_WIDTH_2),
        out_b => sort_outputs(SORT_WIDTH_2-1 downto 0),
        plus => plus
      );

    else generate
      -- the recursion end case, SORT_WIDTH = 1, do nothing
      ap_done <= ap_start;
      sort_outputs <= sort_inputs;
    end generate recursive_gen; 
  

end architecture rtl;
