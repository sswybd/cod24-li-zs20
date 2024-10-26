`include "simple_reg_macro.sv"

module MEM_to_WB_regs #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
) (
    input wire sys_clk,
    input wire sys_rst,
    input wire wr_en,

    input wire rf_w_src_mem_h_alu_l_i,
    input wire rf_wr_en_i,
    input wire [DATA_WIDTH-1:0] rd_mem_data_i,
    input wire [DATA_WIDTH-1:0] alu_result_i,
    input wire [REG_ADDR_WIDTH-1:0] rf_waddr_i,

    output logic rf_w_src_mem_h_alu_l,
    output logic rf_wr_en,
    output logic [DATA_WIDTH-1:0] rd_mem_data,
    output logic [DATA_WIDTH-1:0] alu_result,
    output logic [REG_ADDR_WIDTH-1:0] rf_waddr
);

`simple_reg(rf_w_src_mem_h_alu_l, rf_w_src_mem_h_alu_l_i);
`simple_reg(rf_wr_en, rf_wr_en_i);
`simple_reg(rd_mem_data, rd_mem_data_i);
`simple_reg(alu_result, alu_result_i);
`simple_reg(rf_waddr, rf_waddr_i);

endmodule