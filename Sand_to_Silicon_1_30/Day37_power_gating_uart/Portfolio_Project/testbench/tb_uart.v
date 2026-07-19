`timescale 1ns/1ps

module tb_uart_power_gating_with_idle_timer;

parameter DATA_WIDTH = 8;
parameter CLK_FREQ   = 50_000_000;
parameter BAUD_RATE  = 115200;

// Small timeout for simulation
parameter IDLE_TIMEOUT_US = 2;

reg clk;
reg rst_n;
reg sleep;
reg tx_start;
reg [DATA_WIDTH-1:0] tx_data;

wire tx;
wire tx_busy;
wire sleep_ack;

//--------------------------------------------------
// DUT
//--------------------------------------------------
uart_power_gating_with_idle_timer #(
    .DATA_WIDTH(DATA_WIDTH),
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .IDLE_TIMEOUT_US(IDLE_TIMEOUT_US)
)dut(
    .clk(clk),
    .rst_n(rst_n),
    .sleep(sleep),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy),
    .sleep_ack(sleep_ack)
);

//--------------------------------------------------
// Clock Generation (50 MHz)
//--------------------------------------------------
always #10 clk = ~clk;
//--------------------------------------------------
// Waveform Dump for Power Analysis
//--------------------------------------------------
initial begin
    $dumpfile("uart_power_gating.vcd");
    $dumpvars(0, tb_uart_power_gating_with_idle_timer);
end

//--------------------------------------------------
// Test Sequence
//--------------------------------------------------
initial begin

    clk = 0;
    rst_n = 0;
    sleep = 0;
    tx_start = 0;
    tx_data = 8'h00;

    //------------------------------------------------
    // RESET
    //------------------------------------------------
    #100;
    rst_n = 1;

    $display("-------------------------------------");
    $display("RESET RELEASED");
    $display("-------------------------------------");

    //------------------------------------------------
    // TEST 1
    //------------------------------------------------
    #100;

    tx_data = 8'hA5;
    tx_start = 1;

    #20;
    tx_start = 0;

    wait(tx_busy == 0);

    $display("TEST1 PASS : Transmission Complete");

    //------------------------------------------------
    // TEST 2
    // Sleep while Idle
    //------------------------------------------------

    #500;

    sleep = 1;

    wait(sleep_ack);

    $display("TEST2 PASS : Entered Sleep");

    //------------------------------------------------
    // TEST 3
    // Wakeup
    //------------------------------------------------

    #500;

    sleep = 0;

    #200;

    if(!sleep_ack)
        $display("TEST3 PASS : Wakeup Successful");
    else
        $display("TEST3 FAIL");

    //------------------------------------------------
    // TEST 4
    // Sleep During Transmission
    //------------------------------------------------

    tx_data = 8'h3C;
    tx_start = 1;

    #20;
    tx_start = 0;

    #100;

    sleep = 1;

    wait(sleep_ack);

    $display("TEST4 PASS : Slept After TX");

    //------------------------------------------------
    // TEST 5
    // Wake Again
    //------------------------------------------------

    #500;

    sleep = 0;

    #100;

    //------------------------------------------------
    // TEST 6
    // Second Transmission
    //------------------------------------------------

    tx_data = 8'hF0;
    tx_start = 1;

    #20;
    tx_start = 0;

    wait(tx_busy==0);

    $display("TEST6 PASS : Second TX");

    //------------------------------------------------
    // Finish
    //------------------------------------------------

    #1000;

    $display("-------------------------------------");
    $display("ALL TESTS COMPLETED");
    $display("-------------------------------------");

    $finish;

end

//--------------------------------------------------
// Monitor
//--------------------------------------------------
initial begin

$monitor(
"Time=%0t  State=%0d Busy=%b TX=%b Sleep=%b Ack=%b",
$time,
dut.state,
tx_busy,
tx,
sleep,
sleep_ack
);

end

endmodule