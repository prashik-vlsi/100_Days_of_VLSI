module apb_uart_top (
    input wire clk,
    input wire rst_n,
    input wire [31:0] PADDR,
    input wire [31:0] PWDATA,
    input wire pwrite,
    input wire penable,
    input wire psel,
    output wire [31:0] PRDATA,
    output wire pready
);

apb_uart dut (
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

endmodule