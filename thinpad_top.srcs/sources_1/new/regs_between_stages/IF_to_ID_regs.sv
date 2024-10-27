`include "simple_reg_macro.sv"

module IF_to_ID_regs #(
    parameter ADDR_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
    parameter [INSTR_WIDTH-1:0] NOP = 'h00000013
) (
    input wire sys_clk,
    input wire sys_rst,
    input wire wr_en,
    input wire [INSTR_WIDTH-1:0] instr_i,
    input wire [ADDR_WIDTH-1:0] pc_i,

    output logic [INSTR_WIDTH-1:0] instr,
    output logic [ADDR_WIDTH-1:0] pc
);

`simple_reg_with_reset(instr, instr_i, NOP);
`simple_reg(pc, pc_i);

endmodule