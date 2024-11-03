module branch_taker #(
    parameter DATA_WIDTH = 32
) (
    input wire is_branch_i,
    input wire [DATA_WIDTH-1:0] alu_branch_result_i,  // for `beq`, it's `xor_result_is_zero`
    input wire is_uncond_jmp_i,
    output wire take_branch_o
);

assign take_branch_o = (is_branch_i && (alu_branch_result_i == {DATA_WIDTH{1'b0}})) || is_uncond_jmp_i;

endmodule