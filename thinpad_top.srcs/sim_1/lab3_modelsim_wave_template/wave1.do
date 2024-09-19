onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab3_tb/dut/u_controller/clk
add wave -noupdate /lab3_tb/dut/u_controller/reset
add wave -noupdate /lab3_tb/dut/u_controller/step
add wave -noupdate -radix binary /lab3_tb/dut/u_controller/dip_sw
add wave -noupdate -radix binary /lab3_tb/dut/u_controller/inst_reg
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/leds
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_raddr_a
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_rdata_a
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_raddr_b
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_rdata_b
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_waddr
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_wdata
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rf_we
add wave -noupdate -radix unsigned {/lab3_tb/dut/u_register_file/regs[5]}
add wave -noupdate -radix unsigned {/lab3_tb/dut/u_register_file/regs[4]}
add wave -noupdate -radix unsigned {/lab3_tb/dut/u_register_file/regs[3]}
add wave -noupdate -radix unsigned {/lab3_tb/dut/u_register_file/regs[2]}
add wave -noupdate -radix unsigned {/lab3_tb/dut/u_register_file/regs[1]}
add wave -noupdate -radix unsigned {/lab3_tb/dut/u_register_file/regs[0]}
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/alu_a
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/alu_b
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/alu_op
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/alu_y
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/is_rtype
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/is_itype
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/is_peek
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/is_poke
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rd
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rs1
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/rs2
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/opcode
add wave -noupdate /lab3_tb/dut/u_controller/state
add wave -noupdate -radix unsigned /lab3_tb/dut/u_controller/imm
add wave -noupdate -childformat {{{/lab3_tb/dut/u_register_file/regs[5]} -radix unsigned} {{/lab3_tb/dut/u_register_file/regs[4]} -radix unsigned} {{/lab3_tb/dut/u_register_file/regs[3]} -radix unsigned} {{/lab3_tb/dut/u_register_file/regs[2]} -radix unsigned} {{/lab3_tb/dut/u_register_file/regs[1]} -radix unsigned} {{/lab3_tb/dut/u_register_file/regs[0]} -radix unsigned}} -expand -subitemconfig {{/lab3_tb/dut/u_register_file/regs[5]} {-radix unsigned} {/lab3_tb/dut/u_register_file/regs[4]} {-radix unsigned} {/lab3_tb/dut/u_register_file/regs[3]} {-radix unsigned} {/lab3_tb/dut/u_register_file/regs[2]} {-radix unsigned} {/lab3_tb/dut/u_register_file/regs[1]} {-radix unsigned} {/lab3_tb/dut/u_register_file/regs[0]} {-radix unsigned}} /lab3_tb/dut/u_register_file/regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34351642 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {63 us}
