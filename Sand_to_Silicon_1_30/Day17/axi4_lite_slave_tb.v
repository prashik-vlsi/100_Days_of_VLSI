`timescale 1ns/1ps
module axi4_lite_slave_tb;

reg         aclk;
reg         rst_n;
reg         awvalid;
reg         wvalid;
reg  [31:0] wdata;
reg  [31:0] awaddr;
reg  [3:0]  wstrb;
reg         bready;
reg         rready;
reg         arvalid;
reg  [31:0] araddr;

wire        awready;
wire        wready;
wire        rvalid;
wire [1:0]  bresp;
wire        bvalid;
wire [31:0] rdata;
wire        arready;
wire [1:0]  rresp;

axi4_lite_slave uut (
    .aclk(aclk),
    .rst_n(rst_n),
    .awvalid(awvalid),
    .wvalid(wvalid),
    .wdata(wdata),
    .awaddr(awaddr),
    .wstrb(wstrb),
    .bready(bready),
    .rready(rready),
    .arvalid(arvalid),
    .araddr(araddr),
    .awready(awready),
    .wready(wready),
    .rvalid(rvalid),
    .bresp(bresp),
    .bvalid(bvalid),
    .rdata(rdata),
    .arready(arready),
    .rresp(rresp)
);

always #10 aclk = ~aclk;

initial begin
    aclk    = 0;
    awvalid = 0;
    wvalid  = 0;
    wdata   = 0;
    awaddr  = 0;
    wstrb   = 0;
    bready  = 0;
    arvalid = 0;
    araddr  = 0;
    rready  = 0;
    rst_n   = 0;

    $dumpfile("dump.vcd");
    $dumpvars(0, axi4_lite_slave_tb);

    #20;
    rst_n = 1;

    // TEST 1 - Write 0xA5 to SAMPLE_RATE_REG
    @(posedge aclk);
    awaddr  = 32'h00;
    wdata   = 32'hA5;
    awvalid = 1'b1;
    wvalid  = 1'b1;
    wstrb   = 4'b1111;
    bready  = 1'b1;

    @(posedge aclk);
    @(posedge aclk);
    awvalid = 1'b0;
    wvalid  = 1'b0;
    wstrb   = 4'b0000;
    bready  = 1'b0;

    @(posedge aclk);
    @(posedge aclk);

    // TEST 2 - Read SAMPLE_RATE_REG
    $display("TEST2 starting at time=%0t", $time);
    @(posedge aclk);
    araddr  = 32'h00;
    arvalid = 1'b1;
    rready  = 1'b0;

    @(posedge aclk);
    @(posedge aclk);
    rready = 1'b1;

    @(posedge aclk);
    $display("rdata=%h rresp=%b rvalid=%b", rdata, rresp, rvalid);
    arvalid = 1'b0;
    rready  = 1'b0;

    @(posedge aclk);
    $finish;
end

initial begin
    $display("simulation started");
    $monitor("Time=%0t | awvalid=%b awready=%b wvalid=%b wready=%b bvalid=%b bresp=%b | arvalid=%b arready=%b rvalid=%b rdata=%h rresp=%b",
    $time, awvalid, awready, wvalid, wready, bvalid, bresp, arvalid, arready, rvalid, rdata, rresp);
end

endmodule