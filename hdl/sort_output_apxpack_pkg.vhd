
library IEEE;
use IEEE.std_logic_1164.all;

package sort_output_apxpack_pkg is
  constant NUM_INPUTS : natural := 47;
  constant NUM_INPUTS_PW2 : natural := 64;
  constant NUM_OUTPUTS : natural := 18;
  subtype entry_t is std_logic_vector(63 downto 0);
  type sort_inputs_t is array(natural range<>) of entry_t;
end sort_output_apxpack_pkg;
