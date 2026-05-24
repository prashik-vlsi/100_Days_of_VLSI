module fulladder_tb;

reg a;
reg b;
reg c;
wire sum;
wire carry;

fulladder uut(

    .a(a),
    .b(b),
    .c(c),
    .sum(sum),
    .carry(carry)


);

initial begin
$dumpfile("full_dump.vcd");
$dumpvars(0, fulladder_tb);

   a=0; b=0; c=0; #10;
    a=0; b=0; c=1;  #10;
    a=0; b=1; c=0; #10;
    a=0; b=1; c=1; #10;
    a=1; b=0; c=0; #10;
    a=1; b=0; c=1; #10;
    a=1; b=1; c=0; #10;
    a=1; b=1; c=1; #10;
   
   $finish;
end
 initial begin
    $monitor("Time=%0t a=%b b=%b c=%b sum=%b carry=%b",
    $time, a, b, c, sum, carry);
end

endmodule

