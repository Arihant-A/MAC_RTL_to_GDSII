# Timing Constraints — MAC Unit
# Tool: OpenSTA
# Clock period: 11 ns → F_max ≈ 97.94 MHz

# Define primary clock (11 ns period)
create_clock -name clk -period 11 [get_ports clk]

# Input delays (1 ns budget relative to clock edge)
set_input_delay 1 -clock clk [get_ports {a b en clr}]

# Output delays (1 ns budget relative to clock edge)
set_output_delay 1 -clock clk [get_ports {result valid}]

# Async reset: exclude from timing paths
set_false_path -from [get_ports rst]
