vlib work

vlog -timescale 1ns/1ns FSMpart2.v

vsim FSM

log {/*}

add wave {/*}

#
force {start} 0
force {load} 0
force {reset} 0

force {clk} 0 0 ,1 10 -repeat 20
run 20


#
force {start} 0
force {load} 1
force {reset} 1

force {clk} 0 0 ,1 10 -repeat 20
run 20

#
force {start} 0
force {load} 0
force {reset} 1

force {clk} 0 0 ,1 10 -repeat 20
run 20


#
force {start} 0
force {load} 1
force {reset} 1

force {clk} 0 0 ,1 10 -repeat 20
run 20

#
force {start} 0
force {load} 0
force {reset} 1

force {clk} 0 0 ,1 10 -repeat 20
run 20

#
force {start} 1
force {load} 0
force {reset} 1

force {clk} 0 0 ,1 10 -repeat 20
run 20

#
force {start} 0
force {load} 0
force {reset} 1

force {clk} 0 0 ,1 10 -repeat 20
run 20

