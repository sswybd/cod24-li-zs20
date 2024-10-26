`include "simple_reg_macro.sv"

module EXE_to_MEM_regs #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
) (
    input wire sys_clk,
    input wire sys_rst,
    input wire wr_en,

    input wire mem_rd_en_i,
    input wire mem_wr_en_i,
    input wire rf_w_src_mem_h_alu_l_i,
    input wire rf_wr_en_i,
    input wire [1:0] sel_cnt_i,
    input wire [DATA_WIDTH-1:0] alu_result_i,
    input wire [DATA_WIDTH-1:0] non_imm_operand_b_i,
    input wire [REG_ADDR_WIDTH-1:0] rf_waddr_i,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_b_i,

    output logic mem_rd_en,
    output logic mem_wr_en,
    output logic rf_w_src_mem_h_alu_l,
    output logic rf_wr_en,
    output logic [1:0] sel_cnt,
    output logic [DATA_WIDTH-1:0] alu_result,
    output logic [DATA_WIDTH-1:0] non_imm_operand_b,
    output logic [REG_ADDR_WIDTH-1:0] rf_waddr,
    output logic [REG_ADDR_WIDTH-1:0] rf_raddr_b
);

`simple_reg(mem_rd_en, mem_rd_en_i);
`simple_reg(mem_wr_en, mem_wr_en_i);
`simple_reg(rf_w_src_mem_h_alu_l, rf_w_src_mem_h_alu_l_i);
`simple_reg(rf_wr_en, rf_wr_en_i);
`simple_reg(sel_cnt, sel_cnt_i);
`simple_reg(alu_result, alu_result_i);
`simple_reg(non_imm_operand_b, non_imm_operand_b_i);
`simple_reg(rf_waddr, rf_waddr_i);
`simple_reg(rf_raddr_b, rf_raddr_b_i);

endmodule