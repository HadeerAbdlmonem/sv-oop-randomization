vlib work
vlog pkg.sv ALSU.v test_ALSU.sv +cover -covercells
vsim -voptargs=+acc work.alsu_tb -cover
add wave *
coverage save test_ALSU.ucdb -onexit -du work.alsu
coverage exclude -du alsu -togglenode {cin_reg[1]}
coverage exclude -src ALSU.v -line 111 -code b
coverage exclude -src ALSU.v -line 111 -code s
run -all
