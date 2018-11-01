vlib work


vlog -timescale 1ns/1ns poly_function.v


vsim fpga_top


log {/*}

add wave {/*}

# First test case
# Set input values using the force command, signal names need to be in {} brackets.


force {SW[7:0]} 2#0000_0011 0, 2#0000_0001 35, 2#0000_0010 55, 2#0000_0011 75
force {KEY[0]} 0 0, 1 10
force {KEY[1]} 1 0 ,0 15, 1 25, 0 35, 1 45, 0 55, 1 65, 0 75, 1 85 
force {CLOCK_50} 0 0, 1 5 -r 10
# Run simulation for a few ns.
run 140ns



