module wb_source_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] rd_mem_data_i,
    input wire [DATA_WIDTH-1:0] alu_result_i,
    input wire wb_source_mem_h_alu_l_ctrl_i,
    output wire [DATA_WIDTH-1:0] wb_data_o
);

assign wb_data_o = wb_source_mem_h_alu_l_ctrl_i ? rd_mem_data_i : alu_result_i;

endmodule