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
assign rf_rdata_b = (rf_raddr_b > 5'd0) ? regs[rf_raddr_a - 5'd1] : 16'd0;

endmodule

// logic [15:0] x1;
// logic [15:0] x2;
// logic [15:0] x3;
// logic [15:0] x4;
// logic [15:0] x5;
// logic [15:0] x6;
// logic [15:0] x7;
// logic [15:0] x8;
// logic [15:0] x9;
// logic [15:0] x10;
// logic [15:0] x11;
// logic [15:0] x12;
// logic [15:0] x13;
// logic [15:0] x14;
// logic [15:0] x15;
// logic [15:0] x16;
// logic [15:0] x17;
// logic [15:0] x18;
// logic [15:0] x19;
// logic [15:0] x20;
// logic [15:0] x21;
// logic [15:0] x22;
// logic [15:0] x23;
// logic [15:0] x24;
// logic [15:0] x25;
// logic [15:0] x26;
// logic [15:0] x27;
// logic [15:0] x28;
// logic [15:0] x29;
// logic [15:0] x30;
// logic [15:0] x31;