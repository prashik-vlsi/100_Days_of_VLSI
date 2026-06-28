`timescale 1ns/1ps

module abp_peripheral_tb;
parameter TB_DATA_WIDTH = 32;
parameter TB_ADDR_WIDTH = 32;

reg                        tb_clk;
reg                        tb_rst_n;
reg  [TB_ADDR_WIDTH-1:0]   tb_paddr;
reg                        tb_psel;
reg                        tb_penable;
reg                        tb_pwrite;
reg  [TB_DATA_WIDTH-1:0]   tb_pwdata;

wire [TB_DATA_WIDTH-1:0]   tb_prdata;
wire                       tb_pready;
wire                       tb_pslverr;
wire                       tb_done_out;

apb_timer_peripheral #(
    .DATA_WIDTH ( TB_DATA_WIDTH ),
    .ADDR_WIDTH ( TB_ADDR_WIDTH )
) u_dut (
    .clk        ( tb_clk      ),
    .rst_n      ( tb_rst_n    ),
    .paddr      ( tb_paddr    ),
    .psel       ( tb_psel     ),
    .penable    ( tb_penable  ),
    .pwrite     ( tb_pwrite   ),
    .pwdata     ( tb_pwdata   ),
    .prdata     ( tb_prdata   ),
    .pready     ( tb_pready   ),
    .pslverr    ( tb_pslverr  ),
    .done_out   ( tb_done_out )
);

always #5 tb_clk =~tb_clk;

initial begin 
    $dumpfile("peripheral.vcd");
    $dumpvars(0, abp_peripheral_tb);
    $monitor("Time=%0t | done_out=%b | pslverr=%b | prdata=%h | pready=%b",
          $time, tb_done_out, tb_pslverr, tb_prdata, tb_pready);

    tb_clk =0;
    tb_rst_n=0;
    #10;
    
    tb_rst_n=1;
    #10;
    //cycle1 transaction
    tb_psel =1'b1;
    tb_pwrite =1'b1;
    tb_paddr = 32'h00;


    tb_pwdata = 32'h05;  // data to write
    tb_paddr  = 32'h00;  // address of load register
    tb_pwrite = 1'b1;    // this is a write
    #10;
    tb_penable = 1'b1;
     #10;

tb_psel    = 1'b0;
tb_penable = 1'b0;
tb_pwrite  = 1'b0;
#10;

tb_paddr  = 32'h04;  // which register starts timer
tb_pwdata = 32'h01;   // what value starts it
tb_psel    = 1'b1;
tb_pwrite  = 1'b1;
#10
tb_penable = 1'b1;
#10
tb_psel    = 1'b0;
tb_penable = 1'b0;
tb_pwrite  = 1'b0;
#10;
// wait for timer done
    @(posedge tb_done_out);
    #10;
    $display("done_out fired — ECG sampling window complete");

    // read status register
    tb_psel    = 1'b1;
    tb_pwrite  = 1'b0;
    tb_paddr   = 32'h08;
    #10;
    tb_penable = 1'b1;
    #10;
    tb_psel    = 1'b0;
    tb_penable = 1'b0;
    #10;
    $display("stat_reg = %0b", tb_prdata[0]);

    // test invalid address — PSLVERR
    tb_psel    = 1'b1;
    tb_pwrite  = 1'b1;
    tb_paddr   = 32'hFF;
    tb_pwdata  = 32'hDEAD;
    #10;
    tb_penable = 1'b1;
    #10;
    tb_psel    = 1'b0;
    tb_penable = 1'b0;
    tb_pwrite  = 1'b0;
    #10;
    $display("pslverr = %0b", tb_pslverr);

    $finish;
end
endmodule