module ALU #(
    parameter DATA_WIDTH = 32,
    localparam SHIFT_RANGE = $clog2(DATA_WIDTH)
) (
    input  wire [DATA_WIDTH-1:0] operand_a,
    input  wire [DATA_WIDTH-1:0] operand_b,
    input  wire [3:0] alu_op,
    output wire [DATA_WIDTH-1:0] alu_result
);

wire signed [DATA_WIDTH-1:0] sra_val = $signed(operand_a) >>> operand_b[SHIFT_RANGE-1:0];

assign alu_result = ({(DATA_WIDTH-1){alu_op == 4'd1}}  & (operand_a + operand_b)) |
               ({(DATA_WIDTH-1){alu_op == 4'd2}}  & (operand_a - operand_b)) |
               ({(DATA_WIDTH-1){alu_op == 4'd3}}  & (operand_a & operand_b)) |
               ({(DATA_WIDTH-1){alu_op == 4'd4}}  & (operand_a | operand_b)) |
               ({(DATA_WIDTH-1){alu_op == 4'd5}}  & (operand_a ^ operand_b)) |
               ({(DATA_WIDTH-1){alu_op == 4'd6}}  & (~operand_a)) |
               ({(DATA_WIDTH-1){alu_op == 4'd7}}  & (operand_a << operand_b[SHIFT_RANGE-1:0])) |
               ({(DATA_WIDTH-1){alu_op == 4'd8}}  & (operand_a >> operand_b[SHIFT_RANGE-1:0])) |
               ({(DATA_WIDTH-1){alu_op == 4'd9}}  &  sra_val) |
               ({(DATA_WIDTH-1){alu_op == 4'd10}} & 
                ((operand_a << operand_b[SHIFT_RANGE-1:0]) | 
                     (operand_a >> ('d32 - operand_b[SHIFT_RANGE-1:0]))
                )
               );

endmodule