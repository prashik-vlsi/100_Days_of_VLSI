`timescale 1ns/1ps

module apb_uart_tb;

reg clk = 0;
reg rst_n;
reg [31:0] PADDR;
reg [31:0] PWDATA;
reg pwrite;
reg psel;
reg penable;
wire [31:0] PRDATA;
wire pready;

apb_uart_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .pwrite(pwrite),
    .penable(penable),
    .psel(psel),
    .PRDATA(PRDATA),
    .pready(pready)
);

always #10 clk = ~clk;

initial begin
    rst_n = 0;
    PADDR = 0;
    PWDATA = 0;
    pwrite = 0;
    psel = 0;
    penable = 0;
    
    #100;
    rst_n = 1;
    #20;

    // Test Case 1: Write and Read 0xA5
    apb_write(32'h00, 32'hA5);
    #40;
    apb_read(32'h04);
    apb_read(32'h08);
    #40;

    // Test Case 2: Write and Read 0x3C
    apb_write(32'h00, 32'h3C);
    #40;
    apb_read(32'h04);
    apb_read(32'h08);

    #100;
    $finish;
end

task apb_write(input [31:0] addr, input [31:0] data);
begin
    @(posedge clk);
    PADDR   = addr;
    PWDATA  = data;
    pwrite  = 1;
    psel    = 1;
    penable = 0;

    @(posedge clk);
    penable = 1;

    @(posedge clk);
    psel    = 0;
    penable = 0;
    pwrite  = 0;
    $display("APB WRITE : ADDR=%h DATA=%h", addr, data);
end
endtask

task apb_read(input [31:0] addr);
begin
    @(posedge clk);
    PADDR   = addr;
    pwrite  = 0;
    psel    = 1;
    penable = 0;

    @(posedge clk);
    penable = 1;

    @(posedge clk);
    $display("APB READ  : ADDR=%h DATA=%h", addr, PRDATA);
    psel    = 0;
    penable = 0;
end
endtask

initial begin
    $dumpfile("apb_uart_dump.vcd");
    $dumpvars(0, apb_uart_tb);
end

endmodule