vlib work

vlog -timescale 1ns/1ns datapathpart2.v

vsim datapath

log {/*}

add wave {/*}

# First test case
# Set input values using the force command, signal names need to be in {} brackets.


force {xy} 0000000
force {colour} 111
force {loadx} 1
force {loady} 1
force {loadc} 1
force {enable} 0
force {reset} 0
force {clk} 0 0 ,1 10 -repeat 20
run 20


force {xy} 0000000
force {colour} 111
force {loadx} 1
force {loady} 1
force {loadc} 1
force {enable} 0
force {reset} 1
force {clk} 0 0 ,1 10 -repeat 20
run 20

force {xy} 0000000
force {colour} 111
force {loadx} 1
force {loady} 1
force {loadc} 1
force {enable} 1
force {reset} 1
force {clk} 0 0 ,1 10 -repeat 20
run 300


