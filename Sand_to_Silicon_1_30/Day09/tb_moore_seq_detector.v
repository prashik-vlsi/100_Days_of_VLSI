module tb_moore_seq_detector;
reg rst;
reg in;
reg clk;
wire out;

moore_seq_detector DUT(

    .rst(rst),
    .clk(clk),
    .in(in),
    .out(out)
);

always #5 clk=~clk;

initial begin 

$dumpfile("moore.vcd");
$dumpvars(0, tb_moore_seq_detector);

end
initial begin 
rst =1  ;
clk=0;
in=0;
 #20;
    rst = 0;

    // Feed sequence: 1 0 1 1 0 1 0 1 1

    @(posedge clk) in = 1;
    @(posedge clk) in = 0;
    @(posedge clk) in = 1;
    @(posedge clk) in = 1;
    @(posedge clk) in = 0;
    @(posedge clk) in = 1;
    @(posedge clk) in = 0;
    @(posedge clk) in = 1;
    @(posedge clk) in = 1;

    // Wait a few cycles
    #20;

    $finish;

end

initial begin
$monitor ("Time=%0t, rst=%b, clk=%b, in=%b, out=%b",
$time, rst, clk, in, out);

end  
endmodule

