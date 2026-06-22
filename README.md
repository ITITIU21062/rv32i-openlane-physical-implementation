# Physical Implementation of a 32-bit RISC-V Processor

Student: Nguyen Kham Thinh Khoa  
Student ID: ITITIU21062

## Project Overview

This project implements and compares three RV32I processor architectures using the OpenLane open-source ASIC physical design flow with the SkyWater 130 nm PDK.

The three implemented architectures are:

1. Single-cycle RV32I processor
2. 3-stage pipelined RV32I processor
3. 5-stage pipelined RV32I processor

The goal of this project is not only to complete the RTL-to-GDSII physical implementation of one processor, but also to compare how different microarchitectures affect area, timing, routing complexity, and implementation results.

## Design Targets

### 5-stage pipeline processor

- Top module: `rv32i_top`
- Source folder: `src/`
- Clock port: `i_clk`
- Reset: `i_arst_n`
- Target clock period: 25 ns
- Target frequency: 40 MHz

### 3-stage pipeline processor

- Top module: `rv32i_3stage_top`
- Source folder: `src_3stage/`
- Testbench folder: `sim/three_stage/`
- Target clock period: 35 ns
- Target frequency: approximately 28.57 MHz

### Single-cycle processor

- Top module: `rv32i_single_cycle_top`
- Source folder: `src_single_cycle/`
- Testbench folder: `sim/single_cycle/`
- Target clock period: 50 ns
- Target frequency: 20 MHz

## OpenLane Configuration

OpenLane selects the target architecture through the configuration file, mainly using:

```tcl
set ::env(DESIGN_NAME) ...
set ::env(VERILOG_FILES) ...
set ::env(CLOCK_PORT) ...
set ::env(CLOCK_PERIOD) ...
```

For example:

- Single-cycle uses `rv32i_single_cycle_top` and `src_single_cycle/`
- 3-stage pipeline uses `rv32i_3stage_top` and `src_3stage/`
- 5-stage pipeline uses `rv32i_top` and `src/`

## Main Directory Structure

```text
rv32i_pipeline_clean/
├── src/                         # 5-stage pipeline RTL source files
├── src_single_cycle/            # Single-cycle processor RTL source files
├── src_3stage/                  # 3-stage pipeline RTL source files
├── sim/demo/                    # Demo simulation testbench
├── sim/single_cycle/            # Single-cycle testbench
├── sim/three_stage/             # 3-stage pipeline testbench
├── thesis_experiments/          # OpenLane experiment configs/scripts
├── config.tcl                   # Main OpenLane configuration
├── config_single_cycle.tcl      # OpenLane config for single-cycle architecture
├── config_3stage.tcl            # OpenLane config for 3-stage architecture
├── README.md
└── README_STAGE.txt
```

## Architecture Comparison Summary

| Architecture | Top Module | Source Folder | Clock Period | Frequency |
|---|---|---|---:|---:|
| Single-cycle | `rv32i_single_cycle_top` | `src_single_cycle/` | 50 ns | 20 MHz |
| 3-stage pipeline | `rv32i_3stage_top` | `src_3stage/` | 35 ns | 28.57 MHz |
| 5-stage pipeline | `rv32i_top` | `src/` | 25 ns | 40 MHz |

## OpenLane Run Commands

### Single-cycle

```bash
./flow.tcl -design rv32i_pipeline_clean -tag single_cycle_clk50_fix1
```

### 3-stage pipeline

```bash
./flow.tcl -design rv32i_pipeline_clean -tag three_stage_clk35_fix1
```

### 5-stage pipeline

```bash
./flow.tcl -design rv32i_pipeline_clean -tag timing_fix_clk25_real
```

## Notes

The `runs/` directory is excluded from GitHub because it contains large generated OpenLane results such as logs, reports, DEF, GDSII, and routing outputs. Selected final results can be stored separately in documentation or report files when needed.
