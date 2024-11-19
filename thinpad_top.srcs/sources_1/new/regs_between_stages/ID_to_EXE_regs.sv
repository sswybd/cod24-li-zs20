`include "simple_reg_macro.h"

module ID_to_EXE_regs #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ALU_OP_ENCODING_WIDTH = 5,
    parameter REG_ADDR_WIDTH = 5,
    parameter CSR_ADDR_WIDTH = 12,
    parameter EXCEPTION_CODE_WIDTH = 31
) (
    input wire sys_clk,
    input wire sys_rst,

    input wire wr_en,

    input wire mem_rd_en_i,
    input wire mem_wr_en_i,
    input wire is_branch_type_i,
    input wire rf_w_src_mem_h_alu_l_i,
    input wire alu_src_reg_h_imm_low_i,
    input wire rf_wr_en_i,
    input wire is_uncond_jmp_i,
    input wire operand_a_is_from_pc_i,
    input wire jmp_src_reg_h_imm_l_i,

    input wire [ADDR_WIDTH-1:0] pc_i,

    input wire [1:0] sel_cnt_i,

    input wire [DATA_WIDTH-1:0] rf_rdata_a_i,
    input wire [DATA_WIDTH-1:0] rf_rdata_b_i,
    input wire [DATA_WIDTH-1:0] imm_i,
    input wire [ALU_OP_ENCODING_WIDTH-1:0] alu_op_i,
    input wire [REG_ADDR_WIDTH-1:0] rf_waddr_i,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_a_i,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_b_i,
    input wire [1:0] csr_write_type_i,
    input wire csr_rf_wb_en_i,
    input wire [CSR_ADDR_WIDTH-1:0] csr_addr_i,
    input wire exception_is_valid_i,
    input wire [EXCEPTION_CODE_WIDTH-1:0] exception_code_i,
    input wire is_mret_i,
    
    output logic mem_rd_en,
    output logic mem_wr_en,
    output logic is_branch_type,
    output logic rf_w_src_mem_h_alu_l,
    output logic alu_src_reg_h_imm_low,
    output logic rf_wr_en,
    output logic is_uncond_jmp,
    output logic operand_a_is_from_pc,
    output logic jmp_src_reg_h_imm_l,

    output logic [ADDR_WIDTH-1:0] pc,

    output logic [1:0] sel_cnt,

    output logic [DATA_WIDTH-1:0] rf_rdata_a,
    output logic [DATA_WIDTH-1:0] rf_rdata_b,
    output logic [DATA_WIDTH-1:0] imm,
    output logic [ALU_OP_ENCODING_WIDTH-1:0] alu_op,
    output logic [REG_ADDR_WIDTH-1:0] rf_waddr,
    output logic [REG_ADDR_WIDTH-1:0] rf_raddr_a,
    output logic [REG_ADDR_WIDTH-1:0] rf_raddr_b,
    output logic [1:0] csr_write_type,
    output logic csr_rf_wb_en,
    output logic [CSR_ADDR_WIDTH-1:0] csr_addr,
    output logic exception_is_valid,
    output logic [EXCEPTION_CODE_WIDTH-1:0] exception_code,
    output logic is_mret
);

`simple_reg(mem_rd_en, mem_rd_en_i);
`simple_reg(mem_wr_en, mem_wr_en_i);
`simple_reg(is_branch_type, is_branch_type_i);
`simple_reg(rf_w_src_mem_h_alu_l, rf_w_src_mem_h_alu_l_i);
`simple_reg(alu_src_reg_h_imm_low, alu_src_reg_h_imm_low_i);
`simple_reg(rf_wr_en, rf_wr_en_i);
`simple_reg(is_uncond_jmp, is_uncond_jmp_i);
`simple_reg(operand_a_is_from_pc, operand_a_is_from_pc_i);
`simple_reg(jmp_src_reg_h_imm_l, jmp_src_reg_h_imm_l_i);

`simple_reg(pc, pc_i);

`simple_reg(sel_cnt, sel_cnt_i);

`simple_reg(rf_rdata_a, rf_rdata_a_i);
`simple_reg(rf_rdata_b, rf_rdata_b_i);
`simple_reg(imm, imm_i);
`simple_reg(alu_op, alu_op_i);
`simple_reg(rf_waddr, rf_waddr_i);
`simple_reg(rf_raddr_a, rf_raddr_a_i);
`simple_reg(rf_raddr_b, rf_raddr_b_i);
`simple_reg(csr_write_type, csr_write_type_i);
`simple_reg(csr_rf_wb_en, csr_rf_wb_en_i);
`simple_reg(csr_addr, csr_addr_i);
`simple_reg(exception_is_valid, exception_is_valid_i);
`simple_reg(exception_code, exception_code_i);
`simple_reg(is_mret, is_mret_i);

endmodule