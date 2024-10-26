module imm_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] non_imm_i,
    input wire [DATA_WIDTH-1:0] imm_i,
    input wire non_imm_h_imm_low_ctrl_i,
    output wire [DATA_WIDTH-1:0] operand_o
);

assign operand_o = non_imm_h_imm_low_ctrl_i ? non_imm_i : imm_i;

endmodule