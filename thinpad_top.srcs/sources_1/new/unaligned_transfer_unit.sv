module unaligned_transfer_unit #(
    parameter ADDR_WIDTH = 32,
    parameter SELECT_WIDTH = 4,
    parameter DATA_WIDTH = 32
) (
    input wire [1:0] sel_cnt_i,  // 2'd1: byte; 2'd2: half word; 2'd0: word
    input wire mem_stage_request_use_i,
    input wire [ADDR_WIDTH-1:0] mem_addr_i,
    input wire [DATA_WIDTH-1:0] wr_data_i,
    input wire [DATA_WIDTH-1:0] rd_mem_data_i,

    output wire [SELECT_WIDTH-1:0] sel_o,
    output wire [DATA_WIDTH-1:0] wr_data_o,
    output wire [DATA_WIDTH-1:0] transferred_rd_mem_data_o
);

assign wr_data_o = mem_stage_request_use_i ?
                  (wr_data_i << ((mem_addr_i - ((mem_addr_i >> 'd2) << 'd2)) << 'd3)) :
                   'd0;

wire [SELECT_WIDTH-1:0] sel;

assign sel = (!mem_stage_request_use_i) ? 'd0 :
             (sel_cnt_i == 'd0) ? 4'b1111 :
             (sel_cnt_i == 'd1) ? 4'b0001 :
             (sel_cnt_i == 'd2) ? 4'b0011 : 'd0;

assign sel_o = sel << (mem_addr_i - ((mem_addr_i >> 'd2) << 'd2));

// byte: 3 2 1 0
wire sel_byte_3;               wire sel_byte_2;               wire sel_byte_1;               wire sel_byte_0;
assign sel_byte_3 = sel_o[3];  assign sel_byte_2 = sel_o[2];  assign sel_byte_1 = sel_o[1];  assign sel_byte_0 = sel_o[0];

wire [DATA_WIDTH-1:0] transferred_mem_data;
// filter out `xxx` signals first
assign transferred_mem_data = 
        {
            sel_byte_3 ? rd_mem_data_i[31:24] : 8'd0,
            sel_byte_2 ? rd_mem_data_i[23:16] : 8'd0,
            sel_byte_1 ? rd_mem_data_i[15: 8] : 8'b0,
            sel_byte_0 ? rd_mem_data_i[ 7: 0] : 8'b0
        };

assign transferred_rd_mem_data_o = mem_stage_request_use_i ?
            (transferred_mem_data >> ((mem_addr_i - ((mem_addr_i >> 'd2) << 'd2)) << 'd3))  // srl here
            : 'd0;

endmodule