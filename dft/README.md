# DFT & ATPG — MAC Unit

This directory contains all Design for Testability (DFT) artifacts, including non-scan ATPG and manual scan chain insertion.

---

## Why Synchronous Reset?

The original `mac.v` uses an **asynchronous reset** (`posedge rst`). During ATPG, uninitialized sequential state causes unknown (`'X'`) values to propagate, immediately dropping fault coverage to **0%**.

**Fix:** `mac_sync.v` uses a **synchronous reset** (`if (rst || clr)` inside `always @(posedge clk)`), making all flip-flops fully controllable and observable by the ATPG engine.

---

## Non-Scan ATPG Flow

```bash
# 1. Fault synthesis (inserts fault sites)
fault synth --liberty <PDK>/osu018_stdcells.lib --top mac -o mac_synth.v ../../rtl/mac_sync.v

# 2. Cut sequential elements (expose combinational cone)
fault cut --clock clk --reset rst -o mac_cut.v mac_synth.v

# 3. ATPG — bypass control signals to keep circuit active
fault atpg \
  --cell-model <PDK>/osu018_stdcells.v \
  --clock clk --reset rst \
  --bypassing en=1 --bypassing clr=0 \
  -o mac_atpg.json mac_cut.v
```

**Results:**

| Metric | Value |
|--------|-------|
| Fault sites | 22,523 |
| Fault coverage | **98.45%** |
| Compacted test vectors | **61** (from 100) |

---

## Scan Chain Insertion

### Why Manual?

The automated `fault chain` command includes **boundary scan registers** alongside internal chains. To keep a clean internal-only architecture, scan muxes were inserted manually into `synthesis/synth_mac.v`.

### Architecture

- **65 flip-flops** partitioned into **5 parallel chains of 13 FFs** each
- New ports: `shift` (mode select), `sin[4:0]` (scan inputs), `sout[4:0]` (scan outputs)
- Each FF's data input: `.D(shift ? scan_in : original_data)`

### File Guide

| File | Source | Use |
|------|--------|-----|
| `../../synthesis/synth_mac.v` | Yosys | **Base for scan insertion** |
| `mac_scan_manual.v` | Manual edit | Scan-inserted netlist (use this) |
| `mac_synth.v` | Fault-generated | Intermediate (do not use for scan) |
| `mac_cut.v` | Fault-cut | Combinational ATPG only |

---

## Scan ATPG Flow

```bash
cd scan/

# Cut sequential elements from scan-inserted netlist
fault cut --clock clk --reset rst -o mac_scan_cut.v mac_scan_manual.v

# Run ATPG
fault atpg \
  --clock clk \
  --cell-model <PDK>/osu018_stdcells.v \
  -o mac_scan_atpg.json mac_scan_cut.v
```

**Results:**

| Metric | Value |
|--------|-------|
| Fault coverage | **96.50%** |
| Compacted test vectors | **19** (from 100, **81% reduction**) |

---

## Key Lessons

- **X-propagation is fatal:** Any uninitialized state during ATPG collapses coverage to 0%.
- **DFT starts at RTL:** Poor reset design directly blocks ATPG — testability must be designed in early.
- **ATPG ≠ functional testbench:** ATPG vectors are structural (stuck-at fault detection), not functional.
- **Scan compaction pays off:** Manual mux-based scan achieved 81% vector compaction vs 39% for non-scan, significantly reducing ATE test time.
