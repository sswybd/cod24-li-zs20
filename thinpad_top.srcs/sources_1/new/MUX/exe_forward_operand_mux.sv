module exe_forward_operand_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] exe_stage_rf_rdata_i,
    input wire [DATA_WIDTH-1:0] wb_stage_wr_rf_data_i,
    input wire [DATA_WIDTH-1:0] exe_to_mem_alu_result_i,
    input wire [DATA_WIDTH-1:0] csr_wb_data_i,
    input wire [1:0] forward_ctrl_i,
    output wire [DATA_WIDTH-1:0] operand_o
);

assign operand_o = ({DATA_WIDTH{forward_ctrl_i == 2'b00}} & exe_stage_rf_rdata_i   ) |
                   ({DATA_WIDTH{forward_ctrl_i == 2'b01}} & wb_stage_wr_rf_data_i  ) |
                   ({DATA_WIDTH{forward_ctrl_i == 2'b10}} & exe_to_mem_alu_result_i) |
                   ({DATA_WIDTH{forward_ctrl_i == 2'b11}} & csr_wb_data_i          );

endmodule