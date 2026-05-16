# Thesis experiment pack

This pack is designed to turn the current project into a more defensible physical-implementation and timing-optimization study.

## Core principle
Each run changes one main factor relative to the same baseline whenever possible.

## Baseline reference
- CLOCK_PERIOD = 20
- SYNTH_STRATEGY = AREA 1
- DIE_AREA = 0 0 1200 1200
- CORE_AREA = 100 100 1100 1100
- PL_TARGET_DENSITY = 0.45
- FP_CORE_UTIL = 50

## Recommended core runs
1. `thesis_ctrl_clk20_den045_area1`
   - control run
2. `thesis_clk25_den045_area1`
   - isolates relaxed clock effect
3. `thesis_clk20_den040_area1`
   - isolates density effect
4. `thesis_clk20_den045_delay0`
   - isolates synthesis-strategy effect

## Optional fifth run
5. `thesis_clk20_area1400_area1`
   - explores floorplan expansion with same clock/strategy

## Run order
1. control
2. relaxed clock
3. lower density
4. DELAY 0 comparison
5. optional area expansion

## Why this is better than the old run set
The earlier run set mixed multiple changes together. This pack is tighter, so cause-and-effect is easier to defend during viva.
