module id_forward_rf_rdata_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] rf_rdata_i,
    input wire [DATA_WIDTH-1:0] wr_rf_data_i,
    input wire [DATA_WIDTH-1:0] csr_wb_data_i,
    input wire [1:0] forward_ctrl_i,
    output wire [DATA_WIDTH-1:0] rf_rdata_o
);

assign rf_rdata_o = ({DATA_WIDTH{forward_ctrl_i == 2'b00}} & rf_rdata_i   ) |
                    ({DATA_WIDTH{forward_ctrl_i == 2'b01}} & wr_rf_data_i ) |
                    ({DATA_WIDTH{forward_ctrl_i == 2'b10}} & csr_wb_data_i);

endmodule