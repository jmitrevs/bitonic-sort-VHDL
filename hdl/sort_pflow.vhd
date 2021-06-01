-- ==============================================================
-- RTL generated by Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
-- Version: 2020.2
-- Copyright (C) Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.bitonic_sort_pkg.all;
use work.sort_pflow_pkg.all;

-- signed sort on bits 15 downto 0

entity sort_pflow is
  port (
    ap_clk : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    sort_inputs : in sort_inputs_t(NUM_INPUTS-1 downto 0)(NUM_BITS-1 downto 0);
    sort_outputs : out sort_inputs_t(NUM_OUTPUTS-1 downto 0)(NUM_BITS-1 downto 0)
  );
end;

architecture rtl of sort_pflow is
    --- need to use the next power of 2 
    signal full_inputs : sort_inputs_t(NUM_INPUTS_PW2-1 downto 0)(NUM_BITS-1 downto 0) 
      := (others => (others => '0'));
    signal full_outputs : sort_inputs_t(NUM_INPUTS_PW2-1 downto 0)(NUM_BITS-1 downto 0);
begin
    full_inputs(NUM_INPUTS-1 downto 0) <= sort_inputs;

    sorter_inst:  entity work.bitonic_sort
    generic map (
        SORT_WIDTH => NUM_INPUTS_PW2,
        BIT_WIDTH => NUM_BITS,
        COMPARISON_WIDTH => COMP_BITS
    )
    port map (
        ap_clk => ap_clk,
        ap_start => ap_start,
        ap_done => ap_done,
        sort_inputs => full_inputs,
        sort_outputs => full_outputs    
    );

    sort_outputs <= full_outputs(NUM_OUTPUTS-1 downto 0);
end architecture rtl; 