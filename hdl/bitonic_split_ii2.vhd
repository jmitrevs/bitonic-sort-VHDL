library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;

-- This version is II=2 to save area.

entity bitonic_split_ii2 is
  generic (
    SORT_WIDTH : positive;
    BIT_WIDTH : positive;
    COMPARISON_WIDTH: positive
  );
  port (
    ap_clk : in std_logic;
    ap_start : in std_logic;  -- goes down in second clock cycle
    ap_done : out std_logic;
    in_a : in sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    in_b : in sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    out_a : out sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    out_b : out sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    plus : std_logic
  );
end;

architecture behav of bitonic_split_ii2 is
  constant SORT_WIDTH_2 : natural := SORT_WIDTH/2;
begin

  gen_special : if SORT_WIDTH_2 > 0 generate
    -- this part is II2
    -- THIS BRANCH SHOULD ALWAYS BE TAKEN; REMOVING ELSE CLAUSE

    signal en_out_shr : std_logic_vector(1 downto 0) := "00";
    signal out_a_shift : sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
    signal out_b_shift : sort_inputs_t(SORT_WIDTH - 1 downto 0)(BIT_WIDTH - 1 downto 0);
  begin

    out_a <= out_a_shift;
    out_b <= out_b_shift;

    ap_done <= en_out_shr(1);

    shift_out_proc : process (ap_clk)
    begin
      if rising_edge(ap_clk) then
        out_a_shift(SORT_WIDTH-1 downto SORT_WIDTH_2) <= out_a_shift(SORT_WIDTH_2-1 downto 0);
        out_b_shift(SORT_WIDTH-1 downto SORT_WIDTH_2) <= out_b_shift(SORT_WIDTH_2-1 downto 0);
        en_out_shr(0) <= ap_start;
        en_out_shr(1) <= en_out_shr(0);
      end if;
    end process shift_out_proc;

    gen_comps : for i in SORT_WIDTH_2-1 downto 0 generate
      comp_proc : process (ap_clk)
        variable temp_a : std_logic_vector(BIT_WIDTH-1 downto 0);
        variable temp_b : std_logic_vector(BIT_WIDTH-1 downto 0);
        variable sel_a : std_logic_vector(BIT_WIDTH-1 downto 0);
        variable sel_b : std_logic_vector(BIT_WIDTH-1 downto 0);
      begin

        if rising_edge(ap_clk) then
          if ap_start = '1' then
            sel_a := in_a(SORT_WIDTH_2 + i);
            sel_b := in_b(SORT_WIDTH_2 + i);
          else
            sel_a := in_a(i);
            sel_b := in_b(i);
          end if;

          if signed(sel_a(COMPARISON_WIDTH-1 downto 0)) <= signed(sel_b(COMPARISON_WIDTH-1 downto 0)) then
            temp_a := sel_a;
            temp_b := sel_b;
          else
            temp_a := sel_b;
            temp_b := sel_a;
          end if;
          if plus = '1' then
            out_a_shift(i) <= temp_a;
            out_b_shift(i) <= temp_b;
          else
            out_a_shift(i) <= temp_b;
            out_b_shift(i) <= temp_a;
          end if;
        end if;
      end process comp_proc;
    end generate gen_comps;
  end generate gen_special;

end architecture behav;
