module sipo_tb;
reg si;
reg clk;
wire [3:0] Q;

sipo DUT(
    .si(si),
    .clk(clk),
    .Q(Q)
);

initial begin
    $dumpfile("sipo_dump.vcd");
    $dumpvars(0, sipo_tb);
end

// Clock + stimulus in ONE block
initial begin
    clk = 0;
    si = 0;
    #2;
    si = 1; #10;
    si = 0; #10;
    si = 1; #10;
    si = 1; #10;
    #20;
    $finish;
end

always #5 clk = ~clk;

// Monitor
initial begin
    $monitor("Time=%0t, si=%b, clk=%b, Q=%b",
              $time, si, clk, Q);
end

endmodule
