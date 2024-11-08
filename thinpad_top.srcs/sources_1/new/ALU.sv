module ALU #(
    parameter DATA_WIDTH = 32,
    parameter ALU_OP_ENCODING_WIDTH = 5,
    localparam SHIFT_RANGE = $clog2(DATA_WIDTH)
) (
    input  wire [DATA_WIDTH-1:0] operand_a,
    input  wire [DATA_WIDTH-1:0] operand_b,
    input  wire [ALU_OP_ENCODING_WIDTH-1:0] alu_op,
    output wire [DATA_WIDTH-1:0] alu_result
);

wire signed [DATA_WIDTH-1:0] sra_val = $signed(operand_a) >>> operand_b[SHIFT_RANGE-1:0];

integer i;
logic [DATA_WIDTH-1:0] ctz_result;
logic [DATA_WIDTH-1:0] ctz_temp_rs1;

always_comb begin : calc_ctz
    ctz_result = 'd0;
    ctz_temp_rs1 = operand_a;
    if (alu_op == 'd13) begin
        ctz_temp_rs1 = (ctz_temp_rs1 - 'd1) & (~ctz_temp_rs1);  // https://github.com/riscv/riscv-bitmanip/blob/main-history/verilog/rvb_bitcnt/rvb_bitcnt.v
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            ctz_result = ctz_result + ctz_temp_rs1[i];
        end
    end
    else begin
        ctz_result = 'd0;
    end
end

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
               ({DATA_WIDTH{alu_op == 'd10}} & ((operand_a ^ operand_b) == {DATA_WIDTH{1'b0}})) |
               ({DATA_WIDTH{alu_op == 'd13}} &  ctz_result) |  // ctz
               ({DATA_WIDTH{alu_op == 'd14}} & (operand_a ~^ operand_b)) |
               ({DATA_WIDTH{alu_op == 'd15}} & 
                (operand_a & 
                    (~('d1 << (operand_b & {(DATA_WIDTH-SHIFT_RANGE){1'b0}, SHIFT_RANGE{1'b1}}))))
               )  // sbclr
                
                ;

endmodule

// can also write the `alu_op == 'd10` line like this:
// `({DATA_WIDTH{alu_op == 'd10}} & {DATA_WIDTH{~(|(operand_a ^ operand_b))}})`
// but we must add the latter `DATA_WIDTH` concatenation part
// if we used `(~(|(operand_a ^ operand_b)))` directly, the result would be incorrect (unwanted behaviour, compiler's magic), too