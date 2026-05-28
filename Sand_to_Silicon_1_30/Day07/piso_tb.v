module piso_tb;
    reg[3:0]D;
    reg load;
    wire s0;
    reg clk;

piso DUT(

    .clk(clk),
    .load(load),
    .s0(s0),
    .D(D)
);
initial begin 
clk =0;
load=0;
D=4'b0000;
end 

always #5 clk=~clk;


initial begin 
$dumpfile("piso_dump.vcd");
$dumpvars(0, piso_tb);
end

initial begin
    // Step 1: Load data
    #10;
    load = 1;
    D = 4'b1011;

    // hold load for one clock
    #10;
    load = 0;

    // Step 2: observe shifting
    #40;

    $finish;
end

initial begin
$monitor ("Time=%0t, clk=%b, s0=%b, load=%b, D=%b",
$time, clk, s0, load, D);
end 

endmodule


