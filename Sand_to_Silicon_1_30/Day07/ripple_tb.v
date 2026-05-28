module ripple_tb;
    reg rst;
    reg clk;
    wire [3:0]q;

ripple_counter DUT(

    .rst(rst),
    .clk(clk),
    .q(q)
);


always #5 clk=~clk;

initial begin
$dumpfile("rc.vcd");
$dumpvars(0, ripple_tb);
end 

initial begin
clk=0;
rst=1; #20;

rst=0; #160;
 
 $finish;

 end 
 initial begin
 $monitor("Time=%0t, rst=%b, clk=%b, q=%b",
 $time, rst, clk, q);
 end 
 endmodule

