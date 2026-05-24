module halfadder_tb;

reg a;
reg b;
wire sum;
wire carr;

halfadder uut(

    .a(a),
    .b(b),
    .sum(sum),
    .carr(carr)


);

initial begin 

$dumpfile("ha_dump.vcd");
$dumpvars(0, halfadder_tb);

a=0; b=0; #10;
a=0; b=1; #10;
a=1;  b=0; #10;
a=1; b=1; #10;


$finish;

end 
   initial begin
    $monitor("Time=%0t a=%b b=%b  sum=%b carr=%b",
    $time, a, b, sum, carr);
end

endmodule

