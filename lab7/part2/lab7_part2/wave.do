vlib work

vlog -timescale 1ns/1ns part2.v

vsim FD

log {/*}

add wave {/*}

#reset
force {KEY[1]} 0
force {KEY[3]} 0
force {KEY[0]} 0
force {SW[6:0]} 1100000
force {SW[9:7]} 100

force {CLOCK_50} 0 0 ,1 10 -repeat 20
run 20

#load x
force {KEY[1]} 0
force {KEY[3]} 0 0 , 1 20, 0 40
force {KEY[0]} 1
force {SW[6:0]} 1100000
force {SW[9:7]} 100

force {CLOCK_50} 0 0 ,1 10 -repeat 20
run 60

#load y
force {KEY[1]} 0
force {KEY[3]} 0 0 , 1 20, 0 40
force {KEY[0]} 1
force {SW[6:0]} 0011000
force {SW[9:7]} 100

force {CLOCK_50} 0 0 ,1 10 -repeat 20
run 60

#press start
force {KEY[1]} 0 0, 1 20, 0 40
force {KEY[3]} 0
force {KEY[0]} 1
force {SW[6:0]} 0011000
force {SW[9:7]} 100

force {CLOCK_50} 0 0 ,1 10 -repeat 20
run 1200




