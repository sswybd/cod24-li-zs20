onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab4_tb/dut/sram_controller_base/clk_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/rst_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/wb_cyc_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/wb_stb_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/wb_ack_o
add wave -noupdate -radix hexadecimal /lab4_tb/dut/sram_controller_base/wb_adr_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/wb_dat_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/wb_dat_o
add wave -noupdate -radix binary /lab4_tb/dut/sram_controller_base/wb_sel_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/wb_we_i
add wave -noupdate -radix hexadecimal /lab4_tb/dut/sram_controller_base/sram_addr
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_data
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_ce_n
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_oe_n
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_we_n
add wave -noupdate -radix binary /lab4_tb/dut/sram_controller_base/sram_be_n
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_ce_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/this_state
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_data_en_n
add wave -noupdate -radix hexadecimal /lab4_tb/dut/sram_controller_base/sram_data_i
add wave -noupdate /lab4_tb/dut/sram_controller_base/sram_data_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9786944 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 152
configure wave -valuecolwidth 40
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
WaveRestoreZoom {1142539 ps} {6062239 ps}
