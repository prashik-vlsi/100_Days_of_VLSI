module async_fifo#(
    parameter DATA_WIDTH=8,
    parameter ADDR_WIDTH=4
)

    (
    input wr_rst,
    input rd_rst,
    input wr_clk,
    input rd_clk,
    input wr_en,
    input rd_en,
   input  [DATA_WIDTH-1:0] wr_data,
    output [DATA_WIDTH-1:0] rd_data,
    output full,

    output empty
);

wire [ADDR_WIDTH-1:0] wr_addr;
wire [ADDR_WIDTH-1:0] rd_addr;
wire [ADDR_WIDTH:0]   wr_ptr_gray;
wire [ADDR_WIDTH:0]   rd_ptr_gray;
wire [ADDR_WIDTH:0]   wr_ptr_gray_sync;
wire [ADDR_WIDTH:0]   rd_ptr_gray_sync;
async_fifo_mem #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_mem (
    .wr_clk  (wr_clk),
    .wr_en   (wr_en),
    .wr_addr (wr_addr),
    .wr_data (wr_data),
    .rd_addr (rd_addr),
    .rd_data (rd_data)
); 
 async_fifo_wr_ctrl #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_wr_ctrl (
    .wr_clk          (wr_clk),
    .wr_en           (wr_en),
    .wr_rst          (wr_rst),
    .rd_ptr_gray_sync(rd_ptr_gray_sync),
    .wr_ptr_gray     (wr_ptr_gray),
    .wr_addr         (wr_addr),
    .full            (full)
);
async_fifo_rd_ctrl #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_rd_ctrl (
    .rd_clk          (rd_clk),
    .rd_en           (rd_en),
    .rd_rst          (rd_rst),
    .wr_ptr_gray_sync(wr_ptr_gray_sync),
    .rd_ptr_gray     (rd_ptr_gray),
    .rd_addr         (rd_addr),
    .empty           (empty)
);
// Sync 1 — wr_ptr_gray → read domain
reg [ADDR_WIDTH:0] wr_ptr_gray_sync1;
reg [ADDR_WIDTH:0] wr_ptr_gray_sync2;

always @(posedge rd_clk) begin
    wr_ptr_gray_sync1 <= wr_ptr_gray;
    wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
end

assign wr_ptr_gray_sync = wr_ptr_gray_sync2;


// Sync 2 — rd_ptr_gray → write domain
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1;
reg [ADDR_WIDTH:0] rd_ptr_gray_sync2;

always @(posedge wr_clk) begin
    rd_ptr_gray_sync1 <= rd_ptr_gray;
    rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
end

assign rd_ptr_gray_sync = rd_ptr_gray_sync2;
endmodule