module exe_forward_operand_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] exe_stage_rf_rdata,
    input wire [DATA_WIDTH-1:0] wb_stage_wr_rf_data,
    input wire [DATA_WIDTH-1:0] exe_to_mem_alu_result,
    input wire [1:0] forward,
    output wire [DATA_WIDTH-1:0] operand
);

assign operand = ({DATA_WIDTH{forward == 2'b00}} & exe_stage_rf_rdata) |
                   ({DATA_WIDTH{forward == 2'b01}} & wb_stage_wr_rf_data) |
                   ({DATA_WIDTH{forward == 2'b10}} & exe_to_mem_alu_result);

endmodule