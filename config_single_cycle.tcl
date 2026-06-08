set ::env(PDK) sky130A
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd

set ::env(DESIGN_NAME) rv32i_single_cycle_top
set ::env(DESIGN_IS_CORE) 1
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src_single_cycle/*.sv]

set ::env(CLOCK_PORT) "i_clk"
set ::env(CLOCK_NET) "i_clk"
set ::env(CLOCK_PERIOD) "50"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1200 1200"
set ::env(CORE_AREA) "100 100 1100 1100"

set ::env(SYNTH_STRATEGY) "AREA 1"
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 1
set ::env(MAX_FANOUT_CONSTRAINT) 8
set ::env(PL_TARGET_DENSITY) 0.45
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(RUN_CVC) 0
set ::env(FP_IO_UNMATCHED_ERROR) 0
# Timing fix attempt for W_flush debug output path

set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 1
set ::env(MAX_FANOUT_CONSTRAINT) 6

set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1

set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(GLB_RESIZER_DESIGN_OPTIMIZATIONS) 0

set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.2
