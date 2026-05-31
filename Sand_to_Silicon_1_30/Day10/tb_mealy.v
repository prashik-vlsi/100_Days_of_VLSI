module tb_mealy;

    reg rst;
    reg in;
    reg clk;
    wire out;
mealy DUT(

    .rst(rst),
    .in(in),
    .clk(clk),
    .out(out)
);

always #5 clk=~clk;
initial begin
 $dumpfile("mealy.vcd");
 $dumpvars(0, tb_mealy);
 end

 initial begin 
rst=1;
clk=0;
in=0;

#20

rst=0;

    @(posedge clk) in = 1;
    @(posedge clk) in = 0;
    @(posedge clk) in = 1;
    @(posedge clk) in = 1;
    @(posedge clk) in = 0;
    @(posedge clk) in = 1;
    @(posedge clk) in = 0;
    @(posedge clk) in = 1;
    @(posedge clk) in = 1;

    // Wait a few cycles
    #20;

    $finish;
end 

initial begin
$monitor ("Time=%0t, rst=%b, clk=%b, in=%b, out=%b",
$time, rst, clk, in, out);

end  
endmodule

 
