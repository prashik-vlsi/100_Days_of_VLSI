module handshake_sync_tb;

reg clk_dst;
reg clk_src;
reg rst;
reg req_in;
reg [7:0]data_in;
wire [7:0]data_out;
wire ack_out;

handshake_sync DUT(
    .clk_src(clk_src),
    .clk_dst(clk_dst),
    .rst(rst),
    .data_out(data_out),
    .ack_out(ack_out),
    .data_in(data_in),
    .req_in(req_in)
);

initial begin
    clk_src=0;
    clk_dst=0;
    rst=0;
    req_in=0;
    data_in=0;

end

always #100 clk_src=~clk_src;
always #10 clk_dst=~clk_dst;

initial begin 
    $dumpfile("handshake.vcd");
    $dumpvars(0, handshake_sync_tb);

    rst=1;
    #400;
    rst=0;
    #200;
    data_in = 8'hA5;
    req_in=1;
    #400;
    req_in=0;
    #1000;
    $finish;
end
initial begin
$monitor("Time=%0t rst=%b req_in=%b data_in=%h data_out=%h ack_out=%b",
$time, rst, req_in, data_in, data_out, ack_out);
end
 endmodule

