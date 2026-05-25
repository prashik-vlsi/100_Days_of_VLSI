module comparator_tb;

reg a;
reg b;
wire eq;
wire gt;
wire ls;

comparator uut(

    .a(a),
    .b(b),
    .eq(eq),
    .gt(gt),
    .ls(ls)
);

initial begin
$dumpfile("comp_dump.vcd");
$dumpvars(0, comparator_tb);

a=0; b=0; #10;
a=0; b=1; #10;
a=1; b=0; #10;
a=1; b=1; #10;

$finish;
end

initial begin
    $monitor("Time=%0t, a=%b, b=%b, eq=%b, gt=%b, ls=%b", 
    $time, a, b, eq, gt, ls);
    end 
 endmodule
