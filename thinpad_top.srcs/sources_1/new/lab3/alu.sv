`default_nettype none

module alu(
    input  wire [15:0] alu_a,
    input  wire [15:0] alu_b,
    input  wire [ 3:0] alu_op,
    output wire [15:0] alu_y
);

wire signed [15:0] sra_val = $signed(alu_a) >>> alu_b[3:0];

assign alu_y = ({16{alu_op == 4'd1}}  & (alu_a + alu_b)) |
               ({16{alu_op == 4'd2}}  & (alu_a - alu_b)) |
               ({16{alu_op == 4'd3}}  & (alu_a & alu_b)) |
               ({16{alu_op == 4'd4}}  & (alu_a | alu_b)) |
               ({16{alu_op == 4'd5}}  & (alu_a ^ alu_b)) |
               ({16{alu_op == 4'd6}}  & (~alu_a)) |
               ({16{alu_op == 4'd7}}  & (alu_a << alu_b[3:0])) |
               ({16{alu_op == 4'd8}}  & (alu_a >> alu_b[3:0])) |
               ({16{alu_op == 4'd9}}  &  sra_val) |
               ({16{alu_op == 4'd10}} & ((alu_a << alu_b[3:0]) | (alu_a >> (16'd16 - alu_b[3:0]))));

endmodule