library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;

-- This sorts a sequence of WIDTh using a bitonic sort
-- The WIDTH must be a power of 2

entity bitonic_sort_TB is
end;

architecture behavioral of bitonic_sort_TB is
  -- must be a power of 2
  constant WIDTH : natural := 2;
  constant BIT_WIDTH : natural := 64;
  constant COMPARISON_WIDTH : natural := 16;
  signal ap_clk : std_logic := '0';
  signal ap_start : std_logic := '0';
  signal ap_done : std_logic;
  signal sort_inputs : sort_inputs_t(WIDTH-1 downto 0)(BIT_WIDTH-1 downto 0) := (others => (others => '0'));
  signal sort_outputs : sort_inputs_t(WIDTH-1 downto 0)(BIT_WIDTH-1 downto 0);

begin
  DUV:  entity work.bitonic_sort
  generic map (
    SORT_WIDTH => WIDTH,
    BIT_WIDTH => BIT_WIDTH,
    COMPARISON_WIDTH => COMPARISON_WIDTH,
    PLUS => true
  )
  port map (
    ap_clk => ap_clk,
    ap_start => ap_start,
    ap_done => ap_done,
    sort_inputs => sort_inputs,
    sort_outputs => sort_outputs
  );

  ap_clk <= not ap_clk after 0.5 ns;

  stimuli: process
  begin
    -- sort_inputs(15) <= 64ux"2e";
    -- sort_inputs(14) <= 64ux"2ae";
    -- sort_inputs(13) <= 64ux"35";
    -- sort_inputs(12) <= 64ux"0";
    -- sort_inputs(11) <= 64ux"345";
    -- sort_inputs(10) <= 64ux"34";
    -- sort_inputs(9) <= 64ux"1";
    -- sort_inputs(8) <= 64ux"3f";
    -- sort_inputs(7) <= 64ux"26";
    -- sort_inputs(6) <= 64ux"62";
    -- sort_inputs(5) <= 64ux"772";
    -- sort_inputs(4) <= 64ux"4462";
    -- sort_inputs(3) <= 64ux"9";
    -- sort_inputs(2) <= 64ux"23";
    sort_inputs(1) <= 64ux"25";
    sort_inputs(0) <= 64ux"4";
    wait until ap_start'event and ap_start = '1';
    wait until ap_start'event and ap_start = '0';
    wait until ap_start'event and ap_start = '1';
    wait until ap_start'event and ap_start = '0';
    -- sort_inputs(15) <= 64ux"12e";
    -- sort_inputs(14) <= 64ux"12ae";
    -- sort_inputs(13) <= 64ux"135";
    -- sort_inputs(12) <= 64ux"0";
    -- sort_inputs(11) <= 64ux"3453";
    -- sort_inputs(10) <= 64ux"34e";
    -- sort_inputs(9) <= 64ux"1";
    -- sort_inputs(8) <= 64ux"3fa";
    -- sort_inputs(7) <= 64ux"2a6";
    -- sort_inputs(6) <= 64ux"6a2";
    -- sort_inputs(5) <= 64ux"77a2";
    -- sort_inputs(4) <= 64ux"446a2";  --note, upper 4 is not used in comparison
    -- sort_inputs(3) <= 64ux"a9";
    -- sort_inputs(2) <= 64ux"2a3";
    sort_inputs(1) <= 64ux"9";
    sort_inputs(0) <= 64ux"27";
    wait until ap_start'event and ap_start = '1';
    wait until ap_start'event and ap_start = '0';
    --wait until ap_clk = '1';
    sort_inputs(1) <= 64ux"94";
    sort_inputs(0) <= 64ux"573";
    wait for 150 ns;
    std.env.finish;
  end process stimuli;

  ii2: process (ap_clk)
  begin
    if rising_edge(ap_clk) then
      ap_start <= not ap_start;
    end if;
  end process ii2;

  checker:  process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      report "New clock";
      for i in WIDTH-1 downto 0 loop
        report "done: " & to_string(ap_done) & ", sort_outputs " & to_string(i) & ": " & to_hstring(sort_outputs(i));
      end loop;
    end if;
  end process checker; 

end architecture behavioral;
