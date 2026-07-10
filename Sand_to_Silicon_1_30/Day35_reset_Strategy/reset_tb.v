`timescale 1ns/1ps

module reset_tb;

//==========================================================
// Testbench Signals
//==========================================================

// Clock Signals
reg cpu_clk;
reg adc_clk;
reg uart_clk;

// Reset Controller Inputs
reg ext_rst_n;
reg por_rst_n;
reg sw_rst_n;
reg wdog_rst_n;
reg pll_lock;

// RDC Input
reg cpu_valid;

// Outputs
wire raw_rst_n;

wire cpu_rst_n;
wire adc_rst_n;
wire uart_rst_n;

wire uart_valid;


//==========================================================
// Clock Generation
//==========================================================

// CPU Clock : 100 MHz
initial cpu_clk = 0;
always #5 cpu_clk = ~cpu_clk;

// ADC Clock : 50 MHz
initial adc_clk = 0;
always #10 adc_clk = ~adc_clk;

// UART Clock : 25 MHz
initial uart_clk = 0;
always #20 uart_clk = ~uart_clk;


//==========================================================
// DUT Instantiation
//==========================================================

// Reset Controller
reset_controller u_reset_controller(

    .ext_rst_n(ext_rst_n),
    .por_rst_n(por_rst_n),
    .sw_rst_n(sw_rst_n),
    .wdog_rst_n(wdog_rst_n),
    .pll_lock(pll_lock),

    .raw_rst_n(raw_rst_n)

);

// Reset Tree
reset_tree u_reset_tree(

    .cpu_clk(cpu_clk),
    .adc_clk(adc_clk),
    .uart_clk(uart_clk),

    .raw_rst_n(raw_rst_n),

    .cpu_rst_n(cpu_rst_n),
    .adc_rst_n(adc_rst_n),
    .uart_rst_n(uart_rst_n)

);

// RDC Synchronizer
rdc_control_sync u_rdc(

    .cpu_clk(cpu_clk),
    .uart_clk(uart_clk),

    .cpu_rst_n(cpu_rst_n),
    .uart_rst_n(uart_rst_n),

    .cpu_valid(cpu_valid),

    .uart_valid(uart_valid)

);


//==========================================================
// Stimulus
//==========================================================

initial
begin

    $dumpfile("reset_waveform.vcd");
    $dumpvars(0,reset_tb);

    //------------------------------------------------------
    // Initial Conditions
    //------------------------------------------------------

    ext_rst_n   = 0;
    por_rst_n   = 0;
    sw_rst_n    = 1;
    wdog_rst_n  = 1;
    pll_lock    = 0;

    cpu_valid   = 0;

    //------------------------------------------------------
    // Power-On Reset
    //------------------------------------------------------

    #40;

    por_rst_n = 1;

    #20;

    pll_lock = 1;

    #20;

    ext_rst_n = 1;

    //------------------------------------------------------
    // Wait for Synchronizers
    //------------------------------------------------------

    #100;

    //------------------------------------------------------
    // RDC Test
    //------------------------------------------------------

    $display("----- RDC Test -----");

    cpu_valid = 1;

    #100;

    cpu_valid = 0;

    #100;

    //------------------------------------------------------
    // External Reset
    //------------------------------------------------------

    $display("----- External Reset -----");

    ext_rst_n = 0;

    #40;

    ext_rst_n = 1;

    #120;

    //------------------------------------------------------
    // Software Reset
    //------------------------------------------------------

    $display("----- Software Reset -----");

    sw_rst_n = 0;

    #40;

    sw_rst_n = 1;

    #120;

    //------------------------------------------------------
    // Watchdog Reset
    //------------------------------------------------------

    $display("----- Watchdog Reset -----");

    wdog_rst_n = 0;

    #40;

    wdog_rst_n = 1;

    #120;

    //------------------------------------------------------
    // PLL Unlock
    //------------------------------------------------------

    $display("----- PLL Unlock -----");

    pll_lock = 0;

    #40;

    pll_lock = 1;

    #120;

    $display("--------------------------------");
    $display("Simulation Completed Successfully");
    $display("--------------------------------");

    $finish;

end


//==========================================================
// Monitor
//==========================================================

initial
begin

$monitor(
"Time=%0t | raw_rst=%b | CPU_RST=%b | ADC_RST=%b | UART_RST=%b | cpu_valid=%b | uart_valid=%b",

$time,
raw_rst_n,
cpu_rst_n,
adc_rst_n,
uart_rst_n,
cpu_valid,
uart_valid
);

end

endmodule