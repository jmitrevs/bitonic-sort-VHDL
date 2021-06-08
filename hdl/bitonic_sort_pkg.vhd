
library IEEE;
use IEEE.std_logic_1164.all;

package bitonic_sort_pkg is
  type sort_inputs_t is array(natural range<>) of std_logic_vector;

  function calculate_rf (ii2 : boolean; sort_width : positive) return positive;

end bitonic_sort_pkg;

package body bitonic_sort_pkg is

  function calculate_rf ( ii2 : boolean; sort_width : positive) return positive is
  begin
    if sort_width <= 2 then
      return 1;
    elsif ii2 then
      return 2;
    else
      return 1;
    end if;
  end function calculate_rf;

end package body bitonic_sort_pkg;