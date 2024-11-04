module ALU #(
    parameter DATA_WIDTH = 32,
    parameter ALU_OP_ENCODING_WIDTH = 4,
    localparam SHIFT_RANGE = $clog2(DATA_WIDTH)
) (
    input  wire [DATA_WIDTH-1:0] operand_a,
    input  wire [DATA_WIDTH-1:0] operand_b,
    input  wire [ALU_OP_ENCODING_WIDTH-1:0] alu_op,
    output wire [DATA_WIDTH-1:0] alu_result
);

wire signed [DATA_WIDTH-1:0] sra_val = $signed(operand_a) >>> operand_b[SHIFT_RANGE-1:0];

assign alu_result = 
               ({DATA_WIDTH{alu_op == 'd1}}  & (operand_a + operand_b)) |
               ({DATA_WIDTH{alu_op == 'd2}}  & (operand_a - operand_b)) |
               ({DATA_WIDTH{alu_op == 'd3}}  & (operand_a & operand_b)) |
               ({DATA_WIDTH{alu_op == 'd4}}  & (operand_a | operand_b)) |
               ({DATA_WIDTH{alu_op == 'd5}}  & (operand_a ^ operand_b)) |
               ({DATA_WIDTH{alu_op == 'd6}}  & (~operand_a)) |
               ({DATA_WIDTH{alu_op == 'd7}}  & (operand_a << operand_b[SHIFT_RANGE-1:0])) |
               ({DATA_WIDTH{alu_op == 'd8}}  & (operand_a >> operand_b[SHIFT_RANGE-1:0])) |
               ({DATA_WIDTH{alu_op == 'd9}}  &  sra_val) |
               ({DATA_WIDTH{alu_op == 'd11}} &  operand_a) |  // output `operand_a`
               ({DATA_WIDTH{alu_op == 'd12}} &  operand_b) |  // output `operand_b`
               ({DATA_WIDTH{alu_op == 'd10}} & ((operand_a ^ operand_b) == {DATA_WIDTH{1'b0}}));

endmodule