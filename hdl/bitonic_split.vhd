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
    II2 : boolean := True   -- False means II=1
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
  -- make the reuse factor (1 or 2)
  constant RF : positive := calculate_rf(II2, SORT_WIDTH);
  constant BLOCK_FACTOR : positive := SORT_WIDTH / RF;
  -- if RF=1, en_chain(1) = 0 always
  signal en_chain : std_logic_vector(1 downto 0) := (others => '0');
begin
  -- this is either the low end (RF = 2) or all of it (RF = 1)
  gen_comps_0 : for i in BLOCK_FACTOR-1 downto 0 generate
    comp_proc_0 : process (ap_clk)
      variable temp_a : std_logic_vector(BIT_WIDTH-1 downto 0);
      variable temp_b : std_logic_vector(BIT_WIDTH-1 downto 0);
    begin
      if rising_edge(ap_clk) then
        if (en_chain(0) = '1') then
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
      end if;
    end process comp_proc_0;
  end generate gen_comps_0;

  -- this is only if (RF = 2)
  cond_comps: if RF > 1 generate
    gen_comps_1 : for i in SORT_WIDTH-1 downto SORT_WIDTH-BLOCK_FACTOR generate
      comp_proc_1 : process (ap_clk)
        variable temp_a : std_logic_vector(BIT_WIDTH-1 downto 0);
        variable temp_b : std_logic_vector(BIT_WIDTH-1 downto 0);
      begin
        if rising_edge(ap_clk) then
          if en_chain(0) = '1' then
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
        end if;
      end process comp_proc_1;
    end generate gen_comps_1;
  end generate cond_comps;

  
  ap_done <= en_chain(RF-1);
  done_proc: process(ap_clk)
  begin
    if rising_edge(ap_clk) then
      if RF /= 1 then
        en_chain(RF-1 downto 1) <= en_chain(RF-2 downto 0);
      end if;
      en_chain(0) <= ap_start;
    end if;
  end process done_proc;
  
end architecture behav;
