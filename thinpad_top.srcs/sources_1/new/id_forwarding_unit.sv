module id_forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
) (
    input wire wb_en,
    input wire [REG_ADDR_WIDTH-1:0] wb_addr,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_a,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_b,
    input wire csr_wb_en_i,
    input wire [REG_ADDR_WIDTH-1:0] csr_wb_addr_i,
    output wire [1:0] forward_a_o,  // 00: raw_rf_rdata, 01: wb stage, 10: csr, 11: output all zeros
    output wire [1:0] forward_b_o  // same as `forward_a_o`
);

assign forward_a_o = (csr_wb_en_i && (rf_raddr_a == csr_wb_addr_i) && (csr_wb_addr_i != 'd0)) ? 2'b10 :
                     (wb_en && (wb_addr == rf_raddr_a) && (wb_addr != 'd0)) ? 2'b01 :
                      2'b00;

assign forward_b_o = (csr_wb_en_i && (rf_raddr_b == csr_wb_addr_i) && (csr_wb_addr_i != 'd0)) ? 2'b10 :
                     (wb_en && (wb_addr == rf_raddr_b) && (wb_addr != 'd0)) ? 2'b01 :
                      2'b00;

endmodule