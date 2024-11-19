module pc_mux #(
    parameter ADDR_WIDTH = 32  // `PC` is an address, so use `ADDR_WIDTH`
) (
    input wire [ADDR_WIDTH-1:0] next_normal_pc_i,
    input wire [ADDR_WIDTH-1:0] branch_pc_i,
    input wire [ADDR_WIDTH-1:0] exception_dest_pc_i,  // from `mtvec`, `stvec` or otherwise
    input wire pc_is_from_exe_stage_branch_ctrl_i,
    input wire should_handle_exception_ctrl_i,
    output wire [ADDR_WIDTH-1:0] pc_chosen_o
);

assign pc_chosen_o = should_handle_exception_ctrl_i     ? exception_dest_pc_i :
                     pc_is_from_exe_stage_branch_ctrl_i ? branch_pc           : next_normal_pc;

endmodule