vlib work
vlog package_width.sv count.v test_counter.sv +cover -covercells
vsim -voptargs=+acc work.counter_tb -cover
add wave *
coverage save test_counter.ucdb -onexit -du work.counter
run -all
