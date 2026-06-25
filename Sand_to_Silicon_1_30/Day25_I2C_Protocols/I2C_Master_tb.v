`timescale 1ns/1ps
module I2C_Master_tb;

    reg        clk;
    reg        rst_n;
    reg        start;
    reg        rw;
    reg  [6:0] addr;
    reg  [7:0] wdata;

    wire       sda;
    wire       scl;
    wire [7:0] rdata;
    wire       done;
    wire       ack_err;

    reg [7:0] slave_tx_data;          // payload slave returns on read

    // Combinational bit index: mirrors master bit_cnt, MSB first
    wire [2:0] slave_bit_idx = 3'd7 - dut.bit_cnt;


    pullup(sda);

    I2C_Master dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (start),
        .rw      (rw),
        .addr    (addr),
        .wdata   (wdata),
        .sda     (sda),
        .scl     (scl),
        .rdata   (rdata),
        .done    (done),
        .ack_err (ack_err)
    );


    initial clk = 1'b0;
    always  #10 clk = ~clk;

    initial begin
        $dumpfile("vcd_dump.vcd");
        $dumpvars(0, I2C_Master_tb);
    end

    initial begin
        $monitor("Time=%0dns | State=%b | SCL=%b | SDA=%b | Done=%b | ACK_Err=%b",
                 $time, dut.state, scl, sda, done, ack_err);
    end

    // =========================================================================
    // SLAVE SDA DRIVER — purely combinational
    //
    //  DATA_RX  : slave presents the correct read-data bit (MSB first)
    //  ADDR_ACK : slave drives ACK (0)
    //  DATA_ACK : slave drives ACK (0) only on a Write; on a Read the master
    //             drives NACK, so the slave must release the bus (1'bz)
    //  all else : release bus
    // =========================================================================
    assign sda = (dut.state == dut.DATA_RX)
                     ? slave_tx_data[slave_bit_idx]        // MSB-first read data
               : (dut.state == dut.ADDR_ACK)
                     ? 1'b0                                // slave ACK after address
               : (dut.state == dut.DATA_ACK && rw == 1'b0)
                     ? 1'b0                                // slave ACK after write data
               : 1'bz;                                     // release bus

    // =========================================================================
    // Stimulus sequence
    // =========================================================================
    initial begin
        // Initialise all inputs
        rst_n         = 1'b0;
        start         = 1'b0;
        rw            = 1'b0;
        addr          = 7'b0;
        wdata         = 8'b0;
        slave_tx_data = 8'hB3;   // 1011_0011 — expected read-back value

        #40;
        rst_n = 1'b1;
        #40;

        // -----------------------------------------------------------------
        // Transaction 1 — Write  (addr=0x5A, data=0xA5)
        // -----------------------------------------------------------------
        $display("[TB] Starting I2C Write: addr=0x5A  data=0xA5");
        addr  = 7'h5A;
        wdata = 8'hA5;
        rw    = 1'b0;
        start = 1'b1;
        #20;
        start = 1'b0;

        @(posedge done);
        #200;

        // -----------------------------------------------------------------
        // Transaction 2 — Read  (addr=0x5A, expect 0xB3)
        // -----------------------------------------------------------------
        $display("[TB] Starting I2C Read:  addr=0x5A  (expecting rdata=0xB3)");
        addr  = 7'h5A;
        rw    = 1'b1;
        start = 1'b1;
        #20;
        start = 1'b0;

        @(posedge done);
        #20;

        if (rdata == 8'hB3)
            $display("[TB] PASS — rdata=0x%0h (expected 0xB3)", rdata);
        else
            $display("[TB] FAIL — rdata=0x%0h (expected 0xB3)", rdata);

        #100;
        $finish;
    end

endmodule