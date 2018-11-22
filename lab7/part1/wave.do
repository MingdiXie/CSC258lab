vlib work

vlog -timescale 1ns/1ns ram32x4.v

vsim -L altera_mf_ver ram32x4

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# First test case
# Set input values using the force command, signal names need to be in {} brackets.

force {SW[3:0]} 2#1111
force {SW[8:4]} 2#11111
force {SW[9]} 0
force {KEY[0]} 0 0 ,1 20 -r 40 

# Run simulation for a few ns.
run 40

force {SW[3:0]} 2#1111
force {SW[8:4]} 2#11111
force {SW[9]} 1
force {KEY[0]} 0 0 ,1 20 -r 40 

# Run simulation for a few ns.
run 40


force {SW[3:0]} 2#0000
force {SW[8:4]} 2#11111
force {SW[9]} 0
force {KEY[0]} 0 0 ,1 20 -r 40 

# Run simulation for a few ns.
run 40


force {SW[3:0]} 2#1100
force {SW[8:4]} 2#00000
force {SW[9]} 0
force {KEY[0]} 0 0 ,1 20 -r 40 

# Run simulation for a few ns.
run 40

force {SW[3:0]} 2#1100
force {SW[8:4]} 2#00000
force {SW[9]} 1
force {KEY[0]} 0 0 ,1 20 -r 40 

# Run simulation for a few ns.
run 40


force {SW[3:0]} 2#1100
force {SW[8:4]} 2#00000
force {SW[9]} 0
force {KEY[0]} 0 0 ,1 20 -r 40 

# Run simulation for a few ns.
run 40
