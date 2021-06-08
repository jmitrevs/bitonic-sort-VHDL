library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;

entity bitonic_split is
  generic (
    SORT_WIDTH : positive;
    BIT_WIDTH : positive;
    COMPARISON_WIDTH: positive;
    PLUS : boolean;
    REUSE_FACTOR : positive := 2   -- Also the II, must be power of 2, <= SORT_WIDTH
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    in_a : in sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    in_b : in sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    out_a : out sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    out_b : out sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0)
  );
end;

architecture behav of bitonic_split is
  -- make the RF be no greater than the SORT_WIDTH
  constant RF : positive := regularize_rf(REUSE_FACTOR, SORT_WIDTH);
  constant BLOCK_FACTOR : positive := SORT_WIDTH / RF;
  constant START_IDX : start_idx_t(RF-1 downto 0) := start_indices(RF, BLOCK_FACTOR);
  signal en_chain : std_logic_vector(RF-1 downto 0) := (others => '0');
begin
  gen_comps : for i in BLOCK_FACTOR-1 downto 0 generate
    comp_proc : process (ap_clk)
      variable temp_a : std_logic_vector(BIT_WIDTH-1 downto 0);
      variable temp_b : std_logic_vector(BIT_WIDTH-1 downto 0);
    begin
      if rising_edge(ap_clk) then
        if signed(in_a(i)(COMPARISON_WIDTH-1 downto 0)) <= signed(in_b(i)(COMPARISON_WIDTH-1 downto 0)) then
          temp_a := in_a(i);
          temp_b := in_b(i);
        else
          temp_a := in_b(i);
          temp_b := in_a(i);
        end if;
        if PLUS then
          out_a(i) <= temp_a;
          out_b(i) <= temp_b;
        else
          out_a(i) <= temp_b;
          out_b(i) <= temp_a;
        end if;
      end if;
    end process comp_proc;
  end generate gen_comps;
   
  ap_done <= en_chain(0);
  done_proc: process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if RF /= 1 then
        en_chain(RF-2 downto 0) <= en_chain(RF-1 downto 1);
      end if;
      en_chain(RF-1) <= ap_start;
    end if;
  end process done_proc;
end architecture behav;
