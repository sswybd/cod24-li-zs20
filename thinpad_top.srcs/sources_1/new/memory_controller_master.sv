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
    input wire [SELECT_WIDTH-1:0] wb_sel_i,
    input wire ack_i,
    input wire rd_en,
    input wire wr_en,
    output wire ack_o,
    output logic stb_o,
    output wire [DATA_WIDTH-1:0] rd_data_o,
    output wire [DATA_WIDTH-1:0] bus_data_o,
    output wire [ADDR_WIDTH-1:0] addr_o,
    output wire [SELECT_WIDTH-1:0] wb_sel_o,
    output wire we_o
);


endmodule