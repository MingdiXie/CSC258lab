# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns mux.v

# Load simulation using mux as the top level simulation module.
vsim mux

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}



# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[3:0]} 0001
force {SW[7:4]} 1000
force {KEY[2:0]} 000



# Run simulation for a few ns.
run 10ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[3:0]} 1010
force {SW[7:4]} 1011
force {KEY[2:0]} 000



# Run simulation for a few ns.
run 10ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[3:0]} 1001
force {SW[7:4]} 0101
force {KEY[2:0]} 000



# Run simulation for a few ns.
run 10ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[3:0]} 0001
force {SW[7:4]} 1111
force {KEY[2:0]} 000



# Run simulation for a few ns.
run 10ns

