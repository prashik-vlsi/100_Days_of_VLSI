#==============================================================
# SDC CONSTRAINTS
# Project      : VitalGuard Subsystem
# Top Module   : my_design
# Technology   : SKY130 HD
# Clock        : PCLK
# Frequency    : 100 MHz
#==============================================================


#==============================================================
# 1. CLOCK DEFINITION
#==============================================================

# 100 MHz clock
# Period = 10 ns

create_clock \
    -name PCLK \
    -period 10.0 \
    [get_ports PCLK]


#==============================================================
# 2. CLOCK UNCERTAINTY
#==============================================================

# Account for clock jitter and uncertainty

set_clock_uncertainty \
    -setup 0.2 \
    [get_clocks PCLK]

set_clock_uncertainty \
    -hold 0.1 \
    [get_clocks PCLK]


#==============================================================
# 3. CLOCK TRANSITION
#==============================================================

set_clock_transition \
    0.1 \
    [get_clocks PCLK]


#==============================================================
# 4. INPUT DELAYS
#==============================================================

# APB address input delay

set_input_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PADDR[*]]

set_input_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PADDR[*]]


# APB select

set_input_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PSEL]

set_input_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PSEL]


# APB enable

set_input_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PENABLE]

set_input_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PENABLE]


# APB write control

set_input_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PWRITE]

set_input_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PWRITE]


# APB write data

set_input_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PWDATA[*]]

set_input_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PWDATA[*]]


# UART RX input

set_input_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports RX]

set_input_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports RX]


#==============================================================
# 5. OUTPUT DELAYS
#==============================================================

# APB read data

set_output_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PRDATA[*]]

set_output_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PRDATA[*]]


# APB ready signal

set_output_delay \
    -clock PCLK \
    -max 2.0 \
    [get_ports PREADY]

set_output_delay \
    -clock PCLK \
    -min 0.5 \
    [get_ports PREADY]


#==============================================================
# 6. INPUT DRIVE
#==============================================================

# Assume inputs are driven by an inverter cell

set_driving_cell \
    -lib_cell sky130_fd_sc_hd__inv_1 \
    [get_ports {PADDR[*] PSEL PENABLE PWRITE PWDATA[*] RX}]


#==============================================================
# 7. OUTPUT LOAD
#==============================================================

# Assume standard capacitive load

set_load 0.1 [get_ports {PRDATA[*] PREADY}]


#==============================================================
# 8. RESET CONSTRAINT
#==============================================================

# PRESETn is asynchronous reset.
# It is not a synchronous timing path.

set_false_path \
    -from [get_ports PRESETn] \
    -to [all_registers]


#==============================================================
# 9. ASYNCHRONOUS RESET RECOVERY/REMOVAL
#==============================================================

# Reset is asynchronous, so recovery/removal checks
# should be considered during signoff.


#==============================================================
# 10. REPORTING
#==============================================================

# End of SDC constraints
