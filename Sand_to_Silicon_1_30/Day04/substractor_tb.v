module substractor_tb;

reg a;
reg b;
reg bin;
wire diff;
wire bout;

substractor uut(

    .a(a),
    .b(b),
    .bin(bin),
    .diff(diff),
    .bout(bout)
);

initial begin
$dumpfile("sub_dump.vcd");
$dumpvars(0, substractor_tb);

    a = 0; b = 0; bin = 0; #10;
    a = 0; b = 0; bin = 1; #10;
    a = 0; b = 1; bin = 0; #10;
    a = 0; b = 1; bin = 1; #10;
    a = 1; b = 0; bin = 0; #10;
    a = 1; b = 0; bin = 1; #10;
    a = 1; b = 1; bin = 0; #10;
    a = 1; b = 1; bin = 1; #10;

$finish;
end

initial begin
$monitor("Time =%0t, a=%b, b=%b, bin=%b, bout=%b, diff=%b",
$time, a, b, bin, bout, diff);

end 
endmodule