module branch_taker (
    input wire is_branch_i,
    input wire should_branch_i,  // for `beq`, it's `xor_result_is_zero`
    output wire take_branch_o
);

assign take_branch_o = is_branch_i & should_branch_i;

endmodule