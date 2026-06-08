module async_fifo_wr_ctrl#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wr_clk,
    input wr_en,
    input wr_rst,
    input   [ADDR_WIDTH:0]rd_ptr_gray_sync,
    output  [ADDR_WIDTH:0]wr_ptr_gray,
    output  [ADDR_WIDTH-1:0] wr_addr,
    output  full
);
reg [ADDR_WIDTH:0] wr_ptr;
assign wr_addr = wr_ptr[ADDR_WIDTH-1:0];


always @(posedge wr_clk)begin
    if(wr_rst==1)
        wr_ptr<=5'b00000;
    else if(wr_en==1 && !full)
        wr_ptr<= wr_ptr+1;
end

assign wr_ptr_gray = wr_ptr ^ (wr_ptr >> 1);

assign full = (wr_ptr_gray[ADDR_WIDTH]   != rd_ptr_gray_sync[ADDR_WIDTH])   &&
              (wr_ptr_gray[ADDR_WIDTH-1] != rd_ptr_gray_sync[ADDR_WIDTH-1]) &&
              (wr_ptr_gray[ADDR_WIDTH-2] == rd_ptr_gray_sync[ADDR_WIDTH-2]) &&
              (wr_ptr_gray[ADDR_WIDTH-3] == rd_ptr_gray_sync[ADDR_WIDTH-3]) &&
              (wr_ptr_gray[ADDR_WIDTH-4] == rd_ptr_gray_sync[ADDR_WIDTH-4]);

endmodule