module hazard_detection_unit (
    input wire sys_clk,
    input wire sys_rst,
    input wire should_take_any_branch_i,  // previous (waveform graph's) `exe_stage_should_branch`
    input wire mem_stage_ack,
    input wire if_stage_ack,
    input wire if_stage_using_bus,
    input wire mem_stage_using_bus,
    input wire mem_stage_request_use,
    output logic if_stage_is_invalid,  // is invalid because of all kinds of branches
    output wire if_stage_into_bubble,
    output wire bus_is_busy,
    output wire mem_stage_into_bubble,
    output wire exe_to_mem_wr_en,
    output wire id_to_exe_wr_en,
    output wire id_stage_into_bubble,
    output wire if_to_id_wr_en,
    output wire pc_wr_en
);

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
        if_stage_is_invalid <= 1'b0;
    end
    else begin
        if (!mem_stage_using_bus && if_stage_using_bus) begin
            if (!pc_wr_en && should_take_any_branch_i) begin
                if_stage_is_invalid <= 1'b1;
            end
            else if (pc_wr_en) begin
                if_stage_is_invalid <= 1'b0;
            end
        end
    end
end

assign if_stage_into_bubble = (~if_stage_ack) | (should_take_any_branch_i & if_stage_ack);
assign bus_is_busy = if_stage_using_bus | mem_stage_using_bus;
assign mem_stage_into_bubble = mem_stage_request_use & (~mem_stage_ack);
assign exe_to_mem_wr_en = ~mem_stage_into_bubble;
assign id_to_exe_wr_en = ~mem_stage_into_bubble;
assign id_stage_into_bubble = 1'd0;
assign if_to_id_wr_en = if_stage_ack | (~mem_stage_into_bubble);
assign pc_wr_en = if_stage_ack | 
                (should_take_any_branch_i & 
                        ((~if_stage_using_bus) | (if_stage_using_bus & mem_stage_using_bus))
                );

endmodule