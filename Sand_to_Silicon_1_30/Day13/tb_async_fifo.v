module tb_async_fifo;
reg wr_rst;
reg rd_rst;
reg wr_en;
reg rd_en;
reg wr_clk;
reg rd_clk;
reg [7:0] wr_data;    // 8 bits
wire [7:0] rd_data;   // 8 bits
wire full;
wire empty;
async_fifo #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(4)
) dut (
    .wr_clk  (wr_clk),
    .rd_clk  (rd_clk),
    .wr_rst  (wr_rst),
    .rd_rst  (rd_rst),
    .wr_en   (wr_en),
    .rd_en   (rd_en),
    .wr_data (wr_data),
    .rd_data (rd_data),
    .full    (full),
    .empty   (empty)
);

initial begin
    wr_clk = 0;
    rd_clk = 0;
end

always #5 wr_clk=~wr_clk;
always #1.5 rd_clk=~rd_clk;
initial begin

    $dumpfile("async_fifo.vcd");
$dumpvars(0, tb_async_fifo);
    // Step 1 - Reset
    wr_rst  = 1;
    rd_rst  = 1;
    wr_en   = 0;
    rd_en   = 0;
    wr_data = 0;
    #20;

    // Step 2 - Release reset
    wr_rst = 0;
    rd_rst = 0;
    #10;

// Step 3 - Write 8 samples
@(negedge wr_clk); wr_en = 1;
@(negedge wr_clk); wr_data = 8'hA1;
@(negedge wr_clk); wr_data = 8'hA2;
@(negedge wr_clk); wr_data = 8'hA3;
@(negedge wr_clk); wr_data = 8'hA4;
@(negedge wr_clk); wr_data = 8'hA5;
@(negedge wr_clk); wr_data = 8'hA6;
@(negedge wr_clk); wr_data = 8'hA7;
@(negedge wr_clk); wr_data = 8'hA8;
@(negedge wr_clk); wr_en = 0;

// Step 4 - Wait for sync delay then read
// Step 4 - Read 8 samples
#100;
repeat(8) begin
    @(negedge rd_clk);
    rd_en = 1;
    @(posedge rd_clk);
    @(negedge rd_clk);
    rd_en = 0;
    #20;
end

// Step 6 - Finish
#300;
$finish;
end 
endmodule

