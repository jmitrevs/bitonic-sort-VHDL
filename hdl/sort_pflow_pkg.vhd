
library IEEE;
use IEEE.std_logic_1164.all;

package sort_pflow_pkg is
  constant NUM_INPUTS : positive := 15;
  constant NUM_INPUTS_PW2 : positive := 16;
  constant NUM_OUTPUTS : positive := 10;
  constant NUM_BITS : positive := 80;
  constant COMP_BITS : positive := 16;
  constant SORT_DELAY : positive := 13;
end sort_pflow_pkg;
