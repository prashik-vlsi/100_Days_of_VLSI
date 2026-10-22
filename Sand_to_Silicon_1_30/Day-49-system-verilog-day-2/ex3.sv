/*
Problem Statement
Design a SystemVerilog module that demonstrates the difference between 
bitwise operators and logical operators.
 The module should operate on two 4-bit variables and display 
 the results of different operations.

Declare two 4-bit variables, a and b, using the logic data type.
 Inside an initial block, assign the following values:
a = 4'b1011
b = 4'b0110

Perform bitwise AND, bitwise OR, bitwise XOR, and bitwise NOT 
operations on these variables. Also perform logical AND between a and b, and logical NOT on b.

Display the result of each operation using $display.
Requirements
1. Create a module named ex3_practice.
2. Use logic [3:0] for both a and b.
3. Perform all six operations using the appropriate SystemVerilog operators.
4. Do not hardcode the calculated outputs.
5. Do not use assign; perform the operations inside the initial block.
6. Before running the program, predict all six outputs on paper.

*/

module ex3;
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] out;
    

    initial begin
        a=4'b0110;
        b=4'b1011;
        out = a&b;
        $display("output of bitwise and operation is: %b", out);   
        out = a|b;
        $display("output of bitwise or operation is: %b", out);   
        out = a^b;
        $display("output of bitwise x-or operation is: %b", out);   
        out = ~a;
        $display("output of bitwise negation operation is:%b", out);   
        out = a&&b;
        $display("output of logical and operation is %b:", out);   
        out = !a;
        $display("output of logical not operation is %b:", out);   
        
    end
    
endmodule
