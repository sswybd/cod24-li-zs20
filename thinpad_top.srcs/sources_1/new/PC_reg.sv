module PC_reg #(
    parameter START_PC = 32'h8000_0000,
    parameter ADDR_WIDTH = 32  // `PC` is an address, so use `ADDR_WIDTH`
) (
    input wire sys_clk,
    input wire sys_rst,
    input wire wr_en,
    input wire [ADDR_WIDTH-1:0] input_pc,
    input wire pc_is_from_branch,
    output logic [ADDR_WIDTH-1:0] output_pc
);

logic [ADDR_WIDTH-1:0] correct_tmp_pc_reg;
logic should_hold_correct_tmp_pc_reg;

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
        should_hold_correct_tmp_pc_reg <= 1'd0;
    end
    else begin
        if (pc_is_from_branch && (!wr_en)) begin
            should_hold_correct_tmp_pc_reg <= 1'd1;
        end
        else if (wr_en) begin
            should_hold_correct_tmp_pc_reg <= 1'd0;
        end
    end
end

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
        output_pc <= START_PC;
        correct_tmp_pc_reg <= START_PC;
    end
    else begin
        if (!should_hold_correct_tmp_pc_reg) begin
            correct_tmp_pc_reg <= input_pc;
        end
        if (wr_en) begin
            if (pc_is_from_branch) begin
                output_pc <= input_pc;
            end
            else begin
                output_pc <= correct_tmp_pc_reg;
            end
        end
    end
end

endmodule