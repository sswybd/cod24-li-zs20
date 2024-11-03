module instr_decoder #(
    parameter INSTR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5,
    parameter ALU_OP_ENCODING_WIDTH = 4,

    localparam LUI_OPCODE = 5'b01101,
    localparam B_TYPE_OPCODE = 5'b11000,
    localparam S_TYPE_OPCODE = 5'b01000,
    localparam BASIC_I_TYPE_WITHOUT_LOAD_OPCODE = 5'b00100,
    localparam R_TYPE_OPCODE = 5'b01100,
    localparam LOAD_TYPE_OPCODE = 5'b00000,
    localparam J_TYPE_OPCODE = 5'b11011,  // only JAL is of J-type
    localparam AUIPC_OPCODE = 5'b00101,
    localparam JALR_OPCODE = 5'b11001
) (
    input wire [INSTR_WIDTH-1:0] instr_i,

    // pure control signal outputs
    output wire decoded_mem_rd_en_o,
    output wire decoded_mem_wr_en_o,
    output wire decoded_is_branch_type_o,
    output wire decoded_rf_w_src_mem_h_alu_l_o,
    output wire decoded_alu_src_reg_h_imm_low_o,
    output wire decoded_rf_wr_en_o,
    output wire decoded_is_uncond_jmp_o,
    output wire decoded_operand_a_is_from_pc_o,
    output wire decoded_jmp_src_reg_h_imm_l_o,

    output wire [1:0] decoded_sel_cnt_o,  // 2'd0 means lw/sw; 2'd1 means lb/wb; 2'd2 means lh/sw; 2'd3 means nill
    output wire [REG_ADDR_WIDTH-1:0] decoded_rf_raddr_a_o,
    output wire [REG_ADDR_WIDTH-1:0] decoded_rf_raddr_b_o,
    output logic [DATA_WIDTH-1:0] decoded_imm_o,
    output wire [ALU_OP_ENCODING_WIDTH-1:0] decoded_alu_op_o,
    output wire [REG_ADDR_WIDTH-1:0] decoded_rf_waddr_o
);

wire [4:0] opcode_segment;
assign opcode_segment = instr_i[6:2];  // the last two bits are `2'b11` for a valid RV32I instr

wire [2:0] funct3;
assign funct3 = instr_i[14:12];

// just in case, to ensure the destination reg is set to zero if not needed, 
// maybe preventing possible and unwanted forwarding
assign decoded_rf_waddr_o = ((opcode_segment != B_TYPE_OPCODE) && (opcode_segment != S_TYPE_OPCODE)) ?
                            instr_i[11:7] : 'd0;

assign decoded_alu_op_o = (opcode_segment == LUI_OPCODE) ? 'd12 :                                               // output operand_b
                          ((opcode_segment == S_TYPE_OPCODE) || (opcode_segment == LOAD_TYPE_OPCODE)
                        || (((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) || (opcode_segment == R_TYPE_OPCODE)) && (funct3 == 3'b000))
                        || (opcode_segment == AUIPC_OPCODE) || (opcode_segment == JALR_OPCODE)) ? 'd1 :       // add
                          (((opcode_segment == B_TYPE_OPCODE) && (funct3 == 3'b000))
                        || (((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) || (opcode_segment == R_TYPE_OPCODE)) &&
                          (funct3 == 3'b100))) ? 'd5 :                     // xor
                          ((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) && (funct3 == 3'b111)) ? 'd3 :  // and
                          ((opcode_segment == B_TYPE_OPCODE) && (funct3 == 3'b001)) ? 'd10 :  // xnor
                          (((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) || (opcode_segment == R_TYPE_OPCODE)) &&
                          (funct3 == 3'b110)) ? 'd4 :  // or
                          (((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) || (opcode_segment == R_TYPE_OPCODE)) &&
                          (funct3 == 3'b001)) ? 'd7 :  // sll
                          (((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) || (opcode_segment == R_TYPE_OPCODE)) &&
                          (funct3 == 3'b101)) ? 'd8 :  // srl
                          'd0;

always_comb begin
    decoded_imm_o = 'd0;

    if ((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) ||
        (opcode_segment == LOAD_TYPE_OPCODE) ||
        (opcode_segment == JALR_OPCODE)) begin
        decoded_imm_o[11:0] = instr_i[31:20];
        if (!((opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) &&
              ((funct3 == 3'b001) || (funct3 == 3'b101)))) begin  // not a shift
            decoded_imm_o[31:12] = {20{instr_i[31]}};  // sign extension
        end
        else begin  // a shift
            decoded_imm_o[11:5] = 'd0;
        end
    end
    else if ((opcode_segment == LUI_OPCODE) || (opcode_segment == AUIPC_OPCODE)) begin
        decoded_imm_o[31:12] = instr_i[31:12];
    end
    else if (opcode_segment == S_TYPE_OPCODE) begin
        decoded_imm_o[4:0] = instr_i[11:7];
        decoded_imm_o[11:5] = instr_i[31:25];
        decoded_imm_o[31:12] = {20{instr_i[31]}};  // sign extension
    end
    else if (opcode_segment == B_TYPE_OPCODE) begin
        decoded_imm_o[12:0] = {instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        decoded_imm_o[31:12] = {20{instr_i[31]}};  // sign extension
    end
    else if (opcode_segment == J_TYPE_OPCODE) begin
        decoded_imm_o[31:21] = {11{instr_i[31]}};  // sign extension
        decoded_imm_o[20:0] = {instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
    end
    else begin
        decoded_imm_o = 'd0;
    end
end

assign decoded_rf_raddr_b_o = ((opcode_segment == B_TYPE_OPCODE) ||
                               (opcode_segment == S_TYPE_OPCODE) ||
                               (opcode_segment == R_TYPE_OPCODE)) ? instr_i[24:20] : 'd0;

assign decoded_rf_raddr_a_o = ((opcode_segment != LUI_OPCODE) &&
                               (opcode_segment != AUIPC_OPCODE) &&
                               (opcode_segment != J_TYPE_OPCODE)) ? instr_i[19:15] : 'd0;

assign decoded_sel_cnt_o = (((opcode_segment == S_TYPE_OPCODE) || (opcode_segment == LOAD_TYPE_OPCODE))
                         && (funct3 == 3'b000)) ? 'd1 :  // byte
                         (((opcode_segment == S_TYPE_OPCODE) || (opcode_segment == LOAD_TYPE_OPCODE))
                         && (funct3 == 3'b001)) ? 'd2 :  // half word
                        (((opcode_segment == S_TYPE_OPCODE) || (opcode_segment == LOAD_TYPE_OPCODE))
                         && (funct3 == 3'b010)) ? 'd0 : 'd0;   // word

assign decoded_jmp_src_reg_h_imm_l_o = (opcode_segment == JALR_OPCODE);

assign decoded_operand_a_is_from_pc_o = (opcode_segment == AUIPC_OPCODE);

assign decoded_is_uncond_jmp_o = ((opcode_segment == J_TYPE_OPCODE) || (opcode_segment == JALR_OPCODE));

assign decoded_rf_wr_en_o = (opcode_segment == LUI_OPCODE) ||
                            (opcode_segment == LOAD_TYPE_OPCODE) ||
                            (opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) ||
                            (opcode_segment == R_TYPE_OPCODE) ||
                            (opcode_segment == AUIPC_OPCODE) ||
                            (opcode_segment == J_TYPE_OPCODE) ||
                            (opcode_segment == JALR_OPCODE);

assign decoded_alu_src_reg_h_imm_low_o = ((opcode_segment == LUI_OPCODE) || 
                                          (opcode_segment == S_TYPE_OPCODE) ||
                                          (opcode_segment == LOAD_TYPE_OPCODE) ||
                                          (opcode_segment == BASIC_I_TYPE_WITHOUT_LOAD_OPCODE) ||
                                          (opcode_segment == AUIPC_OPCODE) ||
                                          (opcode_segment == JALR_OPCODE)) ? 1'd0 :
                                         ((opcode_segment == B_TYPE_OPCODE) ||
                                          (opcode_segment == R_TYPE_OPCODE)) ? 1'd1 : 1'd0;

assign decoded_rf_w_src_mem_h_alu_l_o = (opcode_segment == LOAD_TYPE_OPCODE);

assign decoded_is_branch_type_o = (opcode_segment == B_TYPE_OPCODE);

assign decoded_mem_wr_en_o = (opcode_segment == S_TYPE_OPCODE);
assign decoded_mem_rd_en_o = (opcode_segment == LOAD_TYPE_OPCODE);

endmodule