/* 
### VLSI Problem — RV32I Expected Result Queue

You are developing a SystemVerilog testbench for an RV32I processor. 
The testbench must keep track of the expected 32-bit results of instructions before 
comparing them with the actual results produced by the processor.

Since instruction results must normally be checked in the same order in which they 
are expected, use a **SystemVerilog queue** to implement an expected-result buffer.

Declare a queue named:

```systemverilog
logic [31:0] expected_results[$];
```

Perform the following operations:

1. Insert the following three expected ALU results at the **back of the queue**
 using `push_back()`:

```text
10
20
30
```

2. A high-priority expected result with value `5` must now be checked before
 all existing results. Insert it at the **front of the queue** using `push_front()`.

3. Display the current queue size using `size()`.

4. Use `foreach` to display every value currently stored in the queue along with its index.

At this point, the queue should logically contain:

```text
FRONT                    BACK
  ↓                        ↓
[5] [10] [20] [30]
```

5. Simulate checking the oldest/highest-priority expected result by removing the value from 
the **front** using `pop_front()`. Store the removed value in a 32-bit variable and display it.

6. For debugging, remove the most recently added result from the **back** using `pop_back()`. 
Store and display the removed value.

7. Display all values remaining in the queue using `foreach`.

8. Display the final queue size.

The program must demonstrate the following SystemVerilog queue operations:

```text
push_front()
push_back()
pop_front()
pop_back()
size()
foreach
```

### Expected logical behaviour

```text
After insertion:

[5] [10] [20] [30]

pop_front()
     ↓
Removed = 5

Remaining:
[10] [20] [30]

pop_back()
     ↓
Removed = 30

Final Queue:
[10] [20]

Final Queue Size = 2
```

### VLSI relevance

This queue represents a simplified **verification scoreboard/reference-result buffer**. In a future RV32I testbench, expected instruction results can be inserted into a queue and removed when the DUT produces corresponding results.

The queue is being used as a **testbench data structure**, not as the implementation of a synthesizable hardware FIFO.

*/

module queue;

    logic [31:0] expected_results[$];
    logic [31:0] a;
    logic [31:0] b;

    
    initial begin

        $display("The element push at the back of queue are as follow");
        expected_results.push_back(10);
        expected_results.push_back(20);
        expected_results.push_back(30);

        foreach (expected_results[i]) begin
            $display("expected result [%0d] = %h",i, expected_results[i]);
        end

        expected_results.push_front(5);

        $display("=========================================================");
        $display("The size of the queue is: %0d", expected_results.size());
        $display("=========================================================");


        foreach (expected_results[i]) begin
            $display("expected result [%0d]= %h", i, expected_results[i]);
        end

        a=expected_results.pop_front();

        $display("The recently popped element is: %0d", a);


         foreach (expected_results[i]) begin
            $display("expected result [%0d]= %h", i, expected_results[i]);
        end

    end

endmodule
