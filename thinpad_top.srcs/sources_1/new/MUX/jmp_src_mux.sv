module jmp_src_mux #(
    parameter ADDR_WIDTH = 32
) (
    input wire [ADDR_WIDTH-1:0] direct_jmp_dest_i,
    input wire [ADDR_WIDTH-1:0] indirect_jmp_dest_i,
    input wire is_indirect_jmp_ctrl_i,
    output wire [ADDR_WIDTH-1:0] jmp_dest
);

assign jmp_dest = is_indirect_jmp_ctrl_i ? indirect_jmp_dest_i : direct_jmp_dest_i;

endmodule