`default_nettype none

module register_file #(
    parameter DATA_WIDTH = 16,
    parameter REG_ADDR_WIDTH = 5
) (
    input  wire          clk,
    input  wire          reset,
    
    input  wire  [REG_ADDR_WIDTH-1:0]  rf_raddr_a,
    output logic [DATA_WIDTH-1:0]  rf_rdata_a,
    input  wire  [REG_ADDR_WIDTH-1:0]  rf_raddr_b,
    output logic [DATA_WIDTH-1:0]  rf_rdata_b,
    input  wire  [REG_ADDR_WIDTH-1:0]  rf_waddr,
    input  wire  [DATA_WIDTH-1:0]  rf_wdata,
    input  wire          rf_we
);

logic [DATA_WIDTH-1:0] regs [30:0];

integer i;

always_ff @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 31; i++) begin
            regs[i] <= 'd0;
        end
    end
    else if (rf_we && (rf_waddr > 'd0)) begin
        regs[rf_waddr - 'd1] <= rf_wdata;
    end
end

assign rf_rdata_a = (rf_raddr_a > 'd0) ? regs[rf_raddr_a - 'd1] : 'd0;
assign rf_rdata_b = (rf_raddr_b > 'd0) ? regs[rf_raddr_b - 'd1] : 'd0;

endmodule