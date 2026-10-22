# Day 49 — SystemVerilog Day 2

**Arrays, Operators, Data Manipulation & RTL Fundamentals**

`100_Days_of_VLSI / Sand_to_Silicon_1_30 / Day-49-system-verilog-day-2`

---

## Overview

Day 2 of SystemVerilog moves from basic syntax to the constructs used every day in RTL datapath design: array types, bit- and byte-level manipulation, operator semantics, vector construction, multiplexing, and arithmetic width control. The session ends with a reusable, parameterized adder.

All examples were compiled and simulated locally; the outputs shown below are the observed simulator results.

## Tools Used

| Item | Detail |
|---|---|
| Language | SystemVerilog (IEEE 1800-2012 mode) |
| Simulator | Icarus Verilog 12.0 (`-g2012`) |
| Editor | VS Code |
| OS | Linux / Ubuntu |

```bash
iverilog -g2012 -o <output> <source>.sv
vvp <output>
```

---

## 1. Unpacked Arrays

An unpacked array declares a collection of separate elements. The dimension placed **after** the identifier is the unpacked dimension.

```systemverilog
logic [7:0] mem [4];   // 4 elements, each an 8-bit value
```

- `[7:0]` before the name is the element width (8 bits).
- `[4]` after the name is shorthand for `[0:3]`: four elements, indexed 0 to 3.
- Elements are accessed as `mem[0]` … `mem[3]`.

```systemverilog
initial begin
    mem[0] = 8'hA5;  mem[1] = 8'h3C;
    mem[2] = 8'hFF;  mem[3] = 8'h00;

    foreach (mem[i])
        $display("mem[%0d] = %h", i, mem[i]);
end
```

`foreach` iterates over every valid index and removes the need for hand-written bounds such as `i < 4`.

### Out-of-bounds access

Indexing outside the declared range is not a compile-time error when the index is a variable. Observed behavior in Icarus Verilog 12.0 with `int i = 4`:

| Operation | Result |
|---|---|
| Read `mem[i]` | Returns `xx` (unknown) |
| Write `mem[i] = 8'h11` | Ignored; elements 0–3 unchanged |

Reading from an invalid index yields `X` for 4-state element types. In synthesizable RTL this must be prevented by design, either by sizing the index to match the array depth or by explicit range checks. An `X` appearing on a data path during simulation is often the first symptom of this bug.

### Practical use

- Memories and ROM/RAM behavioral models
- Register banks and register files
- Testbench stimulus and expected-data storage

---

## 2. Packed Multidimensional Arrays

```systemverilog
logic [3:0][7:0] word;   // 4 bytes, packed into one 32-bit vector
```

Packed dimensions are declared **before** the identifier and are stored as a single contiguous vector. Here, `word` is a 32-bit value viewed as four 8-bit groups.

| Expression | Meaning | Width |
|---|---|---|
| `word` | Entire value | 32 |
| `word[3]` | Most significant byte, bits `[31:24]` | 8 |
| `word[0]` | Least significant byte, bits `[7:0]` | 8 |
| `word[1][7:4]` | Upper nibble of byte 1 | 4 |
| `word[0][0]` | Bit 0 of byte 0 | 1 |

Because the array is packed, it can be assigned from, or compared with, a plain 32-bit value and used directly in arithmetic and bitwise expressions. This makes it the natural type for data that is both a number and a structured collection of fields, such as bus words, packet headers, and instruction words.

| Unpacked (`logic [7:0] mem [4]`) | Packed (`logic [3:0][7:0] word`) |
|---|---|
| Separate elements | One contiguous vector |
| Cannot be used as a single operand | Usable as a single vector |
| Models storage | Models data |

---

## 3. Byte Swapping

```systemverilog
module byte_swap;
    logic [3:0][7:0] word;
    logic [7:0] tmp;

    initial begin
        word = 32'h11223344;
        $display("before: %h", word);

        tmp = word[0]; word[0] = word[3]; word[3] = tmp;
        tmp = word[1]; word[1] = word[2]; word[2] = tmp;

        $display("after : %h", word);
    end
endmodule
```

```text
before: 11223344
after : 44332211
```

The same result can be written as a single concatenation: `word = {word[0], word[1], word[2], word[3]};`

### Why it matters

- **Endianness.** Big-endian systems store the most significant byte at the lowest address; little-endian systems store it at the highest. Moving a value between the two requires exactly this reordering.
- **Network protocols.** Network byte order is big-endian, while many processors are little-endian.
- **Processor/memory interfaces.** Bus bridges and DMA engines between differently-ordered domains need hardware byte lanes to be swapped.
- **Data-format conversion.** File formats and peripheral registers often define a fixed byte order.

---

## 4. Bitwise vs Logical Operators

| Category | Operators | Operates on | Result width |
|---|---|---|---|
| Bitwise | `&` `\|` `^` `~` | Each bit independently | Same as operands |
| Logical | `&&` `\|\|` `!` | Whole value as true (non-zero) / false (zero) | 1 bit |

Observed with `x = 4'b1100`, `y = 4'b1010`:

| Expression | Result |
|---|---|
| `x & y` | `1000` |
| `x \| y` | `1110` |
| `x ^ y` | `0110` |
| `~x` | `0011` |
| `x && y` | `1` |
| `x \|\| y` | `1` |
| `!x` | `0` |

The distinction matters when operands overlap partially. With `x = 4'b0100` and `y = 4'b0010`:

```text
x & y   = 0000   // no common set bit
x && y  = 1      // both values are non-zero
```

### RTL usage

- **Bitwise:** masking (`data & 8'h0F`), setting and clearing register bits, parity (`^`), inversion.
- **Logical:** control conditions such as `if (valid && ready)`, which expresses a handshake transfer: data moves only in a cycle where the source is valid and the sink is ready.

---

## 5. Shift Operators

| Operator | Name | Vacated bits filled with |
|---|---|---|
| `<<` | Logical left | `0` |
| `>>` | Logical right | `0` |
| `<<<` | Arithmetic left | `0` |
| `>>>` | Arithmetic right | Sign bit (when operand is signed) |

```systemverilog
logic signed [7:0] a;
a = 8'b10110110;     // -74 as a signed value
```

| Expression | Result (shift by 2) |
|---|---|
| `a << 2` | `11011000` |
| `a >> 2` | `00101101` |
| `a <<< 2` | `11011000` |
| `a >>> 2` | `11101101` |

Left shifts (`<<` and `<<<`) are identical: both shift in zeros on the right. The difference appears on right shifts. `>>` fills the vacated upper bits with zeros, which turns a negative number into a positive one. `>>>` replicates the sign bit (sign extension), so `10110110` (−74) becomes `11101101` (−19), which is −74 divided by 4 rounded toward negative infinity.

Arithmetic right shift only sign-extends if the operand is **signed**. On an unsigned operand, `>>>` behaves like `>>`.

### RTL / DSP relevance

- **ALUs:** shift and rotate instructions.
- **Fixed-point arithmetic:** rescaling after multiplication.
- **DSP:** gain scaling, filter coefficient alignment.
- **Address calculation:** scaling an index by an element size.
- **Power-of-two arithmetic:** `x << n` multiplies by 2ⁿ and `x >>> n` divides a signed value by 2ⁿ, at the cost of wiring only.

---

## 6. Concatenation

`{a, b}` joins signals into a single wider vector, with the leftmost item in the most significant position.

```systemverilog
logic [1:0] hi = 2'b10;
logic [1:0] lo = 2'b01;
logic [3:0] y  = {hi, lo};    // 4'b1001
```

The result width is the sum of the operand widths. Concatenation is pure wiring and costs no logic.

Typical uses:

- **Packet construction:** `{header, length, payload, crc}`
- **Instruction encoding:** `{opcode, rs, rt, imm}`
- **Register construction:** assembling a status register from individual flag bits
- **Datapath design:** zero-extension `{1'b0, a}`, byte reordering, bit slicing and recombination

Concatenation can also appear on the left side of an assignment, for example `{carry, sum} = a + b;`

---

## 7. Replication Operator

`{N{expr}}` repeats `expr` N times.

```systemverilog
logic [7:0] y = {4{2'b10}};    // 8'b10101010
```

| Use | Example |
|---|---|
| Mask generation | `{8{enable}}` — expand a 1-bit enable to an 8-bit mask |
| Repeated test patterns | `{4{4'hA}}` |
| Signal expansion | Broadcast a single bit across a bus |
| Sign extension | `{{8{x[7]}}, x}` — extend an 8-bit signed value to 16 bits |

The repeat count must be a constant expression.

---

## 8. Ternary Operator and 2:1 Multiplexer

```systemverilog
assign y = sel ? a : b;
```

This describes a 2:1 multiplexer: `sel` chooses between two data sources.

| `sel` | `y` |
|---|---|
| `0` | `b` |
| `1` | `a` |

Practice implementation with 4-bit data:

```systemverilog
module mux2to1 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       sel,
    output logic [3:0] y
);
    assign y = sel ? a : b;
endmodule
```

Simulation with `a = 4'hA`, `b = 4'h5`: `sel = 0` gives `y = 5`, and `sel = 1` gives `y = A`.

Applications: CPU datapath source selection, ALU result select, register-file read-port selection, and routing between hardware data sources. Nested ternaries produce priority chains, so deep nesting should be avoided in favor of `case` where a wider multiplexer is intended.

---

## 9. Width Pitfalls and Carry Loss

RTL arithmetic is fixed-width. The result of an operation is truncated to the width of its destination.

```text
  1111   (15)
+ 0001   ( 1)
-------
1_0000   (16)   mathematically, 5 bits
```

```systemverilog
logic [3:0] a = 4'b1111, b = 4'b0001;
logic [3:0] sum4;
logic [4:0] sum5;

assign sum4 = a + b;                  // 4'b0000  -> carry lost
assign sum5 = {1'b0, a} + {1'b0, b};  // 5'b10000 -> carry kept
```

Observed output:

```text
sum4 = 0000
sum5 = 10000
```

A 4-bit destination cannot hold the fifth bit, so `sum4` wraps to zero and the carry is silently discarded. No error is raised, which makes this class of bug easy to miss.

Zero-extending each operand with `{1'b0, a}` makes the addition 5 bits wide before it is evaluated and gives the carry a place to land. Designers should always check two widths: the width of the expression (set by the operands and the destination) and the width of the signal that receives the result.

---

## 10. Parameterized Adder

```systemverilog
module parameterized_adder #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH:0]   sum
);

    assign sum = {1'b0, a} + {1'b0, b};

endmodule
```

- **Reuse.** One module covers any operand width. The width is set at instantiation, not by copying and editing source.
- **Output width.** `[WIDTH:0]` spans `WIDTH + 1` bits. The extra most significant bit holds the carry-out, so the full sum is always representable.
- **Zero extension.** `{1'b0, a}` and `{1'b0, b}` widen the operands to `WIDTH + 1` bits, so the addition is evaluated at full width and no carry is lost. The operands are unsigned, so zeros are the correct extension.

Instantiation for different widths:

```systemverilog
parameterized_adder #(.WIDTH(4))  u_add4  (.a(a4),  .b(b4),  .sum(s4));
parameterized_adder #(.WIDTH(8))  u_add8  (.a(a8),  .b(b8),  .sum(s8));
parameterized_adder #(.WIDTH(16)) u_add16 (.a(a16), .b(b16), .sum(s16));
parameterized_adder #(.WIDTH(32)) u_add32 (.a(a32), .b(b32), .sum(s32));
```

Verified in simulation:

| WIDTH | `a` | `b` | `sum` |
|---|---|---|---|
| 4 | `4'hF` | `4'h1` | `5'b10000` |
| 8 | `8'hFF` | `8'h01` | `9'b100000000` |

---

## Key Learning Outcomes

- Distinguished packed from unpacked data structures and chose between them by purpose (storage vs. data).
- Manipulated hardware data at bit, nibble, and byte level using packed-array indexing.
- Separated bitwise operations (per bit) from logical operations (whole-value truth).
- Applied signed and unsigned shifts and understood sign extension on arithmetic right shift.
- Constructed and replicated vectors with concatenation and replication.
- Described multiplexers with the ternary operator.
- Recognized arithmetic width and carry-loss bugs and fixed them with explicit operand extension.
- Wrote reusable, parameterized RTL.

## Topics Intentionally Deferred

The following are being covered separately and are **not** claimed as completed in this log:

- Reduction operators
- Detailed `==` vs `===` comparison with X/Z values
- Dynamic arrays
- Queues
- Associative arrays

---

## Final Reflection

Day 2 moved past basic SystemVerilog syntax into material that bears directly on RTL datapath design: how data is represented and sliced, how operator choice changes hardware behavior, why expression and destination widths must be tracked deliberately, and how parameters turn a single description into reusable modules. Future sessions will build on this toward more advanced SystemVerilog and verification-oriented concepts.
