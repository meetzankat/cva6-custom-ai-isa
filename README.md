# CVA6 RISC-V Custom AI Vector Extension

Extends the [openhwgroup/CVA6](https://github.com/openhwgroup/cva6) RISC-V processor with three custom AI-accelerating instructions for 8-bit neural network inference.

## Custom Instructions

| Instruction | Opcode | funct7 | Operation |
|-------------|--------|--------|-----------|
| VDOT | 0x0B (custom-0) | 0000000 | 8×INT8 packed dot product |
| VRELU | 0x0B (custom-0) | 0000001 | ReLU activation per byte |
| VGELU | 0x0B (custom-0) | 0000010 | GELU approximation per byte |

All R-type encoding, single-cycle combinational execution.

## Results

- **Simulation:** VDOT verified PASS in 4329 cycles on Verilated CVA6
- **Synthesis:** 773 LUTs, 0 DSPs, 0 FFs on Xilinx Artix-7 xc7a100t (1.22%)
- **Latency:** Single cycle (combinational datapath)

## Files Modified

| File | Change |
|------|--------|
| `core/include/ariane_pkg.sv` | Added VEC_FU to fu_t, VDOT/VRELU/VGELU to fu_op |
| `core/decoder.sv` | Added OpcodeCustom0 decode case |
| `core/vec_fu.sv` | New: vector functional unit RTL |
| `core/ex_stage.sv` | Instantiated vec_fu, wired result |
| `core/issue_stage.sv` | Added vec_valid_o port |
|
## Build

```bash
# Simulation (Verilator)
export VERILATOR_ROOT=/home/meet/verilator
export PATH=$VERILATOR_ROOT/bin:$PATH
make verilate
cd work-ver && make -j2 -f Variane_testharness.mk
./Variane_testharness ../tests/custom/test_vdot.elf

# Standalone vec_fu synthesis (Vivado Tcl console)
create_project vec_fu_test ./work -part xc7a100tcsg324-1 -force
add_files core/vec_fu.sv
synth_design -top vec_fu -part xc7a100tcsg324-1
```

## Target Hardware
- Board: Digilent Nexys A7 100T
- FPGA: Xilinx Artix-7 xc7a100tcsg324-1
- Tool: Vivado 2025.1
