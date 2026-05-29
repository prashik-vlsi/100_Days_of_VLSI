module ring_counter_tb;
    reg rst;
    reg clk;
    wire [3:0]Q;
ring_counter DUT(

    .rst(rst),
    .clk(clk),
    .Q(Q)
);

always #5 clk=~clk;


initial begin
$dumpfile("ring.vcd");
$dumpvars(0, ring_counter_tb);
end 

initial begin
clk=0;
rst=1; #20;

rst=0; #160;
 
 $finish;

 end 
 initial begin
 $monitor("Time=%0t, rst=%b, clk=%b, Q=%b",
 $time, rst, clk, Q);
 end 
 endmodule




