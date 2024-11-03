module id_stage_bubblify_unit (
    input wire mem_rd_en_i,
    input wire mem_wr_en_i,
    input wire is_branch_type_i,
    input wire rf_w_src_mem_h_alu_l_i,
    input wire alu_src_reg_h_imm_low_i,
    input wire rf_wr_en_i,
    input wire is_uncond_jmp_i,
    input wire operand_a_is_from_pc_i,
    input wire jmp_src_reg_h_imm_l_i,
    input wire id_stage_into_bubble_i,

    output wire mem_rd_en_o,
    output wire mem_wr_en_o,
    output wire is_branch_type_o,
    output wire rf_w_src_mem_h_alu_l_o,
    output wire alu_src_reg_h_imm_low_o,
    output wire rf_wr_en_o,
    output wire is_uncond_jmp_o,
    output wire operand_a_is_from_pc_o,
    output wire jmp_src_reg_h_imm_l_o
);

assign mem_rd_en_o = id_stage_into_bubble_i ? 1'd0 : mem_rd_en_i;
assign mem_wr_en_o = id_stage_into_bubble_i ? 1'd0 : mem_wr_en_i;
assign is_branch_type_o = id_stage_into_bubble_i ? 1'd0 : is_branch_type_i;
assign rf_w_src_mem_h_alu_l_o = id_stage_into_bubble_i ? 1'd0 : rf_w_src_mem_h_alu_l_i;
assign alu_src_reg_h_imm_low_o = id_stage_into_bubble_i ? 1'd0 : alu_src_reg_h_imm_low_i;
assign rf_wr_en_o = id_stage_into_bubble_i ? 1'd0 : rf_wr_en_i;
assign is_uncond_jmp_o = id_stage_into_bubble_i ? 1'd0 : is_uncond_jmp_i;
assign operand_a_is_from_pc_o = id_stage_into_bubble_i ? 1'd0 : operand_a_is_from_pc_i;
assign jmp_src_reg_h_imm_l_o = id_stage_into_bubble_i ? 1'd0 : jmp_src_reg_h_imm_l_i;

endmodule