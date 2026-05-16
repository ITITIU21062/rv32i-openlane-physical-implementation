#!/usr/bin/env bash
set -euo pipefail

OPENLANE_ROOT=${OPENLANE_ROOT:-$HOME/OpenLane}
DESIGN=rv32i_pipeline_clean
EXP_DIR="$OPENLANE_ROOT/designs/$DESIGN/thesis_experiments"

run_one() {
  local tag="$1"
  local cfg="$2"
  echo "=== RUN: $tag ==="
  cd "$OPENLANE_ROOT"
  ./flow.tcl -design "$DESIGN" -tag "$tag" -config "$EXP_DIR/$cfg" | tee "$EXP_DIR/${tag}.log"
}

run_one thesis_ctrl_clk20_den045_area1   config_thesis_ctrl_clk20_den045_area1.tcl
run_one thesis_clk25_den045_area1        config_thesis_clk25_den045_area1.tcl
run_one thesis_clk20_den040_area1        config_thesis_clk20_den040_area1.tcl
run_one thesis_clk20_den045_delay0       config_thesis_clk20_den045_delay0.tcl
# optional
# run_one thesis_clk20_area1400_area1      config_thesis_clk20_area1400_area1.tcl
