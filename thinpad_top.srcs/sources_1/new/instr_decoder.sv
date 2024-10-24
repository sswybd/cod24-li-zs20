module instr_decoder #(
    parameter INSTR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SELECT_WIDTH = (DATA_WIDTH / 8),
    parameter REG_ADDR_WIDTH = 5,
    parameter ALU_OP_ENCODING_WIDTH = 4,
    localparam LUI_OPCODE = 5'b01101,
    localparam B_TYPE_OPCODE = 5'b11000,
    localparam S_TYPE_OPCODE = 5'b01000
) (
    input wire [INSTR_WIDTH-1:0] instr_i,

    // pure control signal outputs
    output wire decoded_mem_rd_en_o,
    output wire decoded_mem_wr_en_o,
    output wire decoded_is_branch_type_o,
    output wire decoded_rf_w_src_mem_h_alu_l_o,
    output wire decoded_alu_src_reg_h_imm_low_o,
    output wire decoded_rf_wr_en_o,

    output wire [SELECT_WIDTH-1:0] decoded_sel_o,
    output wire [REG_ADDR_WIDTH-1:0] decoded_rf_raddr_a_o,
    output wire [REG_ADDR_WIDTH-1:0] decoded_rf_raddr_b_o,
    output wire [DATA_WIDTH-1:0] decoded_imm_o,
    output wire [ALU_OP_ENCODING_WIDTH-1:0] decoded_alu_op_o,
    output wire [REG_ADDR_WIDTH-1:0] decoded_rf_waddr_o
);

wire [4:0] opcode_segment;
assign opcode_segment = instr_i[6:2];  // the last two bits are `2'b11` for a valid RV32I instr

wire [2:0] funct3;
assign funct3 = instr_i[14:12];

// just in case, to ensure the destination reg is set to zero if not needed, 
// maybe preventing possible and unwanted forwarding
assign decoded_rf_waddr_o = ((opcode_segment != B_TYPE_OPCODE) && (opcode_segment != S_TYPE_OPCODE)) ? instr_i[11:7] : 'd0;

// TODO: yet to support more instrs
assign decoded_alu_op_o = 

// TODO: yet to support more instrs
// TODO: yet to support more instrs
// TODO: yet to support more instrs
// TODO: yet to support more instrs
// TODO: yet to support more instrs
// TODO: yet to support more instrs
// TODO: yet to support more instrs

endmodule