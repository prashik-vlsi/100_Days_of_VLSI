DAY 15 — TIMING ANALYSIS & CRITICAL PATH
VLSI Design & Verification | Prashik Wankhede
Phase 1 | Setup Time · Hold Time · Timing Paths · Critical Path

CONCEPTS COVERED

1. Setup Time
   The minimum time data must be stable BEFORE the clock edge for the flip-flop to correctly capture it.
   Setup Slack Equation:
   Slack = T_clk + T_skew - T_cq - T_comb - T_setup

Positive slack → Timing met
Zero slack → Dangerously on edge
Negative slack → Timing violation. Circuit fails.

Fix for Setup Violation:

Reduce clock frequency (increase T_clk)
Reduce combinational logic depth (pipeline)
Use faster flip-flop cells (reduce T_cq, T_setup)
Increase positive clock skew

2. Hold Time
   The minimum time data must remain stable AFTER the clock edge for the flip-flop to correctly latch it.
   Hold Slack Equation:
   Slack_hold = T_cq(min) + T_comb(min) - T_hold - T_skew

Uses minimum delays — worst case for hold is fastest path
Positive skew hurts hold timing (opposite of setup)
Fix: Insert buffer cells in the data path

3. Setup vs Hold — Comparison Table
   SetupHoldData must arriveBefore clock edgeAfter clock edgeUse min/max delaysMax delaysMin delaysPositive skew effectHelpsHurtsFix byReduce frequency / PipelineInsert buffers

4. Clock Skew
   Difference in clock arrival time between two flip-flops due to wire and buffer delays.

Positive skew — capture FF clock arrives late → helps setup, hurts hold
Negative skew — capture FF clock arrives early → hurts setup, helps hold

5. Clock-to-Q Delay (T_cq)
   Internal delay of a flip-flop from the clock edge to when output Q becomes valid. Eats into your combinational logic budget.

6. Timing Paths — 4 Types
   TypeStart PointEnd PointVitalGuard Example1FF outputFF inputADC sync FF → alert FF2Input portFF inputSensor pin → sync FF3FF outputOutput portAlert FF → buzzer pin4Input portOutput portInput pin → output pin

7. Critical Path
   The timing path with the least slack in the entire design.

Determines maximum operating frequency
Negative slack on critical path = design fails timing
Must be fixed before tapeout

8. Pipelining
   Inserting a flip-flop in the middle of a long combinational path to reduce T_comb.
   Before: FF1 → [18ns combinational logic] → FF2 ← VIOLATION at 10ns clock

After: FF1 → [9ns logic] → Pipeline_FF → [9ns logic] → FF2 ← PASSES
Tradeoff: Increased latency — output takes more clock cycles to appear.

SLACK WORKED EXAMPLE
Given: f = 50 MHz, T_cq = 0.4ns, T_comb = 12ns, T_skew = 0.3ns (positive), T_setup = 0.2ns
T_clk = 1/50MHz = 20ns

Slack = T_clk + T_skew - T_cq - T_comb - T_setup
Slack = 20 + 0.3 - 0.4 - 12 - 0.2
Slack = +7.7ns ✅ Timing met

FILES CREATED
FileDescriptionvitaguard_timing.vRTL — 3-stage combinational comparator with registered alertvitalguard_timing_tb.vTestbench — 4 test casesvita.vcdWaveform dump for GTKWave

HOW TO SIMULATE
bash# Compile
iverilog -o sim vitaguard_timing.v vitalguard_timing_tb.v

# Run

vvp sim

# View waveforms

gtkwave vita.vcd
GTKWave signals to add: clk, rst, adc_val, treshold, alert

SIMULATION RESULTS
TEST1 Reset: alert=0 ✅ (expect 0)
TEST2 Below Threshold: alert=0 ✅ (expect 0)
TEST3 Emergency: alert=1 ✅ (expect 1)
TEST4 Threshold=255: alert=0 ✅ (expect 0)

KEY EQUATIONS SUMMARY

# Setup Slack

Slack_setup = T_clk + T_skew - T_cq - T_comb - T_setup

# Hold Slack

Slack_hold = T_cq(min) + T_comb(min) - T_hold - T_skew

# Max Operating Frequency

f_max = 1 / (T_cq + T_comb + T_skew + T_setup)

DAY 16 PREVIEW
Static Timing Analysis — Timing Reports, STA Fundamentals, Reading Timing Paths

Day 15 Complete | Phase 1 | Prashik Wankhede
