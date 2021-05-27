#!/usr/bin/env sh

echo
echo "**** split test ****"
ghdl -r --std=08 bitonic_split_TB
echo
echo "**** sort test ****"
ghdl -r --std=08 bitonic_sort_TB
