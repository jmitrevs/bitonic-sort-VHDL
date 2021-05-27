
library IEEE;
use IEEE.std_logic_1164.all;

package sort_output_apxpack_pkg is
  subtype entry_t is std_logic_vector(63 downto 0);
  type sort_inputs_t is array(natural range<>) of entry_t;
end sort_output_apxpack_pkg;
