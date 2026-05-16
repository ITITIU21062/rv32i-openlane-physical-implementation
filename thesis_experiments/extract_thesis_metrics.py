from pathlib import Path
import csv

base = Path.home() / 'OpenLane' / 'designs' / 'rv32i_pipeline_clean' / 'runs'
out = Path.home() / 'OpenLane' / 'designs' / 'rv32i_pipeline_clean' / 'thesis_experiments' / 'thesis_metrics_summary.csv'
run_names = [
    'thesis_ctrl_clk20_den045_area1',
    'thesis_clk25_den045_area1',
    'thesis_clk20_den040_area1',
    'thesis_clk20_den045_delay0',
    'thesis_clk20_area1400_area1',
]
fields = [
    'config','flow_status','total_runtime','routed_runtime','DIEAREA_mm^2','CoreArea_um^2','OpenDP_Util',
    'synth_cell_count','TotalCells','tritonRoute_violations','Magic_violations','lvs_total_errors',
    'pin_antenna_violations','net_antenna_violations','wns','tns','critical_path_ns',
    'suggested_clock_period','suggested_clock_frequency','CLOCK_PERIOD','FP_CORE_UTIL','PL_TARGET_DENSITY','SYNTH_STRATEGY'
]
rows = []
for run in run_names:
    m = base / run / 'reports' / 'metrics.csv'
    if not m.exists():
        continue
    with m.open(newline='', encoding='utf-8') as f:
        r = csv.DictReader(f)
        row = next(r)
        rows.append({k: row.get(k, '') for k in fields})

with out.open('w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=fields)
    w.writeheader()
    w.writerows(rows)

print(out)
print(f'rows={len(rows)}')
