`timescale 1ns/1ps

module sync_fifo_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0]wr_data;
    wire [7:0]rd_data;
    wire full;
    wire empty;

sync_fifo DUT(

   .clk(clk),
   .rst(rst),
   .wr_en(wr_en),
   .rd_en(rd_en),
   .wr_data(wr_data),
   .rd_data(rd_data),
   .full(full),
   .empty(empty)
);

initial begin
    clk=0;
end

always #5 clk=~clk;

initial begin

$dumpfile("fifo.vcd");
$dumpvars(0, sync_fifo_tb);

rst=1;
wr_en=0;
rd_en=0;
wr_data=0;

#20;
rst=0;

wr_en=1;

@(negedge clk);
wr_data=8'hA1;

@(negedge clk);
wr_data=8'hA2;

@(negedge clk);
wr_data=8'hA3;

@(negedge clk);
wr_data=8'hA4;

@(negedge clk);
wr_data=8'hA5;

@(posedge clk);
#10;
wr_en=0;

rd_en=1;

repeat(5) begin

    @(negedge clk);

    $display(
        "Time=%0t, rd_ptr=%0d, rd_data=%h, empty=%b",
        $time,
        DUT.rd_ptr,
        rd_data,
        empty
    );

    @(posedge clk);

end

rd_en=0;

#20;
$finish;

end

initial begin

$monitor(
"Time=%0t, rst=%b, clk=%b, wr_en=%b, rd_en=%b, wr_data=%h, rd_data=%h, full=%b, empty=%b",
$time,
rst,
clk,
wr_en,
rd_en,
wr_data,
rd_data,
full,
empty
);

end

endmodule