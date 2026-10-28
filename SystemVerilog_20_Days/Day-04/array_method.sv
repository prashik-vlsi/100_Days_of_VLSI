/* 
VLSI Problem — Register File Verification Analyzer
You are verifying a small processor register file. After running several test instructions, the following 32-bit values were captured from eight registers:
logic [31:0] reg_data[8] = '{
    32'd120,
    32'd45,
    32'd300,
    32'd75,
    32'd10,
    32'd250,
    32'd90,
    32'd180
};

Write a SystemVerilog testbench module that analyzes the captured register 
values using array methods.

Your testbench must determine the 
1) number of register entries using  size(), 
2) calculate the sum of all captured register values using sum(), 
3) obtain the smallest and largest register values using min() and max(),
4) and use find() to collect every register value greater than 32'd100.

Finally, display all results in the simulator terminal.

You are not allowed to manually hard-code the calculated answers.
Required methods
size()
sum()
min()
max()
find()

========== REGISTER FILE ANALYSIS ==========

Number of registers : ...
Sum of values       : ...
Minimum value       : ...
Maximum value       : ...

Values > 100:
...

*/

module analyzer;
logic [31:0] reg_data[8] = '{
    32'd120,
    32'd45,
    32'd300,
    32'd75,
    32'd10,
    32'd250,
    32'd90,
    32'd180
};
initial begin

    logic [31:0] minimum[$];
    logic [31:0] maximum[$];
    logic [31:0] result[$];

    $display("========================== REGISTER FILE ANALYSIS=================================");

    $display("No of registers are: %0d", $size(reg_data));

    $display("Sum of all the value in register are: %0d", reg_data.sum());

    minimum=reg_data.min();
    maximum = reg_data.max();


    $display("The minimum value is: %0d", minimum[0]);
    $display("the maximum value is; %0d", maximum[0]);


    result = reg_data.find(x) with (x>32'd100);

    $display("The value greater than 32'd100 are: %p", result);
    
    end 

endmodule 





