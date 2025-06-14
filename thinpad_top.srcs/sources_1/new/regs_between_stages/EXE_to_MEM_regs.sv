`include "simple_reg_macro.h"

module EXE_to_MEM_regs #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5,
    parameter CSR_ADDR_WIDTH = 12,
    parameter EXCEPTION_CODE_WIDTH = 31,
    parameter ADDR_WIDTH = 32
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
    input wire [DATA_WIDTH-1:0] csr_rs1_data_i,
    input wire [1:0] csr_write_type_i,
    input wire csr_rf_wb_en_i,
    input wire [CSR_ADDR_WIDTH-1:0] csr_addr_i,
    input wire exception_is_valid_i,
    input wire [EXCEPTION_CODE_WIDTH-1:0] exception_code_i,
    input wire is_mret_i,
    input wire [ADDR_WIDTH-1:0] pc_i,
    input wire [DATA_WIDTH-1:0] mip_i,

    output logic mem_rd_en,
    output logic mem_wr_en,
    output logic rf_w_src_mem_h_alu_l,
    output logic rf_wr_en,
    output logic [1:0] sel_cnt,
    output logic [DATA_WIDTH-1:0] alu_result,
    output logic [DATA_WIDTH-1:0] non_imm_operand_b,
    output logic [REG_ADDR_WIDTH-1:0] rf_waddr,
    output logic [DATA_WIDTH-1:0] csr_rs1_data,
    output logic [1:0] csr_write_type,
    output logic csr_rf_wb_en,
    output logic [CSR_ADDR_WIDTH-1:0] csr_addr,
    output logic exception_is_valid,
    output logic [EXCEPTION_CODE_WIDTH-1:0] exception_code,
    output logic is_mret,
    output logic [ADDR_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] mip
);

`simple_reg(mem_rd_en, mem_rd_en_i);
`simple_reg(mem_wr_en, mem_wr_en_i);
`simple_reg(rf_w_src_mem_h_alu_l, rf_w_src_mem_h_alu_l_i);
`simple_reg(rf_wr_en, rf_wr_en_i);
`simple_reg(sel_cnt, sel_cnt_i);
`simple_reg(alu_result, alu_result_i);
`simple_reg(non_imm_operand_b, non_imm_operand_b_i);
`simple_reg(rf_waddr, rf_waddr_i);
`simple_reg(csr_rs1_data, csr_rs1_data_i);
`simple_reg(csr_write_type, csr_write_type_i);
`simple_reg(csr_rf_wb_en, csr_rf_wb_en_i);
`simple_reg(csr_addr, csr_addr_i);
`simple_reg(exception_is_valid, exception_is_valid_i);
`simple_reg(exception_code, exception_code_i);
`simple_reg(is_mret, is_mret_i);
`simple_reg(pc, pc_i);
`simple_reg(mip, mip_i);

endmodule