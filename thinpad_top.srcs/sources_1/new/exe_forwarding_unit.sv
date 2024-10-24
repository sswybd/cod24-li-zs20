module exe_forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
) (
    input wire exe_to_mem_rf_wr_en,
    input wire mem_to_wb_rf_wr_en,
    input wire [REG_ADDR_WIDTH-1:0] exe_stage_operand_a_rf_addr,
    input wire [REG_ADDR_WIDTH-1:0] exe_stage_operand_b_rf_addr,
    input wire [REG_ADDR_WIDTH-1:0] exe_to_mem_rf_wr_addr,
    input wire [REG_ADDR_WIDTH-1:0] mem_to_wb_rf_wr_addr,
    output wire [1:0] forward_a,  // 2'b00: choose #0, 2'b01: choose #1, 2'b10: choose #2, 2'b11: output all zero
    output wire [1:0] forward_b   // same for `forward_b`
);

assign forward_a = ((mem_to_wb_rf_wr_addr == exe_stage_operand_a_rf_addr) && (mem_to_wb_rf_wr_addr != 'd0) && 
                    mem_to_wb_rf_wr_en && 
                    (!(exe_to_mem_rf_wr_en && (exe_to_mem_rf_wr_addr == exe_stage_operand_a_rf_addr) 
                    && (exe_to_mem_rf_wr_addr != 'd0)))) ?
                    2'b01 :
                    (exe_to_mem_rf_wr_en && (exe_to_mem_rf_wr_addr == exe_stage_operand_a_rf_addr) 
                    && (exe_to_mem_rf_wr_addr != 'd0)) ?
                    2'b10 : 2'b00;

assign forward_b = ((mem_to_wb_rf_wr_addr == exe_stage_operand_b_rf_addr) && (mem_to_wb_rf_wr_addr != 'd0) && 
                    mem_to_wb_rf_wr_en && 
                    (!(exe_to_mem_rf_wr_en && (exe_to_mem_rf_wr_addr == exe_stage_operand_b_rf_addr) 
                    && (exe_to_mem_rf_wr_addr != 'd0)))) ?
                    2'b01 :
                    (exe_to_mem_rf_wr_en && (exe_to_mem_rf_wr_addr == exe_stage_operand_b_rf_addr) 
                    && (exe_to_mem_rf_wr_addr != 'd0)) ?
                    2'b10 : 2'b00;

endmodule