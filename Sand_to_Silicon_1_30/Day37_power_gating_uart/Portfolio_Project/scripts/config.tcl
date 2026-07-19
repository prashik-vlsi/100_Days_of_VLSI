#==================================================
# OpenLane Configuration
# UART Power Gating with Idle Timer
#==================================================


# Top module name
set ::env(DESIGN_NAME) uart_power_gating_with_idle_timer


# RTL source
set ::env(VERILOG_FILES) \
$::env(DESIGN_DIR)/src/uart.v


# Clock
set ::env(CLOCK_PORT) clk
set ::env(CLOCK_PERIOD) 20


# Technology
set ::env(PDK) sky130A


# Standard cell library
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd


#==================================================
# Floorplan
#==================================================

set ::env(FP_CORE_UTIL) 40
set ::env(FP_ASPECT_RATIO) 1
set ::env(FP_CORE_MARGIN) 5


#==================================================
# Placement
#==================================================

set ::env(PL_TARGET_DENSITY) 0.5


#==================================================
# Routing
#==================================================

set ::env(RT_MAX_LAYER) met5
set ::env(RT_MIN_LAYER) met1


#==================================================
# Timing Library
#==================================================

set ::env(LIB_SYNTH) $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set ::env(LIB_FASTEST) $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_100C_1v95.lib

set ::env(LIB_SLOWEST) $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib
#==================================================
# Reports
#==================================================

set ::env(SAVE_VIEWS) true