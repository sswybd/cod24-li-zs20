onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/dut/sys_clk
add wave -noupdate /tb/dut/sys_rst
add wave -noupdate /tb/dut/txd
add wave -noupdate /tb/dut/wbm0_stb_o
add wave -noupdate /tb/dut/wbm1_stb_o
add wave -noupdate -radix binary /tb/dut/if_stage_instr_o
add wave -noupdate /tb/dut/wbs0_adr_i
add wave -noupdate /tb/dut/wbm0_ack_i
add wave -noupdate /tb/dut/wbm1_ack_i
add wave -noupdate /tb/dut/wbs0_dat_o
add wave -noupdate /tb/dut/wbs0_dat_i
add wave -noupdate /tb/dut/wbs0_we_i
add wave -noupdate /tb/dut/wbs0_sel_i
add wave -noupdate /tb/dut/wbs0_stb_i
add wave -noupdate /tb/dut/wbs0_ack_o
add wave -noupdate /tb/dut/wbs0_cyc_i
add wave -noupdate /tb/dut/bus_is_busy
add wave -noupdate -radix binary /tb/dut/pc_is_from_branch
add wave -noupdate -radix binary /tb/dut/exe_stage_alu_result
add wave -noupdate -radix binary /tb/dut/exe_stage_operand_a
add wave -noupdate /tb/dut/exe_stage_operand_b
add wave -noupdate -radix hexadecimal /tb/dut/if_stage_pc
add wave -noupdate -radix binary /tb/dut/fetched_instr
add wave -noupdate /tb/dut/mem_stage_non_imm_operand_b
add wave -noupdate /tb/dut/mem_stage_alu_result
add wave -noupdate /tb/dut/mem_stage_mem_rd_en
add wave -noupdate /tb/dut/mem_stage_mem_wr_en
add wave -noupdate /tb/dut/mem_stage_sel
add wave -noupdate /tb/dut/mem_stage_wr_data
add wave -noupdate /tb/dut/mem_stage_rd_mem_data
add wave -noupdate /tb/dut/wbs2_adr_i
add wave -noupdate /tb/dut/wbs2_dat_o
add wave -noupdate /tb/dut/wbs2_dat_i
add wave -noupdate /tb/dut/wbs2_we_i
add wave -noupdate /tb/dut/wbs2_sel_i
add wave -noupdate /tb/dut/wbs2_stb_i
add wave -noupdate /tb/dut/wbs2_ack_o
add wave -noupdate /tb/dut/wbs2_cyc_i
add wave -noupdate /tb/dut/wbm0_addr_o
add wave -noupdate /tb/dut/wbm1_addr_o
add wave -noupdate /tb/dut/wbm0_dat_o
add wave -noupdate /tb/dut/wbm1_dat_o
add wave -noupdate /tb/dut/wbm0_dat_i
add wave -noupdate /tb/dut/wbm1_dat_i
add wave -noupdate /tb/dut/wbm0_sel_o
add wave -noupdate /tb/dut/wbm1_sel_o
add wave -noupdate /tb/dut/wbm0_we_o
add wave -noupdate /tb/dut/wbm1_we_o
add wave -noupdate /tb/dut/wbs_stb_i
add wave -noupdate /tb/dut/wbs_cyc_i
add wave -noupdate /tb/dut/wbs_ack_o
add wave -noupdate /tb/dut/wbs_addr_i
add wave -noupdate /tb/dut/wbs_dat_o
add wave -noupdate /tb/dut/wbs_dat_i
add wave -noupdate /tb/dut/wbs_sel_i
add wave -noupdate /tb/dut/wbs_we_i
add wave -noupdate /tb/dut/if_stage_invalid
add wave -noupdate /tb/dut/if_stage_into_bubble
add wave -noupdate /tb/dut/if_to_id_wr_en
add wave -noupdate /tb/dut/id_stage_into_bubble
add wave -noupdate /tb/dut/id_to_exe_wr_en
add wave -noupdate /tb/dut/exe_to_mem_wr_en
add wave -noupdate /tb/dut/mem_stage_into_bubble
add wave -noupdate /tb/dut/pc_wr_en
add wave -noupdate /tb/dut/mem_stage_request_use
add wave -noupdate /tb/dut/next_normal_pc
add wave -noupdate /tb/dut/branch_pc
add wave -noupdate /tb/dut/pc_chosen
add wave -noupdate /tb/dut/id_stage_instr
add wave -noupdate /tb/dut/id_stage_pc
add wave -noupdate /tb/dut/wb_stage_wr_rf_data
add wave -noupdate /tb/dut/raw_rf_rdata_a
add wave -noupdate /tb/dut/raw_rf_rdata_b
add wave -noupdate /tb/dut/wb_stage_rf_waddr
add wave -noupdate /tb/dut/wb_stage_rf_wr_en
add wave -noupdate /tb/dut/decoded_rf_raddr_a
add wave -noupdate /tb/dut/decoded_rf_raddr_b
add wave -noupdate /tb/dut/decoded_mem_rd_en
add wave -noupdate /tb/dut/decoded_mem_wr_en
add wave -noupdate /tb/dut/decoded_is_branch_type
add wave -noupdate /tb/dut/decoded_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/decoded_alu_src_reg_h_imm_low
add wave -noupdate /tb/dut/decoded_rf_wr_en
add wave -noupdate /tb/dut/decoded_sel_cnt
add wave -noupdate /tb/dut/decoded_imm
add wave -noupdate /tb/dut/decoded_alu_op
add wave -noupdate /tb/dut/decoded_rf_waddr
add wave -noupdate /tb/dut/id_stage_forward_a
add wave -noupdate /tb/dut/id_stage_forward_b
add wave -noupdate /tb/dut/id_stage_rf_rdata_a
add wave -noupdate /tb/dut/id_stage_rf_rdata_b
add wave -noupdate /tb/dut/id_stage_mem_rd_en_o
add wave -noupdate /tb/dut/id_stage_mem_wr_en_o
add wave -noupdate /tb/dut/id_stage_is_branch_type_o
add wave -noupdate /tb/dut/id_stage_rf_w_src_mem_h_alu_l_o
add wave -noupdate /tb/dut/id_stage_alu_src_reg_h_imm_low_o
add wave -noupdate /tb/dut/id_stage_rf_wr_en_o
add wave -noupdate /tb/dut/exe_stage_mem_rd_en
add wave -noupdate /tb/dut/exe_stage_mem_wr_en
add wave -noupdate /tb/dut/exe_stage_is_branch_type
add wave -noupdate /tb/dut/exe_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/exe_stage_alu_src_reg_h_imm_low
add wave -noupdate /tb/dut/exe_stage_rf_wr_en
add wave -noupdate /tb/dut/exe_stage_pc
add wave -noupdate /tb/dut/exe_stage_sel_cnt
add wave -noupdate /tb/dut/exe_stage_rf_rdata_a
add wave -noupdate /tb/dut/exe_stage_rf_rdata_b
add wave -noupdate /tb/dut/exe_stage_imm
add wave -noupdate /tb/dut/exe_stage_alu_op
add wave -noupdate /tb/dut/exe_stage_rf_waddr
add wave -noupdate /tb/dut/exe_stage_rf_raddr_a
add wave -noupdate /tb/dut/exe_stage_rf_raddr_b
add wave -noupdate /tb/dut/exe_stage_forward_a
add wave -noupdate /tb/dut/exe_stage_forward_b
add wave -noupdate /tb/dut/exe_stage_non_imm_operand_b
add wave -noupdate /tb/dut/mem_stage_rf_wr_en
add wave -noupdate /tb/dut/mem_stage_rf_waddr
add wave -noupdate /tb/dut/mem_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/mem_stage_sel_cnt
add wave -noupdate /tb/dut/final_mem_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/final_mem_stage_rf_wr_en
add wave -noupdate /tb/dut/wb_stage_rd_mem_data
add wave -noupdate /tb/dut/wb_stage_alu_result
add wave -noupdate /tb/dut/wb_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/base_ram_data
add wave -noupdate /tb/dut/base_ram_addr
add wave -noupdate /tb/dut/base_ram_be_n
add wave -noupdate /tb/dut/base_ram_ce_n
add wave -noupdate /tb/dut/base_ram_oe_n
add wave -noupdate /tb/dut/base_ram_we_n
add wave -noupdate /tb/dut/ext_ram_data
add wave -noupdate /tb/dut/ext_ram_addr
add wave -noupdate /tb/dut/ext_ram_be_n
add wave -noupdate /tb/dut/ext_ram_ce_n
add wave -noupdate /tb/dut/ext_ram_oe_n
add wave -noupdate /tb/dut/ext_ram_we_n
add wave -noupdate /tb/dut/wbs1_adr_i
add wave -noupdate /tb/dut/wbs1_dat_o
add wave -noupdate /tb/dut/wbs1_dat_i
add wave -noupdate /tb/dut/wbs1_we_i
add wave -noupdate /tb/dut/wbs1_sel_i
add wave -noupdate /tb/dut/wbs1_stb_i
add wave -noupdate /tb/dut/wbs1_ack_o
add wave -noupdate /tb/dut/wbs1_cyc_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_match
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_match
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_match
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_sel
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_sel
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_sel
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/clk
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/rst
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_adr_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_dat_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_dat_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_we_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_sel_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_stb_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_ack_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_err_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_rty_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbm_cyc_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_adr_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_dat_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_dat_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_we_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_sel_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_stb_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_ack_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_err_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_rty_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_cyc_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_addr
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs0_addr_msk
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_adr_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_dat_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_dat_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_we_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_sel_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_stb_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_ack_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_err_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_rty_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_cyc_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_addr
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs1_addr_msk
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_adr_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_dat_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_dat_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_we_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_sel_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_stb_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_ack_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_err_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_rty_i
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_cyc_o
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_addr
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/wbs2_addr_msk
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/master_cycle
add wave -noupdate -expand -group wb_mux /tb/dut/wb_mux/select_error
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {154580301 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
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
configure wave -timelineunits ns
update
WaveRestoreZoom {147897687 ps} {156727400 ps}
