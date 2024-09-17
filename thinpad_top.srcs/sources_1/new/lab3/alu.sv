`default_nettype none

module alu(
    input  wire [15:0] alu_a,
    input  wire [15:0] alu_b,
    input  wire [ 3:0] alu_op,
    output wire [15:0] alu_y
);

assign alu_y = (alu_op == 4'd1)  ? (alu_a + alu_b) :
               (alu_op == 4'd2)  ? (alu_a - alu_b) :
               (alu_op == 4'd3)  ? (alu_a & alu_b) :
               (alu_op == 4'd4)  ? (alu_a | alu_b) :
               (alu_op == 4'd5)  ? (alu_a ^ alu_b) :
               (alu_op == 4'd6)  ? (~alu_a) :
               (alu_op == 4'd7)  ? (alu_a << alu_b) :
               (alu_op == 4'd8)  ? (alu_a >> alu_b) :
               (alu_op == 4'd9)  ? (alu_a >>> alu_b) :
               (alu_op == 4'd10) ? ((alu_a << alu_b) | (alu_a >> (16'd16 - alu_b))) : 16'd0;

endmodule


// wire [15:0] add_val = alu_a + alu_b;
// wire [15:0] sub_val = alu_a - alu_b;
// wire [15:0] and_val = alu_a & alu_b;
// wire [15:0] or_val = alu_a | alu_b;
// wire [15:0] xor_val = alu_a ^ alu_b;
// wire [15:0] not_val = ~alu_a;
// wire [15:0] sll_val = alu_a << alu_b;
// wire [15:0] srl_val = alu_a >> alu_b;
// wire [15:0] sra_val = alu_a >>> alu_b;
// wire [15:0] rol_val = alu_a rol alu_b;
// wire [15:0] rol_val;
// assign rol_val = (alu_a << alu_b) | (alu_a >> (16'd16 - alu_b));
// wire [19:0] op_code_one_hot;