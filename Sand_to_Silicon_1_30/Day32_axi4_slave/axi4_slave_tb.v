`timescale 1ns/1ps;
module axi4_slave_tb();
 
    reg clk, rst_n;
 
    wire [3:0] awaddr, araddr;
    wire awvalid, awready, arvalid, arready;
    wire [31:0] wdata, rdata;
    wire [3:0] wstrb;
    wire wvalid, wready;
    wire [1:0] bresp, rresp;
    wire bvalid, bready, rvalid, rready;
 
    reg [31:0] read_data;
    reg [1:0]  read_resp;
 
    axi4_lite_master master (
        .clk(clk), .rst_n(rst_n),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
    );
 
    axi4_lite_slave slave (
        .clk(clk), .rst_n(rst_n),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
    );
 
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
 
    integer i;
    integer errors;
 
    initial begin
        errors = 0;
 
        $dumpfile("axi4_lite.vcd");
        $dumpvars(0, axi4_slave_tb);
 
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
 
        // TEST 1: Normal write then read same address
        $display("TEST 1: Write 0xDEADBEEF to addr 0x5, then read back");
        master.axi_write(4'd5, 32'hDEADBEEF);
        master.axi_read(4'd5, read_data, read_resp);
        if (read_data == 32'hDEADBEEF && read_resp == 2'b00)
            $display("PASS: TEST 1");
        else begin
            $display("FAIL: TEST 1 - expected 0xDEADBEEF/OKAY, got 0x%h/%b", read_data, read_resp);
            errors = errors + 1;
        end
 
        // TEST 2: Read from invalid address (0xF is out of MEM_DEPTH=15 range)
        $display("\nTEST 2: Read from invalid address 0xF (out of bounds)");
        master.axi_read(4'hF, read_data, read_resp);
        if (read_resp == 2'b10)
            $display("PASS: TEST 2 - SLVERR returned");
        else begin
            $display("FAIL: TEST 2 - expected SLVERR, got %b", read_resp);
            errors = errors + 1;
        end
 
        // TEST 3: Simultaneous-ish write addr 0x3 and read addr 0x5
        $display("\nTEST 3: Write addr 0x3, then read addr 0x5 (checks state independence)");
        master.axi_write(4'd3, 32'hCAFEBABE);
        master.axi_read(4'd5, read_data, read_resp);
        if (read_data == 32'hDEADBEEF)
            $display("PASS: TEST 3");
        else begin
            $display("FAIL: TEST 3 - expected 0xDEADBEEF, got 0x%h", read_data);
            errors = errors + 1;
        end
 
        // Verify the 0x3 write landed
        master.axi_read(4'd3, read_data, read_resp);
        if (read_data == 32'hCAFEBABE)
            $display("PASS: TEST 3b - addr 0x3 write verified");
        else begin
            $display("FAIL: TEST 3b - expected 0xCAFEBABE at addr 0x3, got 0x%h", read_data);
            errors = errors + 1;
        end
 
        // TEST 4: Back-to-back reads
        $display("\nTEST 4: Back-to-back reads from 0x3, then 0x5");
        master.axi_read(4'd3, read_data, read_resp);
        $display("  Read addr 0x3: 0x%h", read_data);
        if (read_data !== 32'hCAFEBABE) begin
            $display("FAIL: TEST 4a");
            errors = errors + 1;
        end
        master.axi_read(4'd5, read_data, read_resp);
        $display("  Read addr 0x5: 0x%h", read_data);
        if (read_data == 32'hDEADBEEF)
            $display("PASS: TEST 4");
        else begin
            $display("FAIL: TEST 4");
            errors = errors + 1;
        end
 
        // TEST 5: Write all valid addresses (0..14), verify reads, check 0xF stays SLVERR
        $display("\nTEST 5: Write pattern to all valid addresses (0..14), verify reads");
        for (i = 0; i < 15; i = i + 1) begin
            master.axi_write(i[3:0], 32'h1000_0000 + i);
        end
        for (i = 0; i < 15; i = i + 1) begin
            master.axi_read(i[3:0], read_data, read_resp);
            if (read_data == (32'h1000_0000 + i) && read_resp == 2'b00)
                $display("  Addr[%2d] = 0x%h OK", i, read_data);
            else begin
                $display("  Addr[%2d] FAIL: expected 0x%h, got 0x%h resp=%b",
                          i, 32'h1000_0000 + i, read_data, read_resp);
                errors = errors + 1;
            end
        end
 
        // Confirm address 15 (0xF) is still out of range after all writes
        master.axi_read(4'hF, read_data, read_resp);
        if (read_resp == 2'b10)
            $display("PASS: TEST 5b - addr 0xF still SLVERR after full sweep");
        else begin
            $display("FAIL: TEST 5b - addr 0xF should remain SLVERR");
            errors = errors + 1;
        end
 
        #50;
        if (errors == 0)
            $display("\n=== ALL TESTS PASSED ===");
        else
            $display("\n=== %0d TEST(S) FAILED ===", errors);
 
        $finish;
    end
 
endmodule
 