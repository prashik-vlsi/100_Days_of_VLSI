module async_fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // write side
    input  wr_clk,
    input  wr_en,
    input  [ADDR_WIDTH-1:0] wr_addr,
    input  [DATA_WIDTH-1:0] wr_data,

    // read side
    input  [ADDR_WIDTH-1:0] rd_addr,
    output [DATA_WIDTH-1:0] rd_data
);
reg [DATA_WIDTH-1:0] mem [0 : 2**ADDR_WIDTH - 1];

always @(posedge wr_clk)begin
    if(wr_en==1)begin
        mem[wr_addr]<= wr_data;
    end

end

assign rd_data=mem[rd_addr];
endmodule

