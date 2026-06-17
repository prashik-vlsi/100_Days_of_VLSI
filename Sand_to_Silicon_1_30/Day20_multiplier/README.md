# Day 20 — Parameterized Unsigned Multiplier

## Topic

Parameterized Unsigned Multiplier — Partial Product Generation, Partial Product Accumulation,
Bit-Width Scaling, Dynamic Range Verification

---

## Theory

Multiplication in digital hardware is a multi-stage combinational process consisting of two core phases:
**Partial Product Generation (PPG)** and **Partial Product Accumulation (PPA)**. For an N-bit × M-bit
multiplier, an array of AND gates generates intermediate products, which are then summed using a
network of adders.

### Key Distinctions

**Bit-Width Scaling:**
To completely eliminate structural truncation or catastrophic arithmetic overflow, the output bus must
be sized exactly to **N + M** bits.

**Boundary Condition:**
For an 8-bit multiplier (N = 8), the maximum value is `255` (`8'hFF`).
The product at maximum boundaries is:

```
255 × 255 = 65,025
```

Since `65,025` cannot fit into 15 bits (`2¹⁵ − 1 = 32,767`), a full **16-bit wide output bus**
(`[2*WIDTH-1:0]`) is mathematically required to guarantee full precision — zero truncation, zero overflow.

---

## Operations Implemented

| Mode     | Operation               | Core Expression / Logic | Output Width              |
| -------- | ----------------------- | ----------------------- | ------------------------- |
| Unsigned | 8 × 8 Unsigned Multiply | `assign out = A * B;`   | `[2*WIDTH-1:0]` (16 bits) |

---

## Files

| File              | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `multiplier.v`    | Parameterized RTL module with explicit output bus sizing          |
| `multiplier_tb.v` | Self-checking testbench addressing corner and boundary conditions |

---

## Simulation Results

**Terminal Output:**
![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/873d9bff6f1d8b9c537cf77369b1e3f25c32a033/Wavefrom_images/Terminal_20.png)

**Waveform Output:**

![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/873d9bff6f1d8b9c537cf77369b1e3f25c32a033/Wavefrom_images/gtk_20.png)
All test cases passed. Zero truncation detected across the full saturation range.
Verified with **iverilog** and **GTKWave**.

---

## Capstone Connection

**NeuralEdge (AI Inference Accelerator):**
The multiplier forms the absolute structural heart of the Multiply-Accumulate (MAC) core.
It calculates matrix layer dot products (Y = Σ Wᵢ · Xᵢ) and directly dictates maximum
system TOPS (Tera Operations Per Second).

**VitalGuard (Medical ECG Monitor):**
Acts as the math execution core within the digital FIR filter engine to multiply continuous
real-time ECG signal streams against precise hardware filter coefficients (h[k] · x[n−k]).
Bit-width precision here is patient-safety critical — truncation means signal distortion.

---

## Key Learnings

1. **Dynamic Width Sizing:** An N-bit × M-bit multiplication strictly dictates an N+M bit target
   bus to secure the entire dynamic numerical scope — no exceptions.

2. **Combinational Delay Management:** Multipliers generate dense combinational trees. To operate
   at deep sub-micron target speeds without setup time violations (Tₛᵤ), pipelining or
   Booth/Wallace tree structures are applied.

3. **Implicit vs Explicit Net Types:** Port lists should explicitly enforce structural designations
   (e.g., `output wire [2*WIDTH-1:0] out`) to prevent compiler inferences from obscuring
   optimization goals and introducing width mismatches.

_Verified with iverilog and GTKWave. Part of the 100 Days of VLSI series._
