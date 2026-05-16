# Physical Implementation of a 32-bit RISC-V Processor

Student: Nguyen Kham Thinh Khoa  
Student ID: ITITIU21062  

## Project Overview

This project implements a 32-bit RV32I pipelined processor using the OpenLane open-source ASIC flow with the SkyWater 130 nm PDK.

The design target is:

- Top module: `rv32i_top`
- Clock port: `i_clk`
- Reset: `i_arst_n` active-low asynchronous reset
- PDK: `sky130A`
- Standard cell library: `sky130_fd_sc_hd`

## Main Directory Structure

```text
rv32i_pipeline_clean/
├── src/                         # RTL source files
├── sim/demo/                    # RTL simulation demo testbench
├── thesis_experiments/          # OpenLane experiment configs/scripts
├── submission_artifacts/        # Selected reports and final evidence
├── config.tcl                   # Main OpenLane configuration
├── config_backup_baseline.tcl   # Baseline config backup
└── README_STAGE.txt
