
library IEEE;
use IEEE.std_logic_1164.all;

package sort_output_apxpack_pkg is
  constant NUM_INPUTS : positive := 47;
  constant NUM_INPUTS_PW2 : positive := 64;
  constant NUM_OUTPUTS : positive := 18;
  constant NUM_BITS : positive := 55;  -- though the input is 64-bit, only 55 are actually nonzero
  constant COMP_BITS : positive := 14;
  constant SORT_DELAY : positive := 17;  -- estimate, not confirmed
end sort_output_apxpack_pkg;
