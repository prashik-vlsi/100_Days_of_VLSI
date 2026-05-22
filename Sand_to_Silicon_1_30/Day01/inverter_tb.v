module inverter_tb;
reg a;
wire y;
inverter uut(.a(a),.y(y));
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,inverter_tb);
a=0; #10;
a=1; #10;
a=0; #10;
$finish;
end
initial begin
$monitor("Time=%0t a=%b y=%b",$time,a,y);
end
endmodule
