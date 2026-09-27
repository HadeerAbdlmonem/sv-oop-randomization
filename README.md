# ⚙️ Assignment 2 — SystemVerilog OOP & Randomization

![SystemVerilog](https://img.shields.io/badge/SystemVerilog-Classes%20%26%20Randomization-2ea44f?style=flat-square)
![Verilog](https://img.shields.io/badge/Verilog-HDL-1f6feb?style=flat-square)
![Simulator](https://img.shields.io/badge/Simulator-QuestaSim-red?style=flat-square)

This assignment moves from directed testbenches into **SystemVerilog's object-oriented
and randomization features**: `class`, `rand`, `constraint ... dist`, dynamic arrays,
and their built-in methods.

## 📦 Modules

| Folder | Module | Description |
|---|---|---|
| 🧩 [`ALSU`](./ALSU) | `alsu` | Arithmetic/Logic/Shift Unit — OR, XOR, ADD, MULT, shift, rotate, reduction ops, bypass |
| 🔁 [`FSM_010.v`](./FSM_010.v) | `fsm_010` | Moore FSM that detects overlapping `"010"` patterns on a serial input |
| 📚 [`array`](./array) | `test_dyn_array` | Demo of SystemVerilog dynamic-array sizing, `sort`/`rsort`/`reverse`/`shuffle` |
| 🔢 [`counter`](./counter) | `counter` | Up/down counter with sync reset, parallel load, and count-enable |

## ✅ Verification Approach

- `design_inputs` / `counter_stimulus` classes drive **constrained-random** stimulus
  (`dist` weighting biases reset, corner-case operands, and invalid-opcode rates)
- Self-checking against a golden reference model computed alongside the DUT
- 1,000+ randomized iterations per testbench

## ▶️ Running a Test

```bash
cd ALSU        # or counter / array
vsim -do run.do
```
