# Day 05 — SystemVerilog Dynamic Data Structures

## Overview

Day 05 of the **100 Days of VLSI — Sand to Silicon** journey focuses on dynamic data structures in SystemVerilog and their role in building scalable verification environments.

The primary objective was to understand how SystemVerilog manages data whose size, ordering, or indexing requirements are determined during simulation rather than being completely fixed at elaboration time.

### Topics Covered

- Dynamic Arrays
- `foreach` Iteration
- Queues
- Associative Arrays
- Runtime allocation and resizing
- Queue-based ordered data management
- Sparse data storage
- Application of these structures in RV32I verification

---

## 1. Dynamic Arrays

Dynamic arrays provide runtime-configurable storage. Unlike fixed-size arrays, their size does not need to be permanently determined when the variable is declared.

The exercises explored the complete lifecycle of a dynamic array:

**Declaration → Allocation → Access → Resize → Preserve Data → Delete**

A dynamic instruction buffer was used to demonstrate these operations. The buffer was initially allocated for four RV32I instructions and was later expanded to accommodate six instructions.

A particularly important observation was that resizing can either discard or preserve existing contents depending on how the new allocation is performed.

### Verification Perspective

Dynamic arrays are useful when the amount of verification data is not known in advance, such as:

- Variable-length instruction streams
- Test vectors
- Expected-result collections
- Memory initialization data
- Generated verification sequences

They are generally more valuable in verification environments than in synthesizable processor datapaths.

---

## 2. `foreach` Iteration

The `foreach` construct provides a convenient way to traverse SystemVerilog arrays without manually maintaining loop boundaries.

This becomes especially useful when working with dynamic containers because their size can change during simulation.

During the exercise, the same iteration mechanism continued to operate correctly after the instruction buffer was resized from four to six entries.

### Key Observation

The loop follows the currently valid array indexes rather than relying on a manually specified constant limit.

This reduces dependency between the storage size and the verification code that processes that storage.

---

## 3. RV32I Dynamic Instruction Buffer

A simplified RV32I instruction buffer was developed to apply dynamic-array concepts to a realistic verification scenario.

The experiment demonstrated:

- Runtime allocation of instruction storage
- Storage of 32-bit instruction words
- Automatic traversal of valid entries
- Expansion of the instruction buffer
- Preservation of previously stored instructions
- Addition of new instructions after resizing
- Runtime size inspection
- Complete deletion of allocated storage

The simulation verified that the original instruction sequence remained intact after the buffer was expanded.

### RV32I Relevance

An architectural RV32I register file has a fixed number of registers and therefore should not be modeled as a dynamic array simply because SystemVerilog provides the feature.

Dynamic arrays instead become valuable when creating the **verification environment surrounding the processor**, where the number of instructions, transactions, or expected values may vary between tests.

---

## 4. Queues

Queues provide variable-size ordered storage with efficient operations at both ends.

The following queue behaviours were explored:

- Insertion at the front
- Insertion at the back
- Removal from the front
- Removal from the back
- Runtime size checking
- Iteration through stored elements

This introduced the distinction between simply storing data and maintaining the **ordering relationship** between transactions.

---

## 5. FIFO Behaviour

Using insertion at the back and removal from the front naturally produces:

**FIFO — First In, First Out**

This behaviour is fundamental throughout digital systems.

Examples include:

- Transaction buffering
- Pipeline tracking
- Data-stream ordering
- Bus transaction monitoring
- Expected-result tracking

The queue exercise demonstrated how values could be inserted in a known order and later retrieved while maintaining that ordering.

---

## 6. RV32I Expected-Result Queue

A simplified expected-result buffer was developed to understand how queues can participate in processor verification.

The conceptual verification flow is:

**Instruction → Expected Result → Queue → DUT Result → Comparison**

Expected results can be stored as instructions are issued. When the processor produces corresponding outputs, the oldest expected result can be retrieved and compared against the DUT result.

This introduces an important concept used in more advanced verification environments:

### Scoreboard-Based Verification

A scoreboard maintains expected behaviour and compares it against actual DUT behaviour.

Queues are particularly suitable when expected and actual transactions must be correlated in a defined order.

This concept will become increasingly relevant when moving toward verification of a pipelined RV32I implementation.

---

## 7. Verification Queue vs Hardware FIFO

An important distinction established during this exercise is that a SystemVerilog queue is **not automatically a hardware FIFO implementation**.

A queue is an extremely convenient simulation and verification data structure.

A synthesizable FIFO, however, typically requires explicit RTL components such as:

- Storage elements
- Read pointer
- Write pointer
- Full detection
- Empty detection
- Pointer management
- Sequential control logic

Therefore, the conceptual FIFO behaviour is transferable to hardware design, while the SystemVerilog queue itself is primarily useful in the verification domain.

---

## 8. Associative Arrays

Associative arrays introduce another storage model: data is associated with meaningful indexes or keys rather than requiring a continuously allocated range.

Only indexes that are actually used need to contain entries.

This makes associative arrays particularly suitable for **sparse data structures**.

The following operations were studied:

- Checking whether an entry exists
- Determining the number of stored entries
- Locating the first valid entry
- Traversing subsequent valid entries
- Deleting individual entries
- Clearing stored data

---

## 9. Sparse Memory Modelling

One important VLSI application of associative arrays is the creation of reference memory models.

A processor may operate within a large address space while a particular verification test accesses only a small number of addresses.

Allocating verification storage for the entire address space would often be unnecessary.

An associative array allows the verification environment to represent only the addresses that actually contain relevant data.

Conceptually:

**Memory Address → Expected Data**

This approach can be useful for:

- Reference memory models
- Address-based scoreboards
- Register models
- Sparse transaction tracking
- Expected load/store behaviour

---

## 10. Choosing the Correct Data Structure

The exercises highlighted that these SystemVerilog structures solve different verification problems.

| Requirement | Suitable Structure |
|---|---|
| Runtime-variable sequence | Dynamic Array |
| Automatic array traversal | `foreach` |
| Ordered transaction storage | Queue |
| FIFO-style expected-result tracking | Queue |
| Sparse address-based storage | Associative Array |
| Reference memory modelling | Associative Array |

The important skill is therefore not merely remembering syntax, but recognizing **which data structure best represents the verification problem being solved**.

---

## 11. RTL vs Verification Perspective

These concepts also reinforce the distinction between **design RTL** and **verification code**.

### Synthesizable RTL

Hardware structures normally require explicitly defined architectural resources and hardware behaviour.

Examples include:

- Register files
- FIFOs
- Memories
- Pipeline registers
- Counters
- Control FSMs

### Verification Environment

SystemVerilog verification code can use higher-level data structures to model expected behaviour and manage simulation data efficiently.

Dynamic arrays, queues, and associative arrays are especially powerful in this environment.

Understanding this boundary is important when progressing from writing individual RTL modules toward complete processor design and verification.

---

## 12. Key Learning Outcomes

By completing Day 05, I gained practical understanding of:

- Runtime storage management in SystemVerilog
- Dynamic array allocation and resizing
- Preservation of data during resizing
- Automatic traversal using `foreach`
- Front and back operations on queues
- FIFO-oriented transaction handling
- Associative storage and sparse indexing
- Expected-result buffering
- Basic scoreboard concepts
- Sparse reference-memory modelling
- Differences between verification data structures and synthesizable hardware

---

## Connection to the RV32I Project

These concepts will later support the verification infrastructure around the RV32I processor.

As the processor grows from individual RTL blocks toward an integrated core, verification will require management of instruction sequences, expected register values, memory transactions, and ordered DUT outputs.

The concepts studied in Day 05 provide SystemVerilog mechanisms for organizing that information efficiently.

### Long-Term Verification Direction

**RV32I Instructions → DUT Execution → Observed Results → Reference/Expected Results → Comparison → Pass/Fail**

Dynamic arrays, queues, and associative arrays provide different tools that can contribute to this verification flow.

---

## Day 05 Status

**Completed Topics**

- Dynamic Arrays
- `foreach`
- Queues
- Associative Arrays
- RV32I-oriented verification exercises
- Dynamic instruction buffering
- Expected-result queue modelling
- Sparse reference-memory concepts

**Next:** Array Locator and Reduction Methods