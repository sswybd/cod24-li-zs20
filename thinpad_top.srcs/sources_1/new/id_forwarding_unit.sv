module id_forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
) (
    input wire wb_en,
    input wire [REG_ADDR_WIDTH-1:0] wb_addr,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_a,
    input wire [REG_ADDR_WIDTH-1:0] rf_raddr_b,
    output wire operand_a_should_forward,
    output wire operand_b_should_forward
);

assign operand_a_should_forward = (wb_en && (wb_addr == rf_raddr_a) && (wb_addr != 'd0)) ? 1'd1 : 1'd0;

assign operand_b_should_forward = (wb_en && (wb_addr == rf_raddr_b) && (wb_addr != 'd0)) ? 1'd1 : 1'd0;

endmodule