module mux2_1_tb;

reg s;
reg i0;
reg i1;
wire y;

mux2_1 uut(

    .s(s),
    .i0(i0),
    .i1(i1),
    .y(y)
);

initial begin 
$dumpfile("mux2_1_dump.vcd");
$dumpvars(0, mux2_1_tb);

s=0; i0=0; i1=0; #10;
s=0; i0=1; i1=0; #10;
s=1; i0=0; i1=0; #10;
s=1; i0=0; i1=1; #10;

$finish;

end 
initial begin

$monitor("Time=%0t, s=%b, i0=%b, i1=%b, y=%b",
$time, s, i0, i1, y);

end 
endmodule
