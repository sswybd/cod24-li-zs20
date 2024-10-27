module exe_forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
) (
    input wire exe_to_mem_rf_wr_en_i,
    input wire mem_to_wb_rf_wr_en_i,
    input wire [REG_ADDR_WIDTH-1:0] exe_stage_operand_a_rf_addr_i,
    input wire [REG_ADDR_WIDTH-1:0] exe_stage_operand_b_rf_addr_i,
    input wire [REG_ADDR_WIDTH-1:0] exe_to_mem_rf_wr_addr_i,
    input wire [REG_ADDR_WIDTH-1:0] mem_to_wb_rf_wr_addr_i,
    output wire [1:0] forward_a_o,  // 2'b00: choose #0, 2'b01: choose #1, 2'b10: choose #2, 2'b11: output all 0s
    output wire [1:0] forward_b_o   // same for `forward_b_o`
);

assign forward_a_o = ((mem_to_wb_rf_wr_addr_i == exe_stage_operand_a_rf_addr_i) && (mem_to_wb_rf_wr_addr_i != 'd0)
                    && mem_to_wb_rf_wr_en_i &&
                    (!(exe_to_mem_rf_wr_en_i && (exe_to_mem_rf_wr_addr_i == exe_stage_operand_a_rf_addr_i) 
                    && (exe_to_mem_rf_wr_addr_i != 'd0)))) ? 2'b01 :
                    (exe_to_mem_rf_wr_en_i && (exe_to_mem_rf_wr_addr_i == exe_stage_operand_a_rf_addr_i)
                    && (exe_to_mem_rf_wr_addr_i != 'd0)) ? 2'b10 : 2'b00;

assign forward_b_o = ((mem_to_wb_rf_wr_addr_i == exe_stage_operand_b_rf_addr_i) && (mem_to_wb_rf_wr_addr_i != 'd0)
                    && mem_to_wb_rf_wr_en_i && 
                    (!(exe_to_mem_rf_wr_en_i && (exe_to_mem_rf_wr_addr_i == exe_stage_operand_b_rf_addr_i) 
                    && (exe_to_mem_rf_wr_addr_i != 'd0)))) ? 2'b01 :
                    (exe_to_mem_rf_wr_en_i && (exe_to_mem_rf_wr_addr_i == exe_stage_operand_b_rf_addr_i) 
                    && (exe_to_mem_rf_wr_addr_i != 'd0)) ? 2'b10 : 2'b00;

endmodule