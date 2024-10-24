`default_nettype none

module register_file(
    input  wire          clk,
    input  wire          reset,
    
    input  wire  [ 4:0]  rf_raddr_a,
    output logic [15:0]  rf_rdata_a,
    input  wire  [ 4:0]  rf_raddr_b,
    output logic [15:0]  rf_rdata_b,
    input  wire  [ 4:0]  rf_waddr,
    input  wire  [15:0]  rf_wdata,
    input  wire          rf_we
);

logic [15:0] regs [30:0];

integer i;

always_ff @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 31; i++) begin
            regs[i] <= 16'd0;
        end
    end
    else if (rf_we && (rf_waddr > 5'd0)) begin
        regs[rf_waddr - 5'd1] <= rf_wdata;
    end
end

assign rf_rdata_a = (rf_raddr_a > 5'd0) ? regs[rf_raddr_a - 5'd1] : 16'd0;
assign rf_rdata_b = (rf_raddr_b > 5'd0) ? regs[rf_raddr_b - 5'd1] : 16'd0;

endmodule