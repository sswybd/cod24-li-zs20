onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/dut/sys_clk
add wave -noupdate /tb/dut/sys_rst
add wave -noupdate -radix binary /tb/dut/if_stage_instr_o
add wave -noupdate -radix binary /tb/dut/current_privilege_level
add wave -noupdate /tb/dut/mem_stage_is_mret
add wave -noupdate /tb/dut/mem_stage_exception_is_valid
add wave -noupdate /tb/dut/mem_stage_is_async_exception
add wave -noupdate /tb/dut/mem_stage_should_handle_exception
add wave -noupdate /tb/dut/should_take_any_branch
add wave -noupdate /tb/dut/pc_chosen
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mtvec_csr
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mscratch_csr
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mepc_csr
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mcause_csr
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mstatus_csr
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mie_csr
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mip_csr
add wave -noupdate -expand -group CSRs -radix hexadecimal /tb/dut/mtime_l
add wave -noupdate -expand -group CSRs -radix hexadecimal /tb/dut/mtime_h
add wave -noupdate -expand -group CSRs -radix hexadecimal /tb/dut/mtimecmp_l
add wave -noupdate -expand -group CSRs -radix hexadecimal /tb/dut/mtimecmp_h
add wave -noupdate -expand -group CSRs -radix binary /tb/dut/mem_stage_mip
add wave -noupdate /tb/dut/mtime
add wave -noupdate /tb/dut/mtimecmp
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtime_h_load
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtime_l_load
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtime_h_store
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtime_l_store
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtimecmp_h_load
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtimecmp_l_load
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtimecmp_h_store
add wave -noupdate -expand -group mtime_decision /tb/dut/is_mtimecmp_l_store
add wave -noupdate /tb/dut/if_stage_pc
add wave -noupdate -radix binary /tb/dut/fetched_instr
add wave -noupdate /tb/dut/mem_stage_non_imm_operand_b
add wave -noupdate /tb/dut/mem_stage_alu_result
add wave -noupdate /tb/dut/mem_stage_mem_rd_en
add wave -noupdate /tb/dut/mem_stage_mem_wr_en
add wave -noupdate /tb/dut/mem_stage_sel
add wave -noupdate /tb/dut/mem_stage_wr_data
add wave -noupdate /tb/dut/raw_rd_mem_data
add wave -noupdate /tb/dut/mem_stage_is_mmio
add wave -noupdate /tb/dut/mem_stage_mem_rd_en_after_judging_mmio
add wave -noupdate /tb/dut/mem_stage_mem_wr_en_after_judging_mmio
add wave -noupdate /tb/dut/mem_stage_csr_and_mmio_rf_wb_en
add wave -noupdate /tb/dut/mem_stage_csr_rf_wb_en
add wave -noupdate /tb/dut/any_ack
add wave -noupdate /tb/dut/if_stage_invalid
add wave -noupdate /tb/dut/if_stage_into_bubble
add wave -noupdate /tb/dut/if_to_id_wr_en
add wave -noupdate /tb/dut/id_stage_into_bubble
add wave -noupdate /tb/dut/id_to_exe_wr_en
add wave -noupdate /tb/dut/exe_to_mem_wr_en
add wave -noupdate /tb/dut/mem_stage_into_bubble
add wave -noupdate /tb/dut/pc_wr_en
add wave -noupdate /tb/dut/pc_is_from_exe_stage_branch
add wave -noupdate /tb/dut/mem_stage_request_use
add wave -noupdate /tb/dut/next_normal_pc
add wave -noupdate /tb/dut/branch_pc
add wave -noupdate /tb/dut/exception_dest_pc
add wave -noupdate /tb/dut/id_stage_instr
add wave -noupdate /tb/dut/id_stage_pc
add wave -noupdate /tb/dut/wb_stage_wr_rf_data
add wave -noupdate /tb/dut/raw_rf_rdata_a
add wave -noupdate /tb/dut/raw_rf_rdata_b
add wave -noupdate /tb/dut/wb_stage_rf_waddr
add wave -noupdate /tb/dut/wb_stage_rf_wr_en
add wave -noupdate /tb/dut/decoded_rf_raddr_a
add wave -noupdate /tb/dut/decoded_rf_raddr_b
add wave -noupdate /tb/dut/mem_stage_rf_waddr
add wave -noupdate /tb/dut/mem_stage_csr_rd_data
add wave -noupdate /tb/dut/rf_wb_en
add wave -noupdate /tb/dut/rf_wb_addr
add wave -noupdate /tb/dut/rf_wb_data
add wave -noupdate /tb/dut/decoded_mem_rd_en
add wave -noupdate /tb/dut/decoded_mem_wr_en
add wave -noupdate /tb/dut/decoded_is_branch_type
add wave -noupdate /tb/dut/decoded_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/decoded_alu_src_reg_h_imm_low
add wave -noupdate /tb/dut/decoded_rf_wr_en
add wave -noupdate /tb/dut/decoded_is_uncond_jmp
add wave -noupdate /tb/dut/decoded_operand_a_is_from_pc
add wave -noupdate /tb/dut/decoded_jmp_src_reg_h_imm_l
add wave -noupdate /tb/dut/decoded_sel_cnt
add wave -noupdate /tb/dut/decoded_imm
add wave -noupdate /tb/dut/decoded_alu_op
add wave -noupdate /tb/dut/decoded_rf_waddr
add wave -noupdate /tb/dut/decodede_csr_write_type
add wave -noupdate /tb/dut/decoded_csr_rf_wb_en
add wave -noupdate /tb/dut/decoded_csr_addr
add wave -noupdate /tb/dut/decoded_exception_is_valid
add wave -noupdate /tb/dut/decoded_exception_code
add wave -noupdate /tb/dut/decoded_is_mret
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
add wave -noupdate /tb/dut/id_stage_is_uncond_jmp
add wave -noupdate /tb/dut/id_stage_operand_a_is_from_pc
add wave -noupdate /tb/dut/id_stage_jmp_src_reg_h_imm_l
add wave -noupdate /tb/dut/id_stage_csr_write_type
add wave -noupdate /tb/dut/id_stage_csr_rf_wb_en
add wave -noupdate /tb/dut/id_stage_csr_addr
add wave -noupdate /tb/dut/id_stage_exception_is_valid
add wave -noupdate /tb/dut/id_stage_is_mret
add wave -noupdate /tb/dut/exe_stage_mem_rd_en
add wave -noupdate /tb/dut/exe_stage_mem_wr_en
add wave -noupdate /tb/dut/exe_stage_is_branch_type
add wave -noupdate /tb/dut/exe_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/exe_stage_alu_src_reg_h_imm_low
add wave -noupdate /tb/dut/exe_stage_rf_wr_en
add wave -noupdate /tb/dut/exe_stage_is_uncond_jmp
add wave -noupdate /tb/dut/exe_stage_operand_a_is_from_pc
add wave -noupdate /tb/dut/exe_stage_jmp_src_reg_h_imm_l
add wave -noupdate /tb/dut/exe_stage_pc
add wave -noupdate /tb/dut/exe_stage_sel_cnt
add wave -noupdate /tb/dut/exe_stage_rf_rdata_a
add wave -noupdate /tb/dut/exe_stage_rf_rdata_b
add wave -noupdate /tb/dut/exe_stage_imm
add wave -noupdate /tb/dut/exe_stage_alu_op
add wave -noupdate /tb/dut/exe_stage_rf_waddr
add wave -noupdate /tb/dut/exe_stage_rf_raddr_a
add wave -noupdate /tb/dut/exe_stage_rf_raddr_b
add wave -noupdate /tb/dut/exe_stage_csr_write_type
add wave -noupdate /tb/dut/exe_stage_csr_rf_wb_en
add wave -noupdate /tb/dut/exe_stage_csr_addr
add wave -noupdate /tb/dut/exe_stage_exception_is_valid
add wave -noupdate /tb/dut/exe_stage_exception_code
add wave -noupdate /tb/dut/exe_stage_is_mret
add wave -noupdate /tb/dut/direct_jmp_dest
add wave -noupdate /tb/dut/exe_stage_forward_a
add wave -noupdate /tb/dut/operand_a_from_reg
add wave -noupdate /tb/dut/exe_stage_csr_rs1_data
add wave -noupdate /tb/dut/exe_stage_operand_a
add wave -noupdate /tb/dut/exe_stage_forward_b
add wave -noupdate /tb/dut/exe_stage_non_imm_operand_b
add wave -noupdate /tb/dut/exe_stage_operand_b
add wave -noupdate /tb/dut/exe_stage_alu_result
add wave -noupdate /tb/dut/exe_stage_final_alu_result
add wave -noupdate /tb/dut/link_addr
add wave -noupdate /tb/dut/mem_stage_rf_wr_en
add wave -noupdate /tb/dut/mem_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/mem_stage_rf_wr_en_after_judging_mmio
add wave -noupdate /tb/dut/mem_stage_sel_cnt
add wave -noupdate /tb/dut/mem_stage_csr_rs1_data
add wave -noupdate /tb/dut/mem_stage_csr_write_type
add wave -noupdate /tb/dut/mem_stage_csr_addr
add wave -noupdate /tb/dut/mem_stage_exception_code
add wave -noupdate /tb/dut/mem_stage_pc
add wave -noupdate /tb/dut/tmp_csr_intermediate_val
add wave -noupdate /tb/dut/within_csr_tmp_val_index
add wave -noupdate /tb/dut/timer_counter
add wave -noupdate /tb/dut/should_increment_mtime
add wave -noupdate /tb/dut/mem_stage_rd_mem_data
add wave -noupdate /tb/dut/final_mem_stage_rf_w_src_mem_h_alu_l
add wave -noupdate /tb/dut/final_mem_stage_rf_wr_en
add wave -noupdate /tb/dut/wb_stage_rd_mem_data
add wave -noupdate /tb/dut/wb_stage_alu_result
add wave -noupdate /tb/dut/wb_stage_rf_w_src_mem_h_alu_l
add wave -noupdate -group bus /tb/dut/bus_is_busy
add wave -noupdate -group bus /tb/dut/wbm0_stb_o
add wave -noupdate -group bus /tb/dut/wbm1_stb_o
add wave -noupdate -group bus /tb/dut/wbm0_ack_i
add wave -noupdate -group bus /tb/dut/wbm1_ack_i
add wave -noupdate -group bus /tb/dut/wbm0_addr_o
add wave -noupdate -group bus /tb/dut/wbm1_addr_o
add wave -noupdate -group bus /tb/dut/wbm0_dat_o
add wave -noupdate -group bus /tb/dut/wbm1_dat_o
add wave -noupdate -group bus /tb/dut/wbm0_dat_i
add wave -noupdate -group bus /tb/dut/wbm1_dat_i
add wave -noupdate -group bus /tb/dut/wbm0_sel_o
add wave -noupdate -group bus /tb/dut/wbm1_sel_o
add wave -noupdate -group bus /tb/dut/wbm0_we_o
add wave -noupdate -group bus /tb/dut/wbm1_we_o
add wave -noupdate -group bus /tb/dut/wbs_stb_i
add wave -noupdate -group bus /tb/dut/wbs_cyc_i
add wave -noupdate -group bus /tb/dut/wbs_ack_o
add wave -noupdate -group bus /tb/dut/wbs_addr_i
add wave -noupdate -group bus /tb/dut/wbs_dat_o
add wave -noupdate -group bus /tb/dut/wbs_dat_i
add wave -noupdate -group bus /tb/dut/wbs_sel_i
add wave -noupdate -group bus /tb/dut/wbs_we_i
add wave -noupdate -group bus /tb/dut/wbs0_adr_i
add wave -noupdate -group bus /tb/dut/wbs0_dat_o
add wave -noupdate -group bus /tb/dut/wbs0_dat_i
add wave -noupdate -group bus /tb/dut/wbs0_we_i
add wave -noupdate -group bus /tb/dut/wbs0_sel_i
add wave -noupdate -group bus /tb/dut/wbs0_stb_i
add wave -noupdate -group bus /tb/dut/wbs0_ack_o
add wave -noupdate -group bus /tb/dut/wbs0_cyc_i
add wave -noupdate -group bus /tb/dut/wbs1_adr_i
add wave -noupdate -group bus /tb/dut/wbs1_dat_o
add wave -noupdate -group bus /tb/dut/wbs1_dat_i
add wave -noupdate -group bus /tb/dut/wbs1_we_i
add wave -noupdate -group bus /tb/dut/wbs1_sel_i
add wave -noupdate -group bus /tb/dut/wbs1_stb_i
add wave -noupdate -group bus /tb/dut/wbs1_ack_o
add wave -noupdate -group bus /tb/dut/wbs1_cyc_i
add wave -noupdate -group bus /tb/dut/wbs2_adr_i
add wave -noupdate -group bus /tb/dut/wbs2_dat_o
add wave -noupdate -group bus /tb/dut/wbs2_dat_i
add wave -noupdate -group bus /tb/dut/wbs2_we_i
add wave -noupdate -group bus /tb/dut/wbs2_sel_i
add wave -noupdate -group bus /tb/dut/wbs2_stb_i
add wave -noupdate -group bus /tb/dut/wbs2_ack_o
add wave -noupdate -group bus /tb/dut/wbs2_cyc_i
add wave -noupdate -group devices /tb/dut/base_ram_data
add wave -noupdate -group devices /tb/dut/base_ram_addr
add wave -noupdate -group devices /tb/dut/base_ram_be_n
add wave -noupdate -group devices /tb/dut/base_ram_ce_n
add wave -noupdate -group devices /tb/dut/base_ram_oe_n
add wave -noupdate -group devices /tb/dut/base_ram_we_n
add wave -noupdate -group devices /tb/dut/ext_ram_data
add wave -noupdate -group devices /tb/dut/ext_ram_addr
add wave -noupdate -group devices /tb/dut/ext_ram_be_n
add wave -noupdate -group devices /tb/dut/ext_ram_ce_n
add wave -noupdate -group devices /tb/dut/ext_ram_oe_n
add wave -noupdate -group devices /tb/dut/ext_ram_we_n
add wave -noupdate -group devices /tb/dut/txd
add wave -noupdate -group devices /tb/dut/rxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3205701383 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 252
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
WaveRestoreZoom {0 ps} {4558536 ps}
