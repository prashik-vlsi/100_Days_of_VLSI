module demux_tb;

reg s;
reg i;
wire y0;
wire y1;

demux uut(

    .s(s),
    .i(i),
    .y0(y0),
    .y1(y1)
);

initial begin
$dumpfile("demux_dump.vcd");
$dumpvars(0, demux_tb);

s=0; i=0; #10;
s=0; i=1; #10;
s=1; i=0; #10;
s=1; i=1; #10;

$finish;

end

initial begin

$monitor("Time =%0t, s=%b, i=%b, y0=%b, y1=%b", 
$time, s, i, y0, y1);
end 
endmodule