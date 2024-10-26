module mem_stage_bubblify_mux (
    input wire into_bubble_i,
    input wire rf_w_src_mem_h_alu_l_i,
    input wire rf_wr_en_i,
    output wire rf_w_src_mem_h_alu_l_o,
    output wire rf_wr_en_o
);

assign rf_w_src_mem_h_alu_l_o = into_bubble_i ? 1'd0 : rf_w_src_mem_h_alu_l_i;
assign rf_wr_en_o = into_bubble_i ? 1'd0 : rf_wr_en_i;

endmodule