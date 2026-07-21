#==================================================
# OpenLane Configuration
# Project: UART Receiver + FIFO + APB
# Top Module: my_design
# Technology: SKY130 HD
#==================================================

#--------------------------------------------------
# Design
#--------------------------------------------------

set ::env(DESIGN_NAME) my_design

#--------------------------------------------------
# RTL Sources
#--------------------------------------------------

set ::env(VERILOG_FILES) "\
$::env(DESIGN_DIR)/design.v \
$::env(DESIGN_DIR)/uart_rx.v \
$::env(DESIGN_DIR)/sync_fifo.v"

#--------------------------------------------------
# Clock
#--------------------------------------------------

set ::env(CLOCK_PORT) PCLK
set ::env(CLOCK_PERIOD) 10

#--------------------------------------------------
# Technology
#--------------------------------------------------

set ::env(PDK) sky130A
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd

#--------------------------------------------------
# Floorplan
#--------------------------------------------------

set ::env(FP_CORE_UTIL) 40
set ::env(FP_ASPECT_RATIO) 1
set ::env(FP_CORE_MARGIN) 5

#--------------------------------------------------
# Placement
#--------------------------------------------------

set ::env(PL_TARGET_DENSITY) 0.5

#--------------------------------------------------
# Routing
#--------------------------------------------------

set ::env(RT_MIN_LAYER) met1
set ::env(RT_MAX_LAYER) met5

#--------------------------------------------------
# Timing Libraries
#--------------------------------------------------

set ::env(LIB_SYNTH) \
$::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

set ::env(LIB_FASTEST) \
$::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_100C_1v95.lib

set ::env(LIB_SLOWEST) \
$::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib

#--------------------------------------------------
# Save Generated Views
#--------------------------------------------------

set ::env(SAVE_VIEWS) true
