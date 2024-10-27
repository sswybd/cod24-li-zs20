module unaligned_rd_transfer_unit #(
    parameter SELECT_WIDTH = 4,
    parameter DATA_WIDTH = 32
) (
    input wire [SELECT_WIDTH-1:0] sel_i,
    input wire [DATA_WIDTH-1:0] rd_mem_data_i,
    
    output wire [DATA_WIDTH-1:0] transfered_mem_data_o
);

// byte: 3 2 1 0
wire sel_byte_3;
wire sel_byte_2;
wire sel_byte_1;
wire sel_byte_0;

assign sel_byte_3 = sel_i[3];
assign sel_byte_2 = sel_i[2];
assign sel_byte_1 = sel_i[1];
assign sel_byte_0 = sel_i[0];

assign transfered_mem_data_o = 
        {
            sel_byte_3 ? rd_mem_data_i[31:24] : 8'd0,
            sel_byte_2 ? rd_mem_data_i[23:16] : 8'd0,
            sel_byte_1 ? rd_mem_data_i[15: 8] : 8'b0,
            sel_byte_0 ? rd_mem_data_i[ 7: 0] : 8'b0
        };

endmodule