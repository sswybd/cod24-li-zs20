module id_forward_rf_rdata_mux #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] rf_rdata_i,
    input wire [DATA_WIDTH-1:0] wr_rf_data_i,
    input wire forward_ctrl_i,
    output wire [DATA_WIDTH-1:0] rf_rdata_o
);

assign rf_rdata_o = forward_ctrl_i ? wr_rf_data_i : rf_rdata_i;

endmodule