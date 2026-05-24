module ripple_tb;

reg [3:0] a, b;
reg cin;
wire [3:0] sum;
wire cout;


ripple uut(

    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);

initial begin
$dumpfile("ripple_dump.vcd");
$dumpvars(0, ripple_tb);
a=0; b=0; cin=0; #10;
    a=0; b=0; cin=1;  #10;
    a=0; b=1; cin=0; #10;
    a=0; b=1; cin=1; #10;
    a=1; b=0; cin=0; #10;
    a=1; b=0; cin=1; #10;
    a=1; b=1; cin=0; #10;
    a=1; b=1; cin=1; #10;
   
   $finish;
end
 initial begin
    $monitor("Time=%0t a=%b b=%b cin=%b sum=%b cout=%b",
    $time, a, b, cin, sum, cout);
end

endmodule


