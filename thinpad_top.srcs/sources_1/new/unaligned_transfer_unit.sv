module unaligned_transfer_unit #(
    parameter ADDR_WIDTH = 32,
    parameter SELECT_WIDTH = 4,
    parameter DATA_WIDTH = 32
) (
    input wire [1:0] sel_cnt_i,  // 2'd1: byte; 2'd2: half word; 2'd0: word
    input wire mem_stage_request_use_i,
    input wire [ADDR_WIDTH-1:0] mem_addr_i,
    input wire [DATA_WIDTH-1:0] wr_data_i,
    output wire [SELECT_WIDTH-1:0] sel_o,
    output wire [DATA_WIDTH-1:0] wr_data_o
);

assign wr_data_o = mem_stage_request_use_i ? (wr_data_i << ((mem_addr_i - ((mem_addr_i >> 'd2) << 'd2)) << 'd3))
                    : 'd0;

wire [SELECT_WIDTH-1:0] sel;

assign sel = (!mem_stage_request_use_i) ? 'd0 :
             (sel_cnt_i == 'd0) ? 4'b1111 :
             (sel_cnt_i == 'd1) ? 4'b0001 :
             (sel_cnt_i == 'd2) ? 4'b0011 : 'd0;

assign sel_o = sel << (mem_addr_i - ((mem_addr_i >> 'd2) << 'd2));

endmodule