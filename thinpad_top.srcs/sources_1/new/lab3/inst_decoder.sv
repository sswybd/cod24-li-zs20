`default_nettype none

/*
 * decode instruction info; need valid `inst_reg` value   
 */
module inst_decoder(
    input  wire [31:0] inst_reg,
    output wire        is_rtype,
    output wire        is_itype,
    output wire        is_peek,
    output wire        is_poke,
    output wire [15:0] imm,
    output wire [ 4:0] rd,
    output wire [ 4:0] rs1,
    output wire [ 4:0] rs2,
    output wire [ 3:0] opcode
);

assign is_rtype = (inst_reg[2:0] == 3'b001);
assign is_itype = (inst_reg[2:0] == 3'b010);
assign is_peek  = is_itype && (inst_reg[6:3] == 4'b0010);
assign is_poke  = is_itype && (inst_reg[6:3] == 4'b0001);
assign imm      = inst_reg[31:16];
assign rd       = inst_reg[11:7];
assign rs1      = inst_reg[19:15];
assign rs2      = inst_reg[24:20];
assign opcode   = inst_reg[6:3];

endmodule