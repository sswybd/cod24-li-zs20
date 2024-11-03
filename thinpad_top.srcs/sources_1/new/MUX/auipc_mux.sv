module auipc_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] pc_operand_i,
    input wire [DATA_WIDTH-1:0] reg_operand_i,
    input wire operand_is_from_pc_ctrl_i,
    output wire [DATA_WIDTH-1:0] operand_o
);

assign operand_o = operand_is_from_pc_ctrl_i ? pc_operand_i : reg_operand_i;

endmodule