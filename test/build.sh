#/usr/bin/env sh

ghdl -a --std=08 ../hdl/sort_output_apxpack_pkg.vhd
ghdl -a --std=08 ../hdl/bitonic_split.vhd 
ghdl -a --std=08 ../hdl/bitonic_merge.vhd 
ghdl -a --std=08 ../hdl/bitonic_sort.vhd 
ghdl -a --std=08 bitonic_split_TB.vhd 
ghdl -a --std=08 bitonic_sort_TB.vhd 
