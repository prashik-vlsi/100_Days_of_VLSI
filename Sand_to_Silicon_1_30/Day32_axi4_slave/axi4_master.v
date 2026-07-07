//=============================================================
// AXI4-Lite Master (BFM) with proper valid/ready handshake
// tasks, plus rready/bready pulse helpers.
//=============================================================
module axi4_lite_master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
)(
    input  wire                     clk,
    input  wire                     rst_n,
 
    output reg  [ADDR_WIDTH-1:0]    awaddr,
    output reg                      awvalid,
    input  wire                     awready,
 
    output reg  [DATA_WIDTH-1:0]    wdata,
    output reg  [(DATA_WIDTH/8)-1:0] wstrb,
    output reg                      wvalid,
    input  wire                     wready,
 
    input  wire [1:0]               bresp,
    input  wire                     bvalid,
    output reg                      bready,
 
    output reg  [ADDR_WIDTH-1:0]    araddr,
    output reg                      arvalid,
    input  wire                     arready,
 
    input  wire [DATA_WIDTH-1:0]    rdata,
    input  wire [1:0]               rresp,
    input  wire                     rvalid,
    output reg                      rready
);
 
    initial begin
        awaddr  = 0; awvalid = 0;
        wdata   = 0; wstrb = 0; wvalid = 0;
        bready  = 0;
        araddr  = 0; arvalid = 0;
        rready  = 0;
    end
 
    task write_addr_phase(input [ADDR_WIDTH-1:0] addr);
        begin
            @(posedge clk);
            awaddr  <= addr;
            awvalid <= 1'b1;
            @(posedge clk);
            while (!awready) @(posedge clk);
            awvalid <= 1'b0;
        end
    endtask
 
    task write_data_phase(input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            wdata  <= data;
            wstrb  <= 4'hF;
            wvalid <= 1'b1;
            @(posedge clk);
            while (!wready) @(posedge clk);
            wvalid <= 1'b0;
        end
    endtask
 
    // Full write: address + data + wait for response, auto bready pulse
    task automatic axi_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            fork
                write_addr_phase(addr);
                write_data_phase(data);
            join
            wait (bvalid);
            @(posedge clk);
            bready <= 1'b1;
            @(posedge clk);
            bready <= 1'b0;
        end
    endtask
 
    task read_addr_phase(input [ADDR_WIDTH-1:0] addr);
        begin
            @(posedge clk);
            araddr  <= addr;
            arvalid <= 1'b1;
            @(posedge clk);
            while (!arready) @(posedge clk);
            arvalid <= 1'b0;
        end
    endtask
 
    // Full read: address phase + wait for rvalid + pulse rready
    task automatic axi_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data, output [1:0] resp);
        begin
            read_addr_phase(addr);
            wait (rvalid);
            @(posedge clk);
            rready <= 1'b1;
            data = rdata;
            resp  = rresp;
            @(posedge clk);
            rready <= 1'b0;
        end
    endtask
 
endmodule