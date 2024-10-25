module IF_to_ID_regs #(
    parameter ADDR_WIDTH = 32,  // `PC` is an address, so use `ADDR_WIDTH`
    parameter INSTR_WIDTH = 32,
    parameter [INSTR_WIDTH-1:0] NOP = 'h00000013
) (
    input wire sys_clk,
    input wire sys_rst,
    input wire wr_en,
    input wire [INSTR_WIDTH-1] instr_i,
    input wire [ADDR_WIDTH-1:0] pc_i,

    output logic [INSTR_WIDTH-1] instr,
    output logic [ADDR_WIDTH-1:0] pc
);

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
        instr <= NOP;
    end
    else if (wr_en) begin
        instr <= instr_i;
    end
end

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
        pc <= {ADDR_WIDTH{'b0}};
    end
    else if (wr_en) begin
        pc <= pc_i;
    end
end

endmodule