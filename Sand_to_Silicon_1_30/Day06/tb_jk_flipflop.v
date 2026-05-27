module tb_jk_flipflop;

reg j;
reg k;
reg clk;
wire Q;
wire Qbar;

jk_flipflop DUT(

    .j(j),
    .k(k),
    .clk(clk),
    .Q(Q),
    .Qbar(Qbar)
);
 
initial begin
    $dumpfile("jk_dump.vcd");
    $dumpvars(0, tb_jk_flipflop);
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    j=0; k=0; #10;
    j=0; k=1; #10;
    j=1; k=0; #10;
    j=1; k=1; #10;
    $finish;
end

initial begin
    $monitor("Time=%0t, j=%b, k=%b, clk=%b, Q=%b, Qbar=%b",
              $time, j, k, clk, Q, Qbar);
end
 endmodule