module memory_controller_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SELECT_WIDTH = (DATA_WIDTH / 8)
) (
    input wire sys_clk,
    input wire sys_rst,
    input wire [ADDR_WIDTH-1:0] addr_i,
    input wire bus_is_busy,
    input wire [DATA_WIDTH-1:0] wr_data_i,
    input wire [DATA_WIDTH-1:0] bus_data_i,
    input wire [SELECT_WIDTH-1:0] sel_i,
    input wire ack_i,  // OR the two masters' ack
    input wire rd_en,
    input wire wr_en,
    output logic stb_o,
    output wire [DATA_WIDTH-1:0] rd_data_o,
    output wire [DATA_WIDTH-1:0] bus_data_o,
    output wire [ADDR_WIDTH-1:0] addr_o,
    output wire [SELECT_WIDTH-1:0] wb_sel_o,
    output wire we_o
);

wire want_to_use;
assign want_to_use = rd_en | wr_en;

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
        stb_o <= 1'd0;
    end
    else begin
        if (want_to_use && !bus_is_busy) begin
            stb_o <= 1'd1;
        end
        else if (ack_i) begin
            stb_o <= 1'd0;
        end
    end
end

assign rd_data_o = bus_data_i;
assign bus_data_o = wr_data_i;
assign addr_o = addr_i;
assign wb_sel_o = sel_i;
assign we_o = wr_en;

endmodule