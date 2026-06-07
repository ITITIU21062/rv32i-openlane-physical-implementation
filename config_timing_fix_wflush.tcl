set ::env(PDK) sky130A
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd

set ::env(DESIGN_NAME) rv32i_top
set ::env(DESIGN_IS_CORE) 1
set ::env(VERILOG_FILES) [list \
    $::env(DESIGN_DIR)/src/adder_N_bit.sv \
    $::env(DESIGN_DIR)/src/mux2to1.sv \
    $::env(DESIGN_DIR)/src/mux3to1.sv \
    $::env(DESIGN_DIR)/src/mux4to1.sv \
    $::env(DESIGN_DIR)/src/ALU_Unit.sv \
    $::env(DESIGN_DIR)/src/Branch_Unit.sv \
    $::env(DESIGN_DIR)/src/Control_Unit.sv \
    $::env(DESIGN_DIR)/src/Data_Memory.sv \
    $::env(DESIGN_DIR)/src/Immediate_Generation.sv \
    $::env(DESIGN_DIR)/src/Instruction_Mem.sv \
    $::env(DESIGN_DIR)/src/Jump_Unit.sv \
    $::env(DESIGN_DIR)/src/Load_Store_Unit.sv \
    $::env(DESIGN_DIR)/src/Program_Counter.sv \
    $::env(DESIGN_DIR)/src/Reg_File.sv \
    $::env(DESIGN_DIR)/src/IF_ID_Register.sv \
    $::env(DESIGN_DIR)/src/ID_EX_Register.sv \
    $::env(DESIGN_DIR)/src/EX_MEM_Register.sv \
    $::env(DESIGN_DIR)/src/MEM_WB_Register.sv \
    $::env(DESIGN_DIR)/src/Forwarding_Unit.sv \
    $::env(DESIGN_DIR)/src/Hazard_Detection_Unit.sv \
    $::env(DESIGN_DIR)/src/rv32i_top.sv \
]

set ::env(CLOCK_PORT) "i_clk"
set ::env(CLOCK_NET) "i_clk"
set ::env(CLOCK_PERIOD) "20"

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
set ::env(CLOCK_PERIOD) "20"

set ::env(SYNTH_STRATEGY) "AREA 1"
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 1
set ::env(MAX_FANOUT_CONSTRAINT) 6

set ::env(PL_TIME_DRIVEN) 1
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 1

set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(GLB_RESIZER_DESIGN_OPTIMIZATIONS) 0

set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.1
