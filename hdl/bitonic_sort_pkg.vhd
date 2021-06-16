
library IEEE;
use IEEE.std_logic_1164.all;

package bitonic_sort_pkg is
  type sort_inputs_t is array(natural range<>) of std_logic_vector;
  type sort_inputs_shr_t is array(natural range<>) of sort_inputs_t;
end bitonic_sort_pkg;
