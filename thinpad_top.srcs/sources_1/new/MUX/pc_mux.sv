module pc_mux #(
    parameter ADDR_WIDTH = 32  // `PC` is an address, so use `ADDR_WIDTH`
) (
    input wire [ADDR_WIDTH-1:0] next_normal_pc,
    input wire [ADDR_WIDTH-1:0] branch_pc,
    input wire pc_is_from_branch,
    output wire [ADDR_WIDTH-1:0] pc_chosen
);

assign pc_chosen = pc_is_from_branch ? branch_pc : next_normal_pc;

endmodule