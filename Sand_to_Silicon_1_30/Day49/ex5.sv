/*

Problem Statement
Design a 4-bit 2:1 Multiplexer (MUX) using SystemVerilog and the ternary operator (?:). 
The multiplexer has two 4-bit inputs a and b, a 1-bit select signal sel, and a 4-bit output y.

The output should follow these conditions:
- When sel = 0, y should select input b.
- When sel = 1, y should select input a.
Use a = 4'b1010 and b = 4'b0101. Test the multiplexer for both values 
of sel and display the output in binary format.

Do not use an if-else statement. Implement the selection using only the ternary operator.

*/

module mux2_1;
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] y;
    logic sel;
initial begin
    a= 4'b1111;
    b= 4'b0000;
    sel=1'b0;

    y= sel ? a : b;
    $display("the output of mux here is: %b", y);
end
endmodule