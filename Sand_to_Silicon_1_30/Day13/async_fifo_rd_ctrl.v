module async_fifo_rd_ctrl#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input rd_clk,
    input rd_en,
    input rd_rst,

    input       [ADDR_WIDTH:0]wr_ptr_gray_sync,
    output  [ADDR_WIDTH:0]rd_ptr_gray,
    output   [ADDR_WIDTH-1:0] rd_addr,
    output  empty
);
reg [ADDR_WIDTH:0] rd_ptr;
assign rd_addr = rd_ptr[ADDR_WIDTH-1:0];

 
always @(posedge rd_clk)begin
    if(rd_rst==1)
        rd_ptr<=5'b00000;
    else if(rd_en==1 && !empty)
        rd_ptr<= rd_ptr+1;
end

assign rd_ptr_gray = rd_ptr ^ (rd_ptr >> 1);

assign empty = wr_ptr_gray_sync==rd_ptr_gray;
endmodule