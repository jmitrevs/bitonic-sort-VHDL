
library IEEE;
use IEEE.std_logic_1164.all;

package bitonic_sort_pkg is
  type sort_inputs_t is array(natural range<>) of std_logic_vector;
  type start_idx_t is array(natural range<>) of integer;

  -- make reuse factor no larger than the sort width
  function regularize_rf (rf : positive; sort_width : positive) return positive;

  function start_indices (rf : positive; block_size : positive) return start_idx_t;
  
end bitonic_sort_pkg;

package body bitonic_sort_pkg is

  function regularize_rf ( rf : positive; sort_width : positive) return positive is
  begin
    if rf <= sort_width then
      return rf;
    else
      return sort_width;
    end if;
  end function regularize_rf;

  function start_indices( rf : positive; block_size : positive) return start_idx_t is
    variable retval : start_idx_t(rf-1 downto 0);
  begin
    for i in retval'range loop
      retval(i) := retval(i) * block_size;
    end loop;
    return retval;
  end function start_indices;
end package body bitonic_sort_pkg;
