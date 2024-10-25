module nop_instr_mux #(
    parameter INSTR_WIDTH = 32,
    localparam [INSTR_WIDTH-1:0] NOP = 'h00000013;
) (
    input wire if_stage_into_bubble,
    input wire if_stage_invalid,
    input wire [INSTR_WIDTH-1:0] fetched_instr,
    output wire [INSTR_WIDTH-1:0] if_stage_instr_o
);

assign if_stage_instr_o = (if_stage_into_bubble || if_stage_invalid) ? NOP : fetched_instr;

endmodule