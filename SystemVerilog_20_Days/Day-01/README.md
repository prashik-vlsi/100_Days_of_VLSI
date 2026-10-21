# SystemVerilog 20-Day Study Plan: Day 1

## Setup

- Simulator: Icarus Verilog 12.0
- How to run:

```bash
iverilog -g2012 -o out_file file.sv
vvp out_file
```

The `-g2012` flag enables SystemVerilog. Without it, most code will fail to compile.

To check that a file was saved properly: `cat -n file.sv`

---

## Day 1 Summary

| Topic | Key point |
|---|---|
| `logic` vs `reg`/`wire` | `logic` works in both continuous and procedural code, but allows only one driver. Use `wire` for multiple drivers |
| 4-state vs 2-state | `logic` holds 0, 1, X, Z. `bit` holds only 0, 1. Assigning X to a `bit` turns it into 0 |
| Number literals | `8'hA5`, `8'b1010_0101`, `8'd165`. Fill literals: `'0`, `'1`, `'x`, `'z` |
| `enum` | Named values. `.name()` returns the name as a string |
| packed `struct` | The first field listed becomes the MSB (leftmost) |
| `typedef` | Gives a type a name; it does not create a variable |

### Mistakes to remember

- After the closing `}` of a `typedef`, add the type name and `;`, for example `} pixel_t;`
- Do not use `assign` inside `initial`; use plain `=`
- Declare variables at the top of the module, outside `initial`
- Do not put `;` after `begin`
- Always check that the file was actually saved

---

## Completed Exercises

| No. | Task | Output |
|---|---|---|
| 1 | Print `8'hA5` in binary, hex, decimal | `bin=10100101 hex=a5 dec=165` |
| 2 | Print RED, YELLOW, GREEN from an enum | `RED` `YELLOW` `GREEN` |
| 3 | Print an RGB packed struct in hex | `ff8000` |

---

## Remaining: 4 Short Programs

### 1. warmup.sv

```systemverilog
module warmup;
  logic [7:0] data;

  typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;
  state_t state;

  initial begin
    data = 8'hAC;
    $display("bin=%b  hex=%h  dec=%0d", data, data, data);

    state = RUN;
    $display("state = %s (%0d)", state.name(), state);
  end
endmodule
```

Expected output:

```
bin=10101100  hex=ac  dec=172
state = RUN (1)
```

### 2. xtest.sv

```systemverilog
module xtest;
  logic [3:0] l;
  bit   [3:0] b;

  initial begin
    l = 4'bxxxx;
    b = 4'bxxxx;
    $display("logic = %b", l);
    $display("bit   = %b", b);
  end
endmodule
```

Expected output:

```
logic = xxxx
bit   = 0000
```

### 3. structtest.sv

```systemverilog
module structtest;
  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } t;

  t x;

  initial begin
    x.a = 4'hA;
    x.b = 4'h5;
    $display("x = %h", x);
    $display("x[7:4] = %h, x[3:0] = %h", x[7:4], x[3:0]);
  end
endmodule
```

Expected output:

```
x = a5
x[7:4] = a, x[3:0] = 5
```

### 4. filltest.sv

```systemverilog
module filltest;
  logic [15:0] data;

  initial begin
    data = '1;
    $display("%b  (hex %h)", data, data);
  end
endmodule
```

Expected output:

```
1111111111111111  (hex ffff)
```

---

## Next Step

**Day 2:** arrays (packed and unpacked), dynamic arrays, operators.

## 20-Day Roadmap

| Days | Topic |
|---|---|
| 1-2 | Data types, operators, arrays, structs, enums |
| 3-4 | Procedural blocks, tasks, functions, packages |
| 5-6 | RTL design, FSMs |
| 7-8 | Interfaces, modports, parameters, generate |
| 9-10 | Basic testbenches, scheduling regions |
| 11-12 | OOP: classes, inheritance |
| 13-14 | Randomization and constraints |
| 15-16 | Assertions (SVA) |
| 17 | Functional coverage |
| 18 | Mailboxes, semaphores, fork/join |
| 19 | UVM introduction |
| 20 | Final project and interview revision |

Note: Icarus works well for Days 1-10. From Day 11 onward (classes, randomization, SVA, UVM) you will need EDA Playground or another simulator with fuller SystemVerilog support.
