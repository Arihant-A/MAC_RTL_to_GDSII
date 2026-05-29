# OpenSTA Script — MAC Unit
# Run: sta mac_sta.tcl

# Load cell library
read_liberty /home/coe-9/Desktop/Technology_PDKs/osu018/osu018_stdcells.lib

# Load synthesized gate-level netlist
read_verilog ../synthesis/synth_mac.v

# Link design
link_design mac

# Apply timing constraints
read_sdc mac.sdc

# Report setup (max) timing paths
report_checks -path_delay max

# Report hold (min) timing paths
report_checks -path_delay min

# Worst negative slack
report_worst_slack

# Total negative slack
report_tns

# Write SDF for back-annotation in gate-level simulation
write_sdf mac.sdf
