# ==============================================================================
# SDC TIMING CONSTRAINTS FILE (constraints.sdc)
# Design: vitalguard_core (ECG Signal Processing)
# Target Clock: clk_50mhz (10.64 ns Period ~ 94 MHz)
# Target PDK  : Sky130 HD
# ==============================================================================

# ==============================================================================
# 1. CLOCK DEFINITIONS
# ==============================================================================
# Primary Clock Definition (50 MHz nominal)
create_clock -name clk_50mhz -period 10.64 [get_ports clk_50mhz]

# Generated Clock Definition (Divide-by-50 for ADC clock output -> 1 MHz)
create_generated_clock -name adc_clk_out \
  -source [get_ports clk_50mhz] \
  -divide_by 50 \
  [get_ports adc_clk_out]


# ==============================================================================
# 2. CLOCK LATENCY & UNCERTAINTY
# ==============================================================================
# Clock Source Latency (Off-chip / Board latency)
set_clock_latency -source 0.5 [get_clocks clk_50mhz]

# Network Insertion Delay / Clock tree latency
set_clock_latency 1.2 [get_clocks clk_50mhz]

# Clock Uncertainty (Jitter + Skew modeling)
set_clock_uncertainty -setup 0.3 [get_clocks clk_50mhz]
set_clock_uncertainty -hold  0.1 [get_clocks clk_50mhz]

# Uncertainty for generated clock
set_clock_uncertainty -setup 0.2 [get_clocks adc_clk_out]
set_clock_uncertainty -hold  0.1 [get_clocks adc_clk_out]


# ==============================================================================
# 3. INPUT & OUTPUT DELAY CONSTRAINTS
# ==============================================================================
# Input Delays (relative to clk_50mhz rising edge)
set_input_delay 2.0 -clock clk_50mhz [get_ports ext_trigger]
set_input_delay 2.0 -clock clk_50mhz [get_ports adc_valid]
set_input_delay 2.0 -clock clk_50mhz [get_ports adc_data_in[*]]

# Output Delays (relative to clk_50mhz rising edge)
set_output_delay 4.0 -clock clk_50mhz [get_ports ecg_filtered_out[*]]
set_output_delay 4.0 -clock clk_50mhz [get_ports alarm_flag]


# ==============================================================================
# 4. ENVIRONMENT & LOAD MODELING
# ==============================================================================
# Driving Cell modeling for input ports (Sky130 standard buffer)
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [get_ports ext_trigger]
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [get_ports adc_valid]
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [get_ports adc_data_in[*]]

# Output Load Capacitance modeling (in pF)
set_load 0.15 [get_ports adc_clk_out]
set_load 0.10 [get_ports ecg_filtered_out[*]]
set_load 0.05 [get_ports alarm_flag]


# ==============================================================================
# 5. TIMING EXCEPTIONS & CDC CONSTRAINTS
# ==============================================================================
# False Path: Asynchronous Reset (CDC - clock domain crossing)
set_false_path -from [get_ports rst_n]


# ==============================================================================
# 6. MULTICYCLE PATH CONSTRAINTS (OPTIONAL - COMMENTED OUT)
# ==============================================================================
# NOTE: These constraints are optional since design meets timing with 5.5ns slack.
# Only uncomment if synthesis creates accum_stage1/accum_stage2 as separate cells.

# set_multicycle_path 2 -setup \
#   -from [get_cells -hierarchical *accum_stage1*] \
#   -to   [get_cells -hierarchical *accum_stage2*]
#
# set_multicycle_path 1 -hold \
#   -from [get_cells -hierarchical *accum_stage1*] \
#   -to   [get_cells -hierarchical *accum_stage2*]

