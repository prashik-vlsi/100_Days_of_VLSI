`timescale 1ns / 1ps

module axi4_master_write_tb;

    // Parameters
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10; // 100 MHz clock

    // Testbench Driving Signals
    reg                     clk;
    reg                     rst_n;

    // User Application Interface Ports
    reg                     write_req;
    reg  [ADDR_WIDTH-1:0]   addr_in;
    reg  [DATA_WIDTH-1:0]   data_in;
    reg  [(DATA_WIDTH/8)-1:0] strb_in;
    wire                    write_done;

    // AXI Bus Interface Wires
    wire [ADDR_WIDTH-1:0]   awaddr;
    wire                    awvalid;
    reg                     awready;

    wire [DATA_WIDTH-1:0]   wdata;
    wire [(DATA_WIDTH/8)-1:0] wstrb;
    wire                    wvalid;
    reg                     wready;

    reg  [1:0]              bresp;
    reg                     bvalid;
    wire                    bready;

    // Transaction bookkeeping for the monitor / scoreboard
    integer txn_count = 0;
    reg [ADDR_WIDTH-1:0]     exp_addr;
    reg [DATA_WIDTH-1:0]     exp_data;
    reg [(DATA_WIDTH/8)-1:0] exp_strb;
    reg aw_seen, w_seen, b_seen;
    integer errors = 0;

    //---------------------------------------------------------
    // DUT
    //---------------------------------------------------------
    axi4_master_write #(
        .addr_width(ADDR_WIDTH),
        .data_width(DATA_WIDTH)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .write_req(write_req),
        .addr_in(addr_in),
        .data_in(data_in),
        .strb_in(strb_in),
        .write_done(write_done),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );

    //---------------------------------------------------------
    // Clock
    //---------------------------------------------------------
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    //---------------------------------------------------------
    // Watchdog
    //---------------------------------------------------------
    initial begin
        #5000;
        $display("\n[FATAL] Simulation Timeout! A handshake deadlock still exists.");
        $display("[SCOREBOARD] Transactions completed = %0d, Errors = %0d", txn_count, errors);
        $finish;
    end

    //---------------------------------------------------------
    // Reusable transaction driver task
    //   mode 0 = simultaneous AW/W
    //   mode 1 = W first, AW delayed
    //   mode 2 = AW first, W delayed
    //---------------------------------------------------------
    task do_write_txn;
        input [ADDR_WIDTH-1:0]     t_addr;
        input [DATA_WIDTH-1:0]     t_data;
        input [(DATA_WIDTH/8)-1:0] t_strb;
        input integer              mode;
        begin
            // Set scoreboard expectations
            exp_addr = t_addr;
            exp_data = t_data;
            exp_strb = t_strb;
            aw_seen  = 0;
            w_seen   = 0;
            b_seen   = 0;

            @(posedge clk);
            write_req <= 1'b1;
            addr_in   <= t_addr;
            data_in   <= t_data;
            strb_in   <= t_strb;

            @(posedge clk);
            write_req <= 1'b0;

            case (mode)
                0: begin // simultaneous
                    while (!awvalid || !wvalid) @(posedge clk);
                    awready <= 1'b1;
                    wready  <= 1'b1;
                    @(posedge clk);
                    awready <= 1'b0;
                    wready  <= 1'b0;
                end

                1: begin // W first, AW delayed
                    while (!wvalid) @(posedge clk);
                    wready <= 1'b1;
                    @(posedge clk);
                    wready <= 1'b0;

                    repeat (2) @(posedge clk);

                    @(posedge clk);
                    awready <= 1'b1;
                    @(posedge clk);
                    awready <= 1'b0;
                end

                2: begin // AW first, W delayed
                    while (!awvalid) @(posedge clk);
                    awready <= 1'b1;
                    @(posedge clk);
                    awready <= 1'b0;

                    repeat (2) @(posedge clk);

                    @(posedge clk);
                    wready <= 1'b1;
                    @(posedge clk);
                    wready <= 1'b0;
                end
            endcase

            // Response phase
            @(posedge clk);
            bvalid <= 1'b1;
            bresp  <= 2'b00;

            while (!(bvalid && bready)) @(posedge clk);
            bvalid <= 1'b0;

            wait(write_done);
            #(CLK_PERIOD * 2);

            // Per-transaction pass/fail check
            if (aw_seen && w_seen && b_seen) begin
                $display("[SCOREBOARD] Txn %0d PASS  (addr=0x%h data=0x%h)", txn_count, exp_addr, exp_data);
            end else begin
                errors = errors + 1;
                $display("[SCOREBOARD] Txn %0d FAIL  aw_seen=%0d w_seen=%0d b_seen=%0d",
                          txn_count, aw_seen, w_seen, b_seen);
            end
            txn_count = txn_count + 1;
        end
    endtask

    //---------------------------------------------------------
    // Stimulus
    //---------------------------------------------------------
    initial begin
        $dumpfile("axi4_master_tb.vcd");
        $dumpvars(0, axi4_master_write_tb);

        clk        = 0;
        rst_n      = 0;
        write_req  = 0;
        addr_in    = 0;
        data_in    = 0;
        strb_in    = 0;
        awready    = 0;
        wready     = 0;
        bresp      = 2'b00;
        bvalid     = 0;

        #(CLK_PERIOD * 2);
        rst_n = 1;
        #(CLK_PERIOD * 2);

        // Transaction 1: simultaneous handshake
        do_write_txn(4'h4, "Shil", 4'b1111, 0);

        // Transaction 2: W first, AW delayed (split handshake - the failing case)
        do_write_txn(4'h8, " Mam", 4'b1111, 1);

        // Transaction 3: AW first, W delayed
        do_write_txn(4'hC, "test", 4'b1111, 2);

        // Transaction 4: simultaneous again, different strobe
        do_write_txn(4'h0, "1234", 4'b0011, 0);

        #(CLK_PERIOD * 5);

        if (errors == 0)
            $display("\n[TB] SUCCESS: All %0d transactions executed cleanly without hangs.", txn_count);
        else
            $display("\n[TB] FAILURE: %0d of %0d transactions failed.", errors, txn_count);

        $finish;
    end

    initial begin
        $display("==================================================================");
        $display("       AXI4-LITE MASTER WRITE TRANSACTION MONITOR ACTIVE          ");
        $display("==================================================================");
    end

    //---------------------------------------------------------
    // Independent per-transaction Bus Monitor
    //---------------------------------------------------------
    always @(posedge clk) begin
        if (rst_n) begin
            if (awvalid && awready) begin
                aw_seen <= 1'b1;
                $display("[MONITOR] [Time: %0t ns] Txn %0d AW HANDSHAKE: Addr = 0x%h", $time, txn_count, awaddr);
                if (awaddr !== exp_addr) begin
                    errors = errors + 1;
                    $display("[MONITOR] *** ADDR MISMATCH: expected 0x%h got 0x%h ***", exp_addr, awaddr);
                end
            end

            if (wvalid && wready) begin
                w_seen <= 1'b1;
                $display("[MONITOR] [Time: %0t ns] Txn %0d W HANDSHAKE : Data = 0x%h (\"%c%c%c%c\"), Strobe = %b",
                         $time, txn_count, wdata, wdata[31:24], wdata[23:16], wdata[15:8], wdata[7:0], wstrb);
                if (wdata !== exp_data) begin
                    errors = errors + 1;
                    $display("[MONITOR] *** DATA MISMATCH: expected 0x%h got 0x%h ***", exp_data, wdata);
                end
                if (wstrb !== exp_strb) begin
                    errors = errors + 1;
                    $display("[MONITOR] *** STROBE MISMATCH: expected %b got %b ***", exp_strb, wstrb);
                end
            end

            if (bvalid && bready) begin
                b_seen <= 1'b1;
                if (bresp == 2'b00)
                    $display("[MONITOR] [Time: %0t ns] Txn %0d B HANDSHAKE : Status OKAY (Write Verified)", $time, txn_count);
                else
                    $display("[MONITOR] [Time: %0t ns] Txn %0d B HANDSHAKE : Error Flag Detected = 2'b%b", $time, txn_count, bresp);
            end

            if (write_done) begin
                $display("[MONITOR] [Time: %0t ns] STATUS      : Lifecycle complete for txn %0d.\n------------------------------------------------------------------", $time, txn_count);
            end
        end
    end

endmodule