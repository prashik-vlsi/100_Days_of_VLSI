module ahb_slave #(
    parameter ADDR_WIDTH = 32,
     parameter DATA_WIDTH = 32
)(  
    input wire                   HCLK,
    input wire                   HRESETn,
    input wire [ADDR_WIDTH-1:0]  HADDR,
    input wire                   HWRITE,
    input wire [2:0]             HSIZE,
    input wire [2:0]             HBURST,
    input wire [1:0]             HTRANS,
    input wire [3:0]             HPROT,
    input wire [DATA_WIDTH-1:0]  HWDATA,
    input wire                   HSELx,
    input wire                   HREADY,

    output  reg [DATA_WIDTH-1:0] HRDATA,
   
    output  reg                  HREADYOUT,
    output  reg                  HRESP
);

reg [2:0] clk_cnt;
reg [31:0] addr_reg;
reg        write_reg;
reg [31:0] mem_array [0:1023];

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        addr_reg  <= 32'd0;
        write_reg <= 1'b0;
    end
    else if (HSELx && HREADY && HTRANS[1]) begin
        addr_reg  <= HADDR;
        write_reg <= HWRITE;
    end
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        // Memory reset optional
    end
    else if (write_reg) begin
        mem_array[addr_reg[11:2]] <= HWDATA;
    end
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        clk_cnt   <= 3'b000;
        HREADYOUT <= 1'b1;
    end
    else if (HSELx && HREADY && HTRANS[1]) begin
        clk_cnt   <= 3'b010;   // load 2 wait cycles
        HREADYOUT <= 1'b0;
    end
    else if (clk_cnt != 0) begin
        clk_cnt   <= clk_cnt - 1'b1;
        HREADYOUT <= 1'b0;
    end
    else begin
        HREADYOUT <= 1'b1;
    end
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        HRESP <= 1'b0;
    else if (addr_reg[31:12] != 0)
        HRESP <= 1'b1;
    else
        HRESP <= 1'b0;
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        HRDATA <= 32'd0;
    else if (!write_reg)
        HRDATA <= mem_array[addr_reg[11:2]];
end
endmodule