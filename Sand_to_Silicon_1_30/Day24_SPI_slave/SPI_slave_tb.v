`timescale 1ns/1ps

module SPI_slave_tb;

    // 1. Parameters
    parameter WIDTH = 8;
    parameter CLK_PERIOD = 10; // 100 MHz system clock

    // 2. TB Signals (Ports)
    reg                  clk;
    reg                  rst;
    reg                  cs;
    reg                  sclk;
    reg                  mosi;
    reg  [WIDTH-1:0]     tx_data;
    wire [WIDTH-1:0]     rx_data;
    wire                 rx_done;
    wire                 miso;

    // 3. DUT Instantiation
    SPI_slave #(
        .WIDTH(WIDTH)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .cs      (cs),
        .sclk    (sclk),
        .mosi    (mosi),
        .tx_data (tx_data),
        .rx_data (rx_data),
        .rx_done (rx_done),
        .miso    (miso)
    );

    // 4. Clock Generation (sys_clk)
    always #(CLK_PERIOD/2) clk = ~clk;

    // 5. VCD Dump and Monitor Setup
    initial begin
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, SPI_slave_tb);

        $monitor("Time=%0t ns | CS=%b | SCLK=%b | MOSI=%b | MISO=%b | BitCnt=%d | RX_Done=%b | RX_Data=0x%h", 
                 $time, cs, sclk, mosi, miso, dut.bit_cnt, rx_done, rx_data);
    end

    // 6. Stimulus Task: Send an SPI Byte (Mode 0)
    task send_spi_byte(input [WIDTH-1:0] data_to_send);
        integer i;
        begin
            // Activate CS
            @(posedge clk);
            cs = 1'b0;
            @(posedge clk);

            // Shift 8 bits (MSB first)
            for (i = WIDTH-1; i >= 0; i = i - 1) begin
                mosi = data_to_send[i];
                
                // Generate a slow, synchronized SCLK rising edge
                repeat(4) @(posedge clk); 
                sclk = 1'b1;
                
                repeat(4) @(posedge clk);
                sclk = 1'b0;
            end
            
            // Deactivate CS
            repeat(4) @(posedge clk);
            cs = 1'b1;
            mosi = 1'b0;
            @(posedge clk);
        end
    endtask

    // 7. Test Sequence
    initial begin
        // Initialize signals
        clk     = 1'b0;
        rst     = 1'b1;
        cs      = 1'b1;
        sclk    = 1'b0;
        mosi    = 1'b0;
        tx_data = 8'hA5; // Data slave will transmit (10100101)

        // Apply Reset
        repeat(5) @(posedge clk);
        rst = 1'b0;
        repeat(2) @(posedge clk);

        // Transaction 1: Send 8'h3C to slave, expect slave to send 8'hA5 to master
        $display("\n--- Starting SPI Transaction 1 (Sending 0x3C) ---");
        send_spi_byte(8'h3C);

        // Hold idle
        repeat(10) @(posedge clk);

        // Transaction 2: Send 8'hF0 with new tx_data loaded
        tx_data = 8'h5A; 
        $display("\n--- Starting SPI Transaction 2 (Sending 0xF0) ---");
        send_spi_byte(8'hF0);

        repeat(20) @(posedge clk);
        $display("\n--- Simulation Finished ---");
        $finish;
    end

endmodule