module simple_wb_arbiter_2 #(
    parameter DATA_WIDTH = 32,                    // width of data bus in bits (8, 16, 32, or 64)
    parameter ADDR_WIDTH = 32,                    // width of address bus in bits
    parameter SELECT_WIDTH = (DATA_WIDTH/8)       // width of word select bus (1, 2, 4, or 8)
) (
    /*
     * Wishbone master 0 input
     */
    input  wire [ADDR_WIDTH-1:0]   wbm0_adr_i,    // ADR_I() address input
    input  wire [DATA_WIDTH-1:0]   wbm0_dat_i,    // DAT_I() data in
    output wire [DATA_WIDTH-1:0]   wbm0_dat_o,    // DAT_O() data out
    input  wire                    wbm0_we_i,     // WE_I write enable input
    input  wire [SELECT_WIDTH-1:0] wbm0_sel_i,    // SEL_I() select input
    input  wire                    wbm0_stb_i,    // STB_I strobe input
    output wire                    wbm0_ack_o,    // ACK_O acknowledge output
    output wire                    wbm0_err_o,    // ERR_O error output
    output wire                    wbm0_rty_o,    // RTY_O retry output
    input  wire                    wbm0_cyc_i,    // CYC_I cycle input

    /*
     * Wishbone master 1 (high priority) input
     */
    input  wire [ADDR_WIDTH-1:0]   wbm1_adr_i,    // ADR_I() address input
    input  wire [DATA_WIDTH-1:0]   wbm1_dat_i,    // DAT_I() data in
    output wire [DATA_WIDTH-1:0]   wbm1_dat_o,    // DAT_O() data out
    input  wire                    wbm1_we_i,     // WE_I write enable input
    input  wire [SELECT_WIDTH-1:0] wbm1_sel_i,    // SEL_I() select input
    input  wire                    wbm1_stb_i,    // STB_I strobe input
    output wire                    wbm1_ack_o,    // ACK_O acknowledge output
    output wire                    wbm1_err_o,    // ERR_O error output
    output wire                    wbm1_rty_o,    // RTY_O retry output
    input  wire                    wbm1_cyc_i,    // CYC_I cycle input

    /*
     * Wishbone slave output
     */
    output wire [ADDR_WIDTH-1:0]   wbs_adr_o,     // ADR_O() address output
    input  wire [DATA_WIDTH-1:0]   wbs_dat_i,     // DAT_I() data in
    output wire [DATA_WIDTH-1:0]   wbs_dat_o,     // DAT_O() data out
    output wire                    wbs_we_o,      // WE_O write enable output
    output wire [SELECT_WIDTH-1:0] wbs_sel_o,     // SEL_O() select output
    output wire                    wbs_stb_o,     // STB_O strobe output
    input  wire                    wbs_ack_i,     // ACK_I acknowledge input
    input  wire                    wbs_err_i,     // ERR_I error input
    input  wire                    wbs_rty_i,     // RTY_I retry input
    output wire                    wbs_cyc_o      // CYC_O cycle output
);

wire select_wbm1;
assign select_wbm1 = wbm1_stb_i;

assign wbs_adr_o = select_wbm1 ? wbm1_adr_i : wbm0_adr_i;
assign wbs_dat_o = select_wbm1 ? wbm1_dat_i : wbm0_dat_i;
assign wbs_we_o = select_wbm1 ? wbm1_we_i : wbm0_we_i;
assign wbs_sel_o = select_wbm1 ? wbm1_sel_i : wbm0_sel_i;
assign wbs_stb_o = select_wbm1 ? wbm1_stb_i : wbm0_stb_i;
assign wbs_cyc_o = select_wbm1 ? wbm1_cyc_i : wbm0_cyc_i;

assign wbm0_dat_o = select_wbm1 ? 'd0 : wbs_dat_i;
assign wbm0_ack_o = select_wbm1 ? 'd0 : wbs_ack_i;
assign wbm0_err_o = select_wbm1 ? 'd0 : wbs_err_i;
assign wbm0_rty_o = select_wbm1 ? 'd0 : wbs_rty_i;

assign wbm1_dat_o = select_wbm1 ? wbs_dat_i : 'd0;
assign wbm1_ack_o = select_wbm1 ? wbs_ack_i : 'd0;
assign wbm1_err_o = select_wbm1 ? wbs_err_i : 'd0;
assign wbm1_rty_o = select_wbm1 ? wbs_rty_i : 'd0;

endmodule