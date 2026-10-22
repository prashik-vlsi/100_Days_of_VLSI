/*Problem Statement
Design a SystemVerilog module to demonstrate the logical left shift (<<) operator on
 an 8-bit binary value.

Declare two 8-bit variables, data and out, using the logic data type. Inside an initial block, 
assign the following value to data:

data = 8'b1011_0110

Perform a logical left shift of data by 3 positions and store the result in out.

Display both the original value of data and the shifted value stored in out in binary format.
Requirements
1. Create a module named shift_practice.
2. Declare data and out as 8-bit logic variables.
3. Assign 8'b1011_0110 to data.
4. Shift data left by 3 positions using the appropriate shift operator.
5. Store the shifted result in out.
6. Use $display to print both values in binary.
7. Do not hardcode the shifted result.

*/
module ex4;
    logic signed [7:0]  a;
    logic[7:0] shifted_output;
    
    initial begin

        a=8'b10110110;

        $display("the original bits are: %b", a);

        shifted_output=a<<2;
        $display("the left shifted by 2 value is: %b", shifted_output);

        shifted_output=a>>2;
        $display("the right shifted by 2 value is: %b", shifted_output);

        shifted_output=a<<<2;
        $display("the arthmetic left shifted by 2 value is: %b", shifted_output);

        shifted_output=a>>>2;
        $display("the arthmetic right shifted by 2 value is: %b", shifted_output);

        end 

endmodule

