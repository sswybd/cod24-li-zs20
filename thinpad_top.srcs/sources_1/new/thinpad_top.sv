`default_nettype none

module thinpad_top (
    input wire clk_50M,     // 50MHz 时钟输入
    input wire clk_11M0592, // 11.0592MHz 时钟输入（备用，可不用）

    input wire push_btn,  // BTN5 按钮开关，带消抖电路，按下时为 1
    input wire reset_btn, // BTN6 复位按钮，带消抖电路，按下时为 1

    input  wire [ 3:0] touch_btn,  // BTN1~BTN4，按钮开关，按下时为 1
    input  wire [31:0] dip_sw,     // 32 位拨码开关，拨到“ON”时为 1
    output wire [15:0] leds,       // 16 位 LED，输出时 1 点亮
    output wire [ 7:0] dpy0,       // 数码管低位信号，包括小数点，输出 1 点亮
    output wire [ 7:0] dpy1,       // 数码管高位信号，包括小数点，输出 1 点亮

    // CPLD 串口控制器信号
    output wire uart_rdn,        // 读串口信号，低有效
    output wire uart_wrn,        // 写串口信号，低有效
    input  wire uart_dataready,  // 串口数据准备好
    input  wire uart_tbre,       // 发送数据标志
    input  wire uart_tsre,       // 数据发送完毕标志

    // BaseRAM 信号
    inout wire [31:0] base_ram_data,  // BaseRAM 数据，低 8 位与 CPLD 串口控制器共享
    output wire [19:0] base_ram_addr,  // BaseRAM 地址
    output wire [3:0] base_ram_be_n,  // BaseRAM 字节使能，低有效。如果不使用字节使能，请保持为 0
    output wire base_ram_ce_n,  // BaseRAM 片选，低有效
    output wire base_ram_oe_n,  // BaseRAM 读使能，低有效
    output wire base_ram_we_n,  // BaseRAM 写使能，低有效

    // ExtRAM 信号
    inout wire [31:0] ext_ram_data,  // ExtRAM 数据
    output wire [19:0] ext_ram_addr,  // ExtRAM 地址
    output wire [3:0] ext_ram_be_n,  // ExtRAM 字节使能，低有效。如果不使用字节使能，请保持为 0
    output wire ext_ram_ce_n,  // ExtRAM 片选，低有效
    output wire ext_ram_oe_n,  // ExtRAM 读使能，低有效
    output wire ext_ram_we_n,  // ExtRAM 写使能，低有效

    // 直连串口信号
    output wire txd,  // 直连串口发送端
    input  wire rxd,  // 直连串口接收端

    // Flash 存储器信号，参考 JS28F640 芯片手册
    output wire [22:0] flash_a,  // Flash 地址，a0 仅在 8bit 模式有效，16bit 模式无意义
    inout wire [15:0] flash_d,  // Flash 数据
    output wire flash_rp_n,  // Flash 复位信号，低有效
    output wire flash_vpen,  // Flash 写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,  // Flash 片选信号，低有效
    output wire flash_oe_n,  // Flash 读使能信号，低有效
    output wire flash_we_n,  // Flash 写使能信号，低有效
    output wire flash_byte_n, // Flash 8bit 模式选择，低有效。在使用 flash 的 16 位模式时请设为 1

    // USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    // inout  wire [7:0] sl811_d,     // USB 数据线与网络控制器的 dm9k_sd[7:0] 共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    // 网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout wire [15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input wire dm9k_int,

    // 图像输出信号
    output wire [2:0] video_red,    // 红色像素，3 位
    output wire [2:0] video_green,  // 绿色像素，3 位
    output wire [1:0] video_blue,   // 蓝色像素，2 位
    output wire       video_hsync,  // 行同步（水平同步）信号
    output wire       video_vsync,  // 场同步（垂直同步）信号
    output wire       video_clk,    // 像素时钟输出
    output wire       video_de      // 行数据有效信号，用于区分消隐区
);

wire locked, clk_10M, clk_20M;
pll_example clock_gen (
    // Clock in ports
    .clk_in1(clk_50M),  // 外部时钟输入
    // Clock out ports
    .clk_out1(clk_10M),  // 时钟输出 1，频率在 IP 配置界面中设置
    .clk_out2(clk_20M),  // 时钟输出 2，频率在 IP 配置界面中设置
    // Status and control signals
    .reset(reset_btn),  // PLL 复位输入
    .locked(locked)  // PLL 锁定指示输出，"1"表示时钟稳定，
                    // 后级电路复位信号应当由它生成（见下）
);

logic reset_of_clk10M;
// 异步复位，同步释放，将 locked 信号转为后级电路的复位 reset_of_clk10M
always_ff @(posedge clk_10M or negedge locked) begin
    if (~locked) reset_of_clk10M <= 1'b1;
    else reset_of_clk10M <= 1'b0;
end

wire sys_clk;
wire sys_rst;

assign sys_clk = clk_10M;
assign sys_rst = reset_of_clk10M;

// 本实验不使用 CPLD 串口，禁用防止总线冲突
assign uart_rdn = 1'd1;
assign uart_wrn = 1'd1;

parameter START_PC = 32'h8000_0000;
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter INSTR_WIDTH = 32;
parameter SELECT_WIDTH = (DATA_WIDTH / 8);
parameter REG_ADDR_WIDTH = 5;
parameter ALU_OP_ENCODING_WIDTH = 4;
parameter [INSTR_WIDTH-1:0] NOP = 'h00000013;

wire data_mem_and_peripheral_ack;
wire instruction_mem_ack;
wire bus_is_busy;
wire [ADDR_WIDTH-1:0] if_stage_pc;
wire [INSTR_WIDTH-1:0] fetched_instr;

wire [DATA_WIDTH-1:0] mem_stage_non_imm_operand_b;
wire [DATA_WIDTH-1:0] mem_stage_alu_result;
wire mem_stage_mem_rd_en;
wire mem_stage_mem_wr_en;
wire [SELECT_WIDTH-1:0] mem_stage_sel;
wire [DATA_WIDTH-1:0] mem_stage_wr_data;
wire [DATA_WIDTH-1:0] raw_rd_mem_data;

/* =========== Wishbone code begin =========== */

// master0/1 <-> arbiter
wire wbm0_stb_o;
wire wbm1_stb_o;
wire wbm0_ack_i;
wire wbm1_ack_i;
wire [ADDR_WIDTH-1:0] wbm0_addr_o;
wire [ADDR_WIDTH-1:0] wbm1_addr_o;
wire [DATA_WIDTH-1:0] wbm0_dat_o;
wire [DATA_WIDTH-1:0] wbm1_dat_o;
wire [DATA_WIDTH-1:0] wbm0_dat_i;
wire [DATA_WIDTH-1:0] wbm1_dat_i;
wire [SELECT_WIDTH-1:0] wbm0_sel_o;
wire [SELECT_WIDTH-1:0] wbm1_sel_o;
wire wbm0_we_o;
wire wbm1_we_o;

// arbiter <-> MUX
wire wbs_stb_i;
wire wbs_cyc_i;
wire wbs_ack_o;
wire [ADDR_WIDTH-1:0] wbs_addr_i;
wire [DATA_WIDTH-1:0] wbs_dat_o;
wire [DATA_WIDTH-1:0] wbs_dat_i;
wire [SELECT_WIDTH-1:0] wbs_sel_i;
wire wbs_we_i;

// MUX <-> slave0
wire [ADDR_WIDTH-1:0] wbs0_adr_i;
wire [DATA_WIDTH-1:0] wbs0_dat_o;
wire [DATA_WIDTH-1:0] wbs0_dat_i;
wire wbs0_we_i;
wire [SELECT_WIDTH-1:0] wbs0_sel_i;
wire wbs0_stb_i;
wire wbs0_ack_o;
wire wbs0_cyc_i;

// MUX <-> slave1
wire [ADDR_WIDTH-1:0] wbs1_adr_i;
wire [DATA_WIDTH-1:0] wbs1_dat_o;
wire [DATA_WIDTH-1:0] wbs1_dat_i;
wire wbs1_we_i;
wire [SELECT_WIDTH-1:0] wbs1_sel_i;
wire wbs1_stb_i;
wire wbs1_ack_o;
wire wbs1_cyc_i;

// MUX <-> slave2
wire [ADDR_WIDTH-1:0] wbs2_adr_i;
wire [DATA_WIDTH-1:0] wbs2_dat_o;
wire [DATA_WIDTH-1:0] wbs2_dat_i;
wire wbs2_we_i;
wire [SELECT_WIDTH-1:0] wbs2_sel_i;
wire wbs2_stb_i;
wire wbs2_ack_o;
wire wbs2_cyc_i;


// master0 => arbiter
memory_controller_master #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .SELECT_WIDTH(SELECT_WIDTH)
) instruction_memory_controller_master_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .addr_i(if_stage_pc),
    .bus_is_busy(bus_is_busy),
    .wr_data_i({DATA_WIDTH{1'b0}}),
    .bus_data_i(wbm0_dat_i),
    .sel_i(4'b1111),
    .ack_i(wbm0_ack_i),
    .rd_en(1'd1),
    .wr_en(1'd0),
    .ack_o(instruction_mem_ack),
    .stb_o(wbm0_stb_o),
    .rd_data_o(fetched_instr),
    .bus_data_o(wbm0_dat_o),
    .addr_o(wbm0_addr_o),
    .wb_sel_o(wbm0_sel_o),
    .we_o(wbm0_we_o)
);

// master1 (high priority) => arbiter
memory_controller_master #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .SELECT_WIDTH(SELECT_WIDTH)
) data_memory_and_peripheral_controller_master_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .addr_i(mem_stage_alu_result),
    .bus_is_busy(bus_is_busy),
    .wr_data_i(mem_stage_wr_data),
    .bus_data_i(wbm1_dat_i),
    .sel_i(mem_stage_sel),
    .ack_i(wbm1_ack_i),
    .rd_en(mem_stage_mem_rd_en),
    .wr_en(mem_stage_mem_wr_en),
    .ack_o(data_mem_and_peripheral_ack),
    .stb_o(wbm1_stb_o),
    .rd_data_o(raw_rd_mem_data),
    .bus_data_o(wbm1_dat_o),
    .addr_o(wbm1_addr_o),
    .wb_sel_o(wbm1_sel_o),
    .we_o(wbm1_we_o)
);

// arbiter => MUX
wb_arbiter_2 #(
    .ARB_LSB_HIGH_PRIORITY(0)
) arbiter_inst (
    .clk(sys_clk),
    .rst(sys_rst),

    /*
     * Wishbone master 0 input
     */
    .wbm0_adr_i(wbm0_addr_o),
    .wbm0_dat_i(wbm0_dat_o),
    .wbm0_dat_o(wbm0_dat_i),
    .wbm0_we_i(wbm0_we_o),
    .wbm0_sel_i(wbm0_sel_o),
    .wbm0_stb_i(wbm0_stb_o),
    .wbm0_ack_o(wbm0_ack_i),
    .wbm0_err_o(),
    .wbm0_rty_o(),
    .wbm0_cyc_i(wbm0_stb_o),

    /*
     * Wishbone master 1 input
     */
    .wbm1_adr_i(wbm1_addr_o),
    .wbm1_dat_i(wbm1_dat_o),
    .wbm1_dat_o(wbm1_dat_i),
    .wbm1_we_i(wbm1_we_o),
    .wbm1_sel_i(wbm1_sel_o),
    .wbm1_stb_i(wbm1_stb_o),
    .wbm1_ack_o(wbm1_ack_i),
    .wbm1_err_o(),
    .wbm1_rty_o(),
    .wbm1_cyc_i(wbm1_stb_o),

    /*
     * Wishbone slave output
     */
    .wbs_adr_o(wbs_addr_i),
    .wbs_dat_i(wbs_dat_o),
    .wbs_dat_o(wbs_dat_i),
    .wbs_we_o(wbs_we_i),
    .wbs_sel_o(wbs_sel_i),
    .wbs_stb_o(wbs_stb_i),
    .wbs_ack_i(wbs_ack_o),
    .wbs_err_i('0),
    .wbs_rty_i('0),
    .wbs_cyc_o(wbs_cyc_i)
);

// MUX => slaves
wb_mux_3 wb_mux (
    .clk(sys_clk),
    .rst(sys_rst),

    // Master interface (to the arbiter)
    .wbm_adr_i(wbs_addr_i),
    .wbm_dat_i(wbs_dat_i),
    .wbm_dat_o(wbs_dat_o),
    .wbm_we_i (wbs_we_i),
    .wbm_sel_i(wbs_sel_i),
    .wbm_stb_i(wbs_stb_i),
    .wbm_ack_o(wbs_ack_o),
    .wbm_err_o(),
    .wbm_rty_o(),
    .wbm_cyc_i(wbs_cyc_i),

    // Slave interface 0 (to BaseRAM controller)
    // Address range: 0x8000_0000 ~ 0x803F_FFFF
    .wbs0_addr    (32'h8000_0000),
    .wbs0_addr_msk(32'hFFC0_0000),

    .wbs0_adr_o(wbs0_adr_i),
    .wbs0_dat_i(wbs0_dat_o),
    .wbs0_dat_o(wbs0_dat_i),
    .wbs0_we_o (wbs0_we_i),
    .wbs0_sel_o(wbs0_sel_i),
    .wbs0_stb_o(wbs0_stb_i),
    .wbs0_ack_i(wbs0_ack_o),
    .wbs0_err_i('0),
    .wbs0_rty_i('0),
    .wbs0_cyc_o(wbs0_cyc_i),

    // Slave interface 1 (to ExtRAM controller)
    // Address range: 0x8040_0000 ~ 0x807F_FFFF
    .wbs1_addr    (32'h8040_0000),
    .wbs1_addr_msk(32'hFFC0_0000),

    .wbs1_adr_o(wbs1_adr_i),
    .wbs1_dat_i(wbs1_dat_o),
    .wbs1_dat_o(wbs1_dat_i),
    .wbs1_we_o (wbs1_we_i),
    .wbs1_sel_o(wbs1_sel_i),
    .wbs1_stb_o(wbs1_stb_i),
    .wbs1_ack_i(wbs1_ack_o),
    .wbs1_err_i('0),
    .wbs1_rty_i('0),
    .wbs1_cyc_o(wbs1_cyc_i),

    // Slave interface 2 (to UART controller)
    // Address range: 0x1000_0000 ~ 0x1000_FFFF
    .wbs2_addr    (32'h1000_0000),
    .wbs2_addr_msk(32'hFFFF_0000),

    .wbs2_adr_o(wbs2_adr_i),
    .wbs2_dat_i(wbs2_dat_o),
    .wbs2_dat_o(wbs2_dat_i),
    .wbs2_we_o (wbs2_we_i),
    .wbs2_sel_o(wbs2_sel_i),
    .wbs2_stb_o(wbs2_stb_i),
    .wbs2_ack_i(wbs2_ack_o),
    .wbs2_err_i('0),
    .wbs2_rty_i('0),
    .wbs2_cyc_o(wbs2_cyc_i)
  );


/* =========== Slaves begin =========== */
sram_controller #(
    .SRAM_ADDR_WIDTH(20),
    .SRAM_DATA_WIDTH(32)
) sram_controller_base (
    .clk_i(sys_clk),
    .rst_i(sys_rst),

    // Wishbone slave (to MUX)
    .wb_cyc_i(wbs0_cyc_i),
    .wb_stb_i(wbs0_stb_i),
    .wb_ack_o(wbs0_ack_o),
    .wb_adr_i(wbs0_adr_i),
    .wb_dat_i(wbs0_dat_i),
    .wb_dat_o(wbs0_dat_o),
    .wb_sel_i(wbs0_sel_i),
    .wb_we_i (wbs0_we_i),

    // To SRAM chip
    .sram_addr(base_ram_addr),
    .sram_data(base_ram_data),
    .sram_ce_n(base_ram_ce_n),
    .sram_oe_n(base_ram_oe_n),
    .sram_we_n(base_ram_we_n),
    .sram_be_n(base_ram_be_n)
);

sram_controller #(
    .SRAM_ADDR_WIDTH(20),
    .SRAM_DATA_WIDTH(32)
) sram_controller_ext (
    .clk_i(sys_clk),
    .rst_i(sys_rst),

    // Wishbone slave (to MUX)
    .wb_cyc_i(wbs1_cyc_i),
    .wb_stb_i(wbs1_stb_i),
    .wb_ack_o(wbs1_ack_o),
    .wb_adr_i(wbs1_adr_i),
    .wb_dat_i(wbs1_dat_i),
    .wb_dat_o(wbs1_dat_o),
    .wb_sel_i(wbs1_sel_i),
    .wb_we_i (wbs1_we_i),

    // To SRAM chip
    .sram_addr(ext_ram_addr),
    .sram_data(ext_ram_data),
    .sram_ce_n(ext_ram_ce_n),
    .sram_oe_n(ext_ram_oe_n),
    .sram_we_n(ext_ram_we_n),
    .sram_be_n(ext_ram_be_n)
);

uart_controller #(
    .CLK_FREQ(10_000_000),
    .BAUD    (115200)
) uart_controller (
    .clk_i(sys_clk),
    .rst_i(sys_rst),

    .wb_cyc_i(wbs2_cyc_i),
    .wb_stb_i(wbs2_stb_i),
    .wb_ack_o(wbs2_ack_o),
    .wb_adr_i(wbs2_adr_i),
    .wb_dat_i(wbs2_dat_i),
    .wb_dat_o(wbs2_dat_o),
    .wb_sel_i(wbs2_sel_i),
    .wb_we_i (wbs2_we_i),

    // to UART pins
    .uart_txd_o(txd),
    .uart_rxd_i(rxd)
);

/* =========== Slaves end =========== */

/* =========== Wishbone code end =========== */

wire if_stage_invalid;
wire if_stage_into_bubble;
wire if_to_id_wr_en;
wire id_stage_into_bubble;
wire id_to_exe_wr_en;
wire exe_to_mem_wr_en;
wire mem_stage_into_bubble;
wire pc_wr_en;
wire pc_is_from_branch;

wire mem_stage_request_use;
assign mem_stage_request_use = mem_stage_mem_rd_en | mem_stage_mem_wr_en;

hazard_detection_unit hazard_detection_unit_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .exe_stage_should_branch(pc_is_from_branch),
    .mem_stage_ack(data_mem_and_peripheral_ack),
    .if_stage_ack(instruction_mem_ack),
    .if_stage_using_bus(wbm0_stb_o),
    .mem_stage_using_bus(wbm1_stb_o),
    .mem_stage_request_use(mem_stage_request_use),
    .if_stage_invalid(if_stage_invalid),
    .if_stage_into_bubble(if_stage_into_bubble),
    .bus_is_busy(bus_is_busy),
    .mem_stage_into_bubble(mem_stage_into_bubble),
    .exe_to_mem_wr_en(exe_to_mem_wr_en),
    .id_to_exe_wr_en(id_to_exe_wr_en),
    .id_stage_into_bubble(id_stage_into_bubble),
    .if_to_id_wr_en(if_to_id_wr_en),
    .pc_wr_en(pc_wr_en)
);

wire [ADDR_WIDTH-1:0] next_normal_pc;
assign next_normal_pc = 'd4 + if_stage_pc;

wire [ADDR_WIDTH-1:0] branch_pc;
wire [ADDR_WIDTH-1:0] pc_chosen;

pc_mux #(
    .ADDR_WIDTH(ADDR_WIDTH)
) pc_mux_inst (
    .next_normal_pc(next_normal_pc),
    .branch_pc(branch_pc),
    .pc_is_from_branch(pc_is_from_branch),
    .pc_chosen(pc_chosen)
);

PC_reg #(
    .START_PC(START_PC),
    .ADDR_WIDTH(ADDR_WIDTH)
) PC_reg_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .wr_en(pc_wr_en),
    .input_pc(pc_chosen),
    .pc_is_from_branch(pc_is_from_branch),
    .output_pc(if_stage_pc)
);

wire [INSTR_WIDTH-1:0] if_stage_instr_o;

nop_instr_mux #(
    .INSTR_WIDTH(INSTR_WIDTH),
    .NOP(NOP)
) nop_instr_mux_inst (
    .if_stage_into_bubble(if_stage_into_bubble),
    .if_stage_invalid(if_stage_invalid),
    .fetched_instr(fetched_instr),
    .if_stage_instr_o(if_stage_instr_o)
);

wire [INSTR_WIDTH-1:0] id_stage_instr;
wire [ADDR_WIDTH-1:0] id_stage_pc;

IF_to_ID_regs #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .INSTR_WIDTH(INSTR_WIDTH),
    .NOP(NOP)
) IF_to_ID_regs_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .wr_en(if_to_id_wr_en),
    .instr_i(if_stage_instr_o),
    .pc_i(if_stage_pc),

    .instr(id_stage_instr),
    .pc(id_stage_pc)
);

wire [DATA_WIDTH-1:0] wb_stage_wr_rf_data;
wire [DATA_WIDTH-1:0] raw_rf_rdata_a;
wire [DATA_WIDTH-1:0] raw_rf_rdata_b;
wire [REG_ADDR_WIDTH-1:0] wb_stage_rf_waddr;
wire wb_stage_rf_wr_en;
wire [REG_ADDR_WIDTH-1:0] decoded_rf_raddr_a;
wire [REG_ADDR_WIDTH-1:0] decoded_rf_raddr_b;

register_file #(
    .DATA_WIDTH(DATA_WIDTH),
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) register_file_inst (
    .clk(sys_clk),
    .reset(sys_rst),
    .rf_raddr_a(decoded_rf_raddr_a),
    .rf_rdata_a(raw_rf_rdata_a),
    .rf_raddr_b(decoded_rf_raddr_b),
    .rf_rdata_b(raw_rf_rdata_b),
    .rf_waddr(wb_stage_rf_waddr),
    .rf_wdata(wb_stage_wr_rf_data),
    .rf_we(wb_stage_rf_wr_en)
);

wire decoded_mem_rd_en;
wire decoded_mem_wr_en;
wire decoded_is_branch_type;
wire decoded_rf_w_src_mem_h_alu_l;
wire decoded_alu_src_reg_h_imm_low;
wire decoded_rf_wr_en;
wire [1:0] decoded_sel_cnt;
wire [DATA_WIDTH-1:0] decoded_imm;
wire [ALU_OP_ENCODING_WIDTH-1:0] decoded_alu_op;
wire [REG_ADDR_WIDTH-1:0] decoded_rf_waddr;

instr_decoder #(
    .INSTR_WIDTH(INSTR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
    .ALU_OP_ENCODING_WIDTH(ALU_OP_ENCODING_WIDTH)
) instr_decoder_inst (
    // input instruction
    .instr_i(id_stage_instr),

    // pure control signal outputs
    .decoded_mem_rd_en_o(decoded_mem_rd_en),
    .decoded_mem_wr_en_o(decoded_mem_wr_en),
    .decoded_is_branch_type_o(decoded_is_branch_type),
    .decoded_rf_w_src_mem_h_alu_l_o(decoded_rf_w_src_mem_h_alu_l),
    .decoded_alu_src_reg_h_imm_low_o(decoded_alu_src_reg_h_imm_low),
    .decoded_rf_wr_en_o(decoded_rf_wr_en),

    // other output signals with more concrete meaning
    .decoded_sel_cnt_o(decoded_sel_cnt),
    .decoded_rf_raddr_a_o(decoded_rf_raddr_a),
    .decoded_rf_raddr_b_o(decoded_rf_raddr_b),
    .decoded_imm_o(decoded_imm),
    .decoded_alu_op_o(decoded_alu_op),
    .decoded_rf_waddr_o(decoded_rf_waddr)
);

wire id_stage_forward_a;
wire id_stage_forward_b;

wire [DATA_WIDTH-1:0] id_stage_rf_rdata_a;

id_forward_rf_rdata_mux #(
    .DATA_WIDTH(DATA_WIDTH)
) id_forward_a_mux_inst (
    .rf_rdata_i(raw_rf_rdata_a),
    .wr_rf_data_i(wb_stage_wr_rf_data),
    .forward_ctrl_i(id_stage_forward_a),
    .rf_rdata_o(id_stage_rf_rdata_a)
);

wire [DATA_WIDTH-1:0] id_stage_rf_rdata_b;

id_forward_rf_rdata_mux #(
    .DATA_WIDTH(DATA_WIDTH)
) id_forward_b_mux_inst (
    .rf_rdata_i(raw_rf_rdata_b),
    .wr_rf_data_i(wb_stage_wr_rf_data),
    .forward_ctrl_i(id_stage_forward_b),
    .rf_rdata_o(id_stage_rf_rdata_b)
);

wire id_stage_mem_rd_en_o;
wire id_stage_mem_wr_en_o;
wire id_stage_is_branch_type_o;
wire id_stage_rf_w_src_mem_h_alu_l_o;
wire id_stage_alu_src_reg_h_imm_low_o;
wire id_stage_rf_wr_en_o;

id_stage_bubblify_unit id_stage_bubblify_unit_inst (
    .mem_rd_en_i(decoded_mem_rd_en),
    .mem_wr_en_i(decoded_mem_wr_en),
    .is_branch_type_i(decoded_is_branch_type),
    .rf_w_src_mem_h_alu_l_i(decoded_rf_w_src_mem_h_alu_l),
    .alu_src_reg_h_imm_low_i(decoded_alu_src_reg_h_imm_low),
    .rf_wr_en_i(decoded_rf_wr_en),
    .id_stage_into_bubble_i(id_stage_into_bubble),

    .mem_rd_en_o(id_stage_mem_rd_en_o),
    .mem_wr_en_o(id_stage_mem_wr_en_o),
    .is_branch_type_o(id_stage_is_branch_type_o),
    .rf_w_src_mem_h_alu_l_o(id_stage_rf_w_src_mem_h_alu_l_o),
    .alu_src_reg_h_imm_low_o(id_stage_alu_src_reg_h_imm_low_o),
    .rf_wr_en_o(id_stage_rf_wr_en_o)
);

wire exe_stage_mem_rd_en;
wire exe_stage_mem_wr_en;
wire exe_stage_is_branch_type;
wire exe_stage_rf_w_src_mem_h_alu_l;
wire exe_stage_alu_src_reg_h_imm_low;
wire exe_stage_rf_wr_en;
wire [ADDR_WIDTH-1:0] exe_stage_pc;
wire [1:0] exe_stage_sel_cnt;
wire [DATA_WIDTH-1:0] exe_stage_rf_rdata_a;
wire [DATA_WIDTH-1:0] exe_stage_rf_rdata_b;
wire [DATA_WIDTH-1:0] exe_stage_imm;
wire [ALU_OP_ENCODING_WIDTH-1:0] exe_stage_alu_op;
wire [REG_ADDR_WIDTH-1:0] exe_stage_rf_waddr;
wire [REG_ADDR_WIDTH-1:0] exe_stage_rf_raddr_a;
wire [REG_ADDR_WIDTH-1:0] exe_stage_rf_raddr_b;

assign branch_pc = exe_stage_pc + exe_stage_imm;

id_forwarding_unit #(
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) id_forwarding_unit_inst (
    .wb_en(wb_stage_rf_wr_en),
    .wb_addr(wb_stage_rf_waddr),
    .rf_raddr_a(decoded_rf_raddr_a),
    .rf_raddr_b(decoded_rf_raddr_b),
    .operand_a_should_forward(id_stage_forward_a),
    .operand_b_should_forward(id_stage_forward_b)
);

ID_to_EXE_regs #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ALU_OP_ENCODING_WIDTH(ALU_OP_ENCODING_WIDTH),
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) ID_to_EXE_regs_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .wr_en(id_to_exe_wr_en),

    .mem_rd_en_i(id_stage_mem_rd_en_o),
    .mem_wr_en_i(id_stage_mem_wr_en_o),
    .is_branch_type_i(id_stage_is_branch_type_o),
    .rf_w_src_mem_h_alu_l_i(id_stage_rf_w_src_mem_h_alu_l_o),
    .alu_src_reg_h_imm_low_i(id_stage_alu_src_reg_h_imm_low_o),
    .rf_wr_en_i(id_stage_rf_wr_en_o),
    .pc_i(id_stage_pc),
    .sel_cnt_i(decoded_sel_cnt),
    .rf_rdata_a_i(id_stage_rf_rdata_a),
    .rf_rdata_b_i(id_stage_rf_rdata_b),
    .imm_i(decoded_imm),
    .alu_op_i(decoded_alu_op),
    .rf_waddr_i(decoded_rf_waddr),
    .rf_raddr_a_i(decoded_rf_raddr_a),
    .rf_raddr_b_i(decoded_rf_raddr_b),

    .mem_rd_en(exe_stage_mem_rd_en),
    .mem_wr_en(exe_stage_mem_wr_en),
    .is_branch_type(exe_stage_is_branch_type),
    .rf_w_src_mem_h_alu_l(exe_stage_rf_w_src_mem_h_alu_l),
    .alu_src_reg_h_imm_low(exe_stage_alu_src_reg_h_imm_low),
    .rf_wr_en(exe_stage_rf_wr_en),
    .pc(exe_stage_pc),
    .sel_cnt(exe_stage_sel_cnt),
    .rf_rdata_a(exe_stage_rf_rdata_a),
    .rf_rdata_b(exe_stage_rf_rdata_b),
    .imm(exe_stage_imm),
    .alu_op(exe_stage_alu_op),
    .rf_waddr(exe_stage_rf_waddr),
    .rf_raddr_a(exe_stage_rf_raddr_a),
    .rf_raddr_b(exe_stage_rf_raddr_b)
);

wire [1:0] exe_stage_forward_a;
wire [1:0] exe_stage_forward_b;

wire [DATA_WIDTH-1:0] exe_stage_operand_a;

exe_forward_operand_mux #(
    .DATA_WIDTH(DATA_WIDTH)
) exe_forward_a_mux_inst (
    .exe_stage_rf_rdata_i(exe_stage_rf_rdata_a),
    .wb_stage_wr_rf_data_i(wb_stage_wr_rf_data),
    .exe_to_mem_alu_result_i(mem_stage_alu_result),
    .forward_ctrl_i(exe_stage_forward_a),
    .operand_o(exe_stage_operand_a)
);

wire [DATA_WIDTH-1:0] exe_stage_non_imm_operand_b;

exe_forward_operand_mux #(
    .DATA_WIDTH(DATA_WIDTH)
) exe_forward_b_mux_inst (
    .exe_stage_rf_rdata_i(exe_stage_rf_rdata_b),
    .wb_stage_wr_rf_data_i(wb_stage_wr_rf_data),
    .exe_to_mem_alu_result_i(mem_stage_alu_result),
    .forward_ctrl_i(exe_stage_forward_b),
    .operand_o(exe_stage_non_imm_operand_b)
);

wire [DATA_WIDTH-1:0] exe_stage_operand_b;

imm_mux #(
    .DATA_WIDTH(DATA_WIDTH)
) imm_mux_inst (
    .non_imm_i(exe_stage_non_imm_operand_b),
    .imm_i(exe_stage_imm),
    .non_imm_h_imm_low_ctrl_i(exe_stage_alu_src_reg_h_imm_low),
    .operand_o(exe_stage_operand_b)
);

wire [DATA_WIDTH-1:0] exe_stage_alu_result;

ALU #(
    .DATA_WIDTH(DATA_WIDTH),
    .ALU_OP_ENCODING_WIDTH(ALU_OP_ENCODING_WIDTH)
) ALU_inst (
    .operand_a(exe_stage_operand_a),
    .operand_b(exe_stage_operand_b),
    .alu_op(exe_stage_alu_op),
    .alu_result(exe_stage_alu_result)
);

branch_taker branch_taker_inst (
    .is_branch_i(exe_stage_is_branch_type),
    .alu_branch_result_i(exe_stage_alu_result),
    .take_branch_o(pc_is_from_branch)
);

wire mem_stage_rf_wr_en;
wire [REG_ADDR_WIDTH-1:0] mem_stage_rf_waddr;

exe_forwarding_unit #(
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) exe_forwarding_unit_inst (
    .exe_to_mem_rf_wr_en_i(mem_stage_rf_wr_en),
    .mem_to_wb_rf_wr_en_i(wb_stage_rf_wr_en),
    .exe_stage_operand_a_rf_addr_i(exe_stage_rf_raddr_a),
    .exe_stage_operand_b_rf_addr_i(exe_stage_rf_raddr_b),
    .exe_to_mem_rf_wr_addr_i(mem_stage_rf_waddr),
    .mem_to_wb_rf_wr_addr_i(wb_stage_rf_waddr),
    .forward_a_o(exe_stage_forward_a),
    .forward_b_o(exe_stage_forward_b)
);

wire mem_stage_rf_w_src_mem_h_alu_l;
wire [1:0] mem_stage_sel_cnt;

EXE_to_MEM_regs #(
    .DATA_WIDTH(DATA_WIDTH),
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) EXE_to_MEM_regs_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .wr_en(exe_to_mem_wr_en),

    .mem_rd_en_i(exe_stage_mem_rd_en),
    .mem_wr_en_i(exe_stage_mem_wr_en),
    .rf_w_src_mem_h_alu_l_i(exe_stage_rf_w_src_mem_h_alu_l),
    .rf_wr_en_i(exe_stage_rf_wr_en),
    .sel_cnt_i(exe_stage_sel_cnt),
    .alu_result_i(exe_stage_alu_result),
    .non_imm_operand_b_i(exe_stage_non_imm_operand_b),
    .rf_waddr_i(exe_stage_rf_waddr),

    .mem_rd_en(mem_stage_mem_rd_en),
    .mem_wr_en(mem_stage_mem_wr_en),
    .rf_w_src_mem_h_alu_l(mem_stage_rf_w_src_mem_h_alu_l),
    .rf_wr_en(mem_stage_rf_wr_en),
    .sel_cnt(mem_stage_sel_cnt),
    .alu_result(mem_stage_alu_result),
    .non_imm_operand_b(mem_stage_non_imm_operand_b),
    .rf_waddr(mem_stage_rf_waddr)
);

wire [DATA_WIDTH-1:0] mem_stage_rd_mem_data;

unaligned_transfer_unit #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .SELECT_WIDTH(SELECT_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) unaligned_transfer_unit_inst (
    .sel_cnt_i(mem_stage_sel_cnt),
    .mem_stage_request_use_i(mem_stage_request_use),
    .mem_addr_i(mem_stage_alu_result),
    .wr_data_i(mem_stage_non_imm_operand_b),
    .rd_mem_data_i(raw_rd_mem_data),
    .sel_o(mem_stage_sel),
    .wr_data_o(mem_stage_wr_data),
    .transfered_rd_mem_data_o(mem_stage_rd_mem_data)
);

wire final_mem_stage_rf_w_src_mem_h_alu_l;
wire final_mem_stage_rf_wr_en;

mem_stage_bubblify_mux mem_stage_bubblify_mux_inst (
    .into_bubble_i(mem_stage_into_bubble),
    .rf_w_src_mem_h_alu_l_i(mem_stage_rf_w_src_mem_h_alu_l),
    .rf_wr_en_i(mem_stage_rf_wr_en),
    .rf_w_src_mem_h_alu_l_o(final_mem_stage_rf_w_src_mem_h_alu_l),
    .rf_wr_en_o(final_mem_stage_rf_wr_en)
);

wire [DATA_WIDTH-1:0] wb_stage_rd_mem_data;
wire [DATA_WIDTH-1:0] wb_stage_alu_result;
wire wb_stage_rf_w_src_mem_h_alu_l;

MEM_to_WB_regs #(
    .DATA_WIDTH(DATA_WIDTH),
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) MEM_to_WB_regs_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .wr_en(1'd1),

    .rf_w_src_mem_h_alu_l_i(final_mem_stage_rf_w_src_mem_h_alu_l),
    .rf_wr_en_i(final_mem_stage_rf_wr_en),
    .rd_mem_data_i(mem_stage_rd_mem_data),
    .alu_result_i(mem_stage_alu_result),
    .rf_waddr_i(mem_stage_rf_waddr),

    .rf_w_src_mem_h_alu_l(wb_stage_rf_w_src_mem_h_alu_l),
    .rf_wr_en(wb_stage_rf_wr_en),
    .rd_mem_data(wb_stage_rd_mem_data),
    .alu_result(wb_stage_alu_result),
    .rf_waddr(wb_stage_rf_waddr)
);

wb_source_mux #(
    .DATA_WIDTH(DATA_WIDTH)
) wb_source_mux_inst (
    .rd_mem_data_i(wb_stage_rd_mem_data),
    .alu_result_i(wb_stage_alu_result),
    .wb_source_mem_h_alu_l_ctrl_i(wb_stage_rf_w_src_mem_h_alu_l),
    .wb_data_o(wb_stage_wr_rf_data)
);

endmodule