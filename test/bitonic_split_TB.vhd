library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;

-- This sorts a sequence of WIDTh using a bitonic sort
-- The WIDTH must be a power of 2

entity bitonic_split_TB is
end;

architecture behavioral of bitonic_split_TB is
  -- must be a power of 2
  constant WIDTH : natural := 2;
  constant BIT_WIDTH : natural := 64;
  constant COMPARISON_WIDTH : natural := 16;
  signal ap_clk : std_logic := '0';
  signal ap_start : std_logic := '0';
  signal ap_done : std_logic;
  signal in_a : sort_inputs_t(WIDTH-1 downto 0)(BIT_WIDTH-1 downto 0) := (others => (others => '0'));
  signal in_b : sort_inputs_t(WIDTH-1 downto 0)(BIT_WIDTH-1 downto 0) := (others => (others => '0'));
  signal out_a : sort_inputs_t(WIDTH-1 downto 0)(BIT_WIDTH-1 downto 0);
  signal out_b : sort_inputs_t(WIDTH-1 downto 0)(BIT_WIDTH-1 downto 0);

begin
  DUV:  entity work.bitonic_split
  generic map (
    SORT_WIDTH => WIDTH,
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
    plus => '1'
  );

  ap_clk <= not ap_clk after 4.167 ns;

  stimuli: process
  begin
    in_a(1) <= 64ux"2";
    in_a(0) <= 64ux"23";
    in_b(1) <= 64ux"25";
    in_b(0) <= 64ux"4";
    wait for 50 ns;
    std.env.finish;
  end process stimuli;

  checker:  process(ap_clk)
    begin
      if rising_edge(ap_clk) then
        report "New clock";
        for i in WIDTH-1 downto 0 loop
          report "out_a " & to_string(i) & ": " & to_hstring(out_a(i));
        end loop;
        for i in WIDTH-1 downto 0 loop
          report "out_b " & to_string(i) & ": " & to_hstring(out_b(i));
        end loop;
      end if;
    end process checker; 
end architecture behavioral;
