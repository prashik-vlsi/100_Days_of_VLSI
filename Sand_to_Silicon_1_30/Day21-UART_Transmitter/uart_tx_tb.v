`timescale 1ns/1ps

module tb_uart_tx;

    // Inputs to the Unit Under Test (UUT)
    reg clk;
    reg rst_n;
    reg tx_start;
    reg [7:0] tx_data;

    // Outputs from the Unit Under Test (UUT)
    wire tx_serial;
    wire tx_busy;

    // Instantiate the Parameterized Unit Under Test (UUT)
    uart_tx #(
        .CLK_FREQ(50000000),  // 50 MHz System Clock
        .BAUD_RATE(9600)      // 9600 Baud Rate
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );

    // =========================================================================
    // ICARUS VERILOG WORKAROUND: Intermediate Nets for $monitor
    // =========================================================================
    wire [1:0] mon_state     = uut.current_state;
    wire [7:0] mon_shift_reg = uut.tx_shift_reg;

    // Clock Generation: 50 MHz = 20ns clock period (Toggle every 10ns)
    always #10 clk = ~clk;

    initial begin
        // Setup structural waveform dumping for GTKWave analysis
        $dumpfile("uart_tx_waveform.vcd");
        $dumpvars(0, tb_uart_tx);

        // CLEAN EVENT-DRIVEN MONITOR BLOCK (Passing only simple signals now)
        $monitor("Time = %0t ns | rst_n = %b | State_Bits = %b | tx_start = %b | tx_serial = %b | tx_busy = %b | Shift_Reg = 8'h%h", 
                 $time, rst_n, mon_state, tx_start, tx_serial, tx_busy, mon_shift_reg);

        // System Initialization
        clk = 0;
        rst_n = 0;       // Apply active-low synchronous reset
        tx_start = 0;
        tx_data = 8'b0;

        // Release Reset after 100ns execution window
        #100;
        rst_n = 1;
        #40;             // Wait for clock stability

        // Stimulus Injection: Transmit ASCII Character 'A' (8'h41)
        tx_data = 8'h41;
        tx_start = 1;    // Assert start strobe
        #20;             // Hold for exactly one 50MHz clock cycle
        tx_start = 0;    // Deassert strobe to prevent double transmission

        // Wait window: 10 bits * 104.16us per bit = ~1.04ms total frame duration
        #1200000; 

        $display("[SUCCESS] Simulation complete. Run 'gtkwave uart_tx_waveform.vcd' to analyze the physical frame.");
        $finish;
    end

endmodule