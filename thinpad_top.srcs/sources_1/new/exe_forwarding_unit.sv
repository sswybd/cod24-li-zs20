module exe_forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
) (
    input wire exe_to_mem_rf_wr_en_i,
    input wire mem_to_wb_rf_wr_en_i,
    input wire [REG_ADDR_WIDTH-1:0] exe_stage_operand_a_rf_addr_i,
    input wire [REG_ADDR_WIDTH-1:0] exe_stage_operand_b_rf_addr_i,
    input wire [REG_ADDR_WIDTH-1:0] exe_to_mem_rf_wr_addr_i,
    input wire [REG_ADDR_WIDTH-1:0] mem_to_wb_rf_wr_addr_i,
    input wire mem_stage_rf_w_src_mem_h_alu_l_i,
    input wire csr_wb_en_i,
    input wire [REG_ADDR_WIDTH-1:0] csr_wb_addr_i,
    output wire [1:0] forward_a_o,  // 'b00: choose #0, 'b01: #1, 'b10: #2, 'b11: choose csr
    output wire [1:0] forward_b_o   // same as `forward_a_o`
);

assign forward_a_o = (csr_wb_en_i && (csr_wb_addr_i == exe_stage_operand_a_rf_addr_i) &&
                      (csr_wb_addr_i != 'd0)) ? 2'b11 :
                     (exe_to_mem_rf_wr_en_i && (exe_to_mem_rf_wr_addr_i == exe_stage_operand_a_rf_addr_i) &&
                      (exe_to_mem_rf_wr_addr_i != 'd0) && (!mem_stage_rf_w_src_mem_h_alu_l_i)) ? 2'b10 :
                     ((mem_to_wb_rf_wr_addr_i == exe_stage_operand_a_rf_addr_i) &&
                      (mem_to_wb_rf_wr_addr_i != 'd0) &&
                      mem_to_wb_rf_wr_en_i) ? 2'b01 : 2'b00;

assign forward_b_o = (csr_wb_en_i && (csr_wb_addr_i == exe_stage_operand_b_rf_addr_i) &&
                      (csr_wb_addr_i != 'd0)) ? 2'b11 :
                     (exe_to_mem_rf_wr_en_i && (exe_to_mem_rf_wr_addr_i == exe_stage_operand_b_rf_addr_i) &&
                      (exe_to_mem_rf_wr_addr_i != 'd0) && (!mem_stage_rf_w_src_mem_h_alu_l_i)) ? 2'b10 :
                     ((mem_to_wb_rf_wr_addr_i == exe_stage_operand_b_rf_addr_i) &&
                      (mem_to_wb_rf_wr_addr_i != 'd0) &&
                      mem_to_wb_rf_wr_en_i) ? 2'b01 : 2'b00;

endmodule