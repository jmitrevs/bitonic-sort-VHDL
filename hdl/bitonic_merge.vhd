library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sort_output_apxpack_pkg.all;

-- This function merges (sorts) a bitonic sequence,
-- The bitonic sequence is actually already split in two
-- so the a parts and the b parts are the two half-sequences
-- and the WIDTH is the size of that half-sequence.
entity bitonic_merge is
  generic (
    WIDTH: natural;
    PLUS: boolean
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    in_a : in sort_inputs_t(WIDTH-1 downto 0);
    in_b : in sort_inputs_t(WIDTH-1 downto 0);
    out_a : out sort_inputs_t(WIDTH-1 downto 0);
    out_b : out sort_inputs_t(WIDTH-1 downto 0)
  );
end;

architecture rtl of bitonic_merge is
  constant WIDTH_2 : natural := WIDTH/2;
begin
  -- recursive generate
  recursive_gen: if WIDTH_2 > 0 generate
      signal intermed_a : sort_inputs_t(WIDTH-1 downto 0);
      signal intermed_b : sort_inputs_t(WIDTH-1 downto 0);
      signal intermediate_enable : std_logic;
    begin
      split_inst: entity work.bitonic_split
      generic map (
        WIDTH => WIDTH,
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
        WIDTH => WIDTH_2,
        PLUS => PLUS
      )
      port map (
        ap_clk => ap_clk,
        ap_start => intermediate_enable,
        ap_done => ap_done,
        in_a => intermed_a(WIDTH-1 downto WIDTH_2),
        in_b => intermed_a(WIDTH_2-1 downto 0),
        out_a => out_a(WIDTH-1 downto WIDTH_2),
        out_b => out_a(WIDTH_2-1 downto 0)
      );

      seqb_inst: entity work.bitonic_merge
        generic map (
          WIDTH => WIDTH_2,
          PLUS => PLUS
        )
      port map (
        ap_clk => ap_clk,
        ap_start => intermediate_enable,
        ap_done => open,
        in_a => intermed_b(WIDTH-1 downto WIDTH_2),
        in_b => intermed_b(WIDTH_2-1 downto 0),
        out_a => out_b(WIDTH-1 downto WIDTH_2),
        out_b => out_b(WIDTH_2-1 downto 0)
      );
    else generate
      -- the recursion end case
      split_inst: entity work.bitonic_split
      generic map (
        WIDTH => 1,
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
