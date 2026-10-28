/* ### VLSI Problem — RV32I Dynamic Instruction Test Buffer

You are developing a **SystemVerilog testbench for an RV32I processor**. 
During verification, different test programs may contain different numbers of 32-bit
 instructions. Therefore, a **dynamic array** is used to create an instruction buffer 
 whose size can be changed during simulation.

Write a SystemVerilog testbench that performs the following operations:

1. Declare a dynamic array named `instruction_buffer` capable of storing **32-bit RV32I 
instructions**.

2. Allocate space for **4 instructions** using `new[]`.

3. Store the following instruction words in the buffer:

```text
0x00500093
0x00A00113
0x002081B3
0x00310233
```

4. Display the current number of instructions using the dynamic array `size()` method.

5. Use a `foreach` loop to display every instruction along with its array index 
in hexadecimal format.

6. Assume the verification program is expanded and now requires **6 instructions**.
 Resize the dynamic array from 4 to 6 elements while **preserving all four existing 
 instructions**.

7. Store the following two additional instructions at indexes `4` and `5`:

```text
0x004182B3
0x00520333
```

8. Display the new buffer size and use `foreach` to verify that all six instructions 
are present and that the original four instructions were preserved after resizing.

9. After verification is complete, delete the entire dynamic array using `delete()`.

10. Display the final array size to verify that it has become `0`.

#### Concepts to demonstrate

```text
Dynamic array declaration
new[]
size()
new[size](old_array)
foreach
delete()
```

#### Expected Output Format

```text
========== RV32I INSTRUCTION BUFFER ==========

Initial Buffer Size : 4

Instruction[0] = 00500093
Instruction[1] = 00A00113
Instruction[2] = 002081B3
Instruction[3] = 00310233

Buffer resized...

New Buffer Size : 6

Instruction[0] = 00500093
Instruction[1] = 00A00113
Instruction[2] = 002081B3
Instruction[3] = 00310233
Instruction[4] = 004182B3
Instruction[5] = 00520333

Buffer deleted.

Final Buffer Size : 0
```

**Constraint:** Do not replace the dynamic array with a fixed-size array. 
The program must demonstrate allocation, resizing while preserving existing data,
 iteration using `foreach`, and deletion of dynamic storage.


 */

 module instruction_verification;
    logic[31:0] instruction_buffer [];
    
    initial begin
        instruction_buffer  = new[4];
        instruction_buffer[0]=32'h00500093;
        instruction_buffer[1]=32'h00A00113;
        instruction_buffer[2]=32'h002081B3;
        instruction_buffer[3]=32'h00310233;

        $display("========== RV32I INSTRUCTION BUFFER ==========");

        $display("=======================================================");

        $display("initial buffer size is: %0d", instruction_buffer.size());

        $display("=======================================================");

        foreach (instruction_buffer[i]) begin
            $display("Instruction[%0d] = %h", i, instruction_buffer[i]);
        end

        //resizing the dynamic array from 4 to 6

        instruction_buffer=new[6](instruction_buffer);

        instruction_buffer[4]=32'h004182B3;

        instruction_buffer[5]=32'h00520333;

        $display("The buffer size is: %0d", instruction_buffer.size());

        $display("=======================================================");

        foreach (instruction_buffer[i]) begin
            $display("Instruction[%0d] = %h", i, instruction_buffer[i]);
        end

        instruction_buffer.delete();

        $display("=======================================================");
        $display("The Dynamic array is deleted");
        $display("=======================================================");
        $display("The final array size is: %0d", instruction_buffer.size());


 end

 endmodule
