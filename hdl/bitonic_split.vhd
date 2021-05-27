library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.sort_output_apxpack_pkg.all;

entity bitonic_split is
  generic (
    WIDTH : positive;
    PLUS : boolean
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;
    ap_done : out std_logic;
    in_a : in sort_inputs_t(WIDTH - 1 downto 0);
    in_b : in sort_inputs_t(WIDTH - 1 downto 0);
    out_a : out sort_inputs_t(WIDTH - 1 downto 0);
    out_b : out sort_inputs_t(WIDTH - 1 downto 0)
  );
end;

architecture behav of bitonic_split is
  signal en_out : std_logic := '0';
begin
  gen_comps : for i in WIDTH-1 downto 0 generate
    comp_proc : process (ap_clk)
      variable temp_a : entry_t;
      variable temp_b : entry_t;
    begin
      if rising_edge(ap_clk) then
        if signed(in_a(i)(15 downto 0)) <= signed(in_b(i)(15 downto 0)) then
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
  
  ap_done <= en_out;
  done_proc: process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      en_out <= ap_start;
    end if;
  end process done_proc;

end architecture behav;
