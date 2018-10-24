vlib work

vlog -timescale 1ns/1ns mux.v

vsim mux

log {/*}

add wave {/*}

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[2:0]} 000
force {KEY[1]} 0
force {KEY[0]} 0
force {SW[8]} 0 0, 1 10 -repeat 20


# Run simulation for a few ns.
run 40ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[2:0]} 000
force {KEY[1]} 1
force {KEY[0]} 1
force {SW[8]} 0 0, 1 10 -repeat 20


# Run simulation for a few ns.
run 40ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[2:0]} 000
force {KEY[1]} 0
force {KEY[0]} 1
force {SW[8]} 0 0, 1 10 -repeat 20


# Run simulation for a few ns.
run 600ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[2:0]} 001
force {KEY[1]} 0
force {KEY[0]} 0
force {SW[8]} 0 0, 1 10 -repeat 20


# Run simulation for a few ns.
run 40ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[2:0]} 001
force {KEY[1]} 1
force {KEY[0]} 1
force {SW[8]} 0 0, 1 10 -repeat 20


# Run simulation for a few ns.
run 40ns

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force {SW[2:0]} 001
force {KEY[1]} 0
force {KEY[0]} 1
force {SW[8]} 0 0, 1 10 -repeat 20


# Run simulation for a few ns.
run 600ns

