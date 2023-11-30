#
# Copyright 2022 Ettus Research, a National Instruments Brand
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# Description:
#   Timing constraints exclusive to X440. These should be used
#   in conjunction with ./common.xdc
#

###############################################################################
# DB GPIO
#   This interface is defined as system synchronous to pll_ref_clk.
#   Some timing constants in this section are declared in
#   <repo>/fpga/usrp3/top/x400/constraints/timing/shared_constants.sdc
###############################################################################

# In the current db_gpio_interface implementation, all GPIOs are received asynchronously
# by the DB, so we add a very relax constraint for these signals.
set db_gpio_min 0
set db_gpio_max [expr {$pll_ref_clk_period/2}]
set db_gpio_sync_max 3.500

# Set constraints for all ports.
set db_gpio_ports [get_ports {DB0_GPIO[*] DB1_GPIO[*]}]
set db_gpio_sync_ports [get_ports {DB0_GPIO[12] DB0_GPIO[13] DB1_GPIO[16] DB1_GPIO[17]}]

set_output_delay -clock [get_clocks pll_ref_clk] -min $db_gpio_min $db_gpio_ports
set_output_delay -clock [get_clocks pll_ref_clk] -max $db_gpio_max $db_gpio_ports
# Should just overwrite the setting for the sync clock ports that are also in db_gpio_ports
set_output_delay -clock [get_clocks ref_clk] -max $db_gpio_sync_max $db_gpio_sync_ports

set_input_delay -clock [get_clocks pll_ref_clk] -max $db_gpio_min $db_gpio_ports
set_input_delay -clock [get_clocks pll_ref_clk] -min $db_gpio_max $db_gpio_ports

# Use multi cycle path constraint to relax timing on these pins.
set_multicycle_path -setup 2 -from [get_pins db_gpio_gen[*].db_gpio_interface_i/ctrlport_to_i2c_inst/i2c_master/byte_controller/bit_controller/*_oen_reg/C]
set_multicycle_path -end -hold 7 -from [get_pins db_gpio_gen[*].db_gpio_interface_i/ctrlport_to_i2c_inst/i2c_master/byte_controller/bit_controller/*_oen_reg/C]
###############################################################################
# x440_ps_rfdc_bd
###############################################################################

# This property tells Vivado that we require these clocks to be well aligned.
# We have synchronous clock domain crossings between these clocks that can have
# large hold violations after placement due to uneven clock loading.
set_property CLOCK_DELAY_GROUP DataClkGroup [get_nets -hier -filter {\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/data_clk               ||\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/data_clk_2x            ||\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/pll_ref_clk_out        ||\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/radio0_rfdc_clk        ||\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/radio0_rfdc_clk_2x     ||\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/radio1_rfdc_clk        ||\
  NAME=~*/rfdc/data_clock_mmcm/inst/CLK_CORE_DRP_I/clk_inst/radio1_rfdc_clk_2x       \
}]

# We treat rfdc_clk buffers as asynchronous, with knowledge that
# code clocked in this domain will be reset after this clocked is enabled. This
# will make timing easier to meet on these clock domains.
set_false_path -from [get_pins -hierarchical -filter {NAME =~ */rfdc/clock_gates_0/*rEnableRfdc0Bufg1x*/C}] \
               -to   [get_pins -hierarchical -filter {NAME =~ */rfdc/rf_clock_buffers/rf0_clk_1x_buf/*BUFGCE*/CE}]

set_false_path -from [get_pins -hierarchical -filter {NAME =~ */rfdc/clock_gates_0/*rEnableRfdc0Bufg2x*/C}] \
               -to   [get_pins -hierarchical -filter {NAME =~ */rfdc/rf_clock_buffers/rf0_clk_2x_buf/*BUFGCE*/CE}]

set_false_path -from [get_pins -hierarchical -filter {NAME =~ */rfdc/clock_gates_0/*rEnableRfdc1Bufg1x*/C}] \
               -to   [get_pins -hierarchical -filter {NAME =~ */rfdc/rf_clock_buffers/rf1_clk_1x_buf/*BUFGCE*/CE}]

set_false_path -from [get_pins -hierarchical -filter {NAME =~ */rfdc/clock_gates_0/*rEnableRfdc1Bufg2x*/C}] \
               -to   [get_pins -hierarchical -filter {NAME =~ */rfdc/rf_clock_buffers/rf1_clk_2x_buf/*BUFGCE*/CE}]


###############################################################################
# SPLL SYSREF Capture
###############################################################################

# SYSREF is generated by the LMK04832 clocking chip (SPLL), which also produces
# the PLL reference clock (PRC) used to generate data clocks with a MMCM. Both
# SYSREF and PLL reference clock are directly fed into the RFSoC.
# SYSREF is captured by the FPGA fabric in the PRC clock domain (MMCM's PRC
# output) with a double synchronizer and then transfered to the RFDC clock
# domain. Both SYSREF versions (PRC and RFDC) are used by downstream logic for
# sync. purposes.
# SYSREF is a continuous signal intentionally shifted in the LMK chip to align
# it closer to the PRC's falling edge.
# The highest PRC frequency supported in MPM (64 MHz) is used for
# timing constraints. Therefore, SYSREF LMK's delay = (1/64e6)/2.
set sysref_lmk_delay 7.8125
#
# These are the signals' lengths and corresponding delays (assuming 170 ps/in):
#   - SYSREF --> 5794 mils (5.794 inches) = 0.985 ns
#   - PRC    --> 5668 mils (5.668 inches) = 0.964 ns
#
# For min/max input delay calculations, it is assumed min prop. delay of 0 ns,
# which essentially over-constrains SYSREF.
#
# The max input delay is the latest that SYSREF may arrive w.r.t PRC, and it is
# calculated as follows:
#   Input delay (max) = SYSREF's LMK delay + SYSREF prop. delay (max)
#                       - PRC prop. delay (min)
set sysref_max_input_delay [expr {$sysref_lmk_delay + 0.985 - 0}]
#
# The min input delay is the earliest that SYSREF may arrive w.r.t PRC, and it
# is calculated as follows:
#   Input delay (min) = SYSREF's LMK delay + SYSREF prop. delay (min)
#                       - PRC prop. delay (min)
set sysref_min_input_delay [expr {$sysref_lmk_delay + 0 - 0.964}]

set_input_delay -clock pll_ref_clk -max $sysref_max_input_delay [get_ports {SYSREF_FABRIC_P}]
set_input_delay -clock pll_ref_clk -min $sysref_min_input_delay [get_ports {SYSREF_FABRIC_P}]

###############################################################################
# SPI to MB CPLD (PL)
#   This interface is defined as system synchronous to pll_ref_clk.
###############################################################################

# The output delays are chosen to allow a large time window of valid data for
# the MB CPLD logic.
set spi_min_out_delay -1.500
set spi_max_out_delay  9.500

# Set output constraints for all ports.
set spi_out_ports [get_ports {PL_CPLD_SCLK PL_CPLD_MOSI PL_CPLD_CS0_n PL_CPLD_CS1_n}]
set_output_delay -clock [get_clocks pll_ref_clk] -min $spi_min_out_delay $spi_out_ports
set_output_delay -clock [get_clocks pll_ref_clk] -max $spi_max_out_delay $spi_out_ports
