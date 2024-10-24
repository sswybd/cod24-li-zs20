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

logic locked, clk_10M, clk_20M;
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
parameter SELECT_WIDTH = (DATA_WIDTH / 8);
parameter REG_ADDR_WIDTH = 5;

wire data_mem_and_peripheral_ack;
wire instruction_mem_ack;
wire bus_is_busy;

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
    .addr_i(),
    .bus_is_busy(bus_is_busy),
    .wr_data_i({DATA_WIDTH{1'b0}}),
    .bus_data_i(wbm0_dat_i),
    .sel_i(4'b1111),
    .ack_i(wbm0_ack_i),
    .rd_en(1'd1),
    .wr_en(1'd0),
    .ack_o(instruction_mem_ack),
    .stb_o(wbm0_stb_o),
    .rd_data_o(),
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
    .addr_i(),
    .bus_is_busy(bus_is_busy),
    .wr_data_i(),
    .bus_data_i(wbm1_dat_i),
    .sel_i(),
    .ack_i(wbm1_ack_i),
    .rd_en(),
    .wr_en(),
    .ack_o(data_mem_and_peripheral_ack),
    .stb_o(wbm1_stb_o),
    .rd_data_o(),
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

hazard_detection_unit hazard_detection_unit_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .exe_stage_should_branch(),
    .mem_stage_ack(data_mem_and_peripheral_ack),
    .if_stage_ack(instruction_mem_ack),
    .if_stage_using_bus(wbm0_stb_o),
    .mem_stage_using_bus(wbm1_stb_o),
    .mem_stage_request_use(),
    .if_stage_invalid(),
    .if_stage_into_bubble(),
    .bus_is_busy(bus_is_busy),
    .mem_stage_into_bubble(),
    .exe_to_mem_wr_en(),
    .id_to_exe_wr_en(),
    .id_stage_into_bubble(),
    .if_to_id_wr_en(),
    .pc_wr_en()
);

PC_reg #(
    .START_PC(START_PC),
    .ADDR_WIDTH(ADDR_WIDTH)
) PC_reg_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .wr_en(),
    .input_pc(),
    .pc_is_from_branch(),
    .output_pc()
);

register_file register_file_inst (
    .clk(sys_clk),
    .reset(sys_rst),
    .rf_raddr_a(),
    .rf_rdata_a(),
    .rf_raddr_b(),
    .rf_rdata_b(),
    .rf_waddr(),
    .rf_wdata(),
    .rf_we()
);

ALU #(
    .DATA_WIDTH(DATA_WIDTH)
) ALU_inst (
    .operand_a(),
    .operand_b(),
    .alu_op(),
    .alu_result()
);

exe_forwarding_unit #(
    .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
) exe_forwarding_unit_inst (
    .exe_to_mem_rf_wr_en(),
    .mem_to_wb_rf_wr_en(),
    .exe_stage_operand_a_rf_addr(),
    .exe_stage_operand_b_rf_addr(),
    .exe_to_mem_rf_wr_addr(),
    .mem_to_wb_rf_wr_addr(),
    .forward_a(),
    .forward_b()
);

endmodule

/* =========== Demo code begin =========== */

  // 数码管连接关系示意图，dpy1 同理
  // p=dpy0[0] // ---a---
  // c=dpy0[1] // |     |
  // d=dpy0[2] // f     b
  // e=dpy0[3] // |     |
  // b=dpy0[4] // ---g---
  // a=dpy0[5] // |     |
  // f=dpy0[6] // e     c
  // g=dpy0[7] // |     |
  //           // ---d---  p

  // 7 段数码管译码器演示，将 number 用 16 进制显示在数码管上面
//   logic [7:0] number;
//   SEG7_LUT segL (
//       .oSEG1(dpy0),
//       .iDIG (number[3:0])
//   );  // dpy0 是低位数码管
//   SEG7_LUT segH (
//       .oSEG1(dpy1),
//       .iDIG (number[7:4])
//   );  // dpy1 是高位数码管



//   // 直连串口接收发送演示，从直连串口收到的数据再发送出去
//   logic [7:0] ext_uart_rx;
//   logic [7:0] ext_uart_buffer, ext_uart_tx;
//   logic ext_uart_ready, ext_uart_clear, ext_uart_busy;
//   logic ext_uart_start, ext_uart_avai;

//   assign number = ext_uart_buffer;

//   // 接收模块，9600 无检验位
//   async_receiver #(
//       .ClkFrequency(50000000),
//       .Baud(9600)
//   ) ext_uart_r (
//       .clk           (clk_50M),         // 外部时钟信号
//       .RxD           (rxd),             // 外部串行信号输入
//       .RxD_data_ready(ext_uart_ready),  // 数据接收到标志
//       .RxD_clear     (ext_uart_clear),  // 清除接收标志
//       .RxD_data      (ext_uart_rx)      // 接收到的一字节数据
//   );

//   assign ext_uart_clear = ext_uart_ready; // 收到数据的同时，清除标志，因为数据已取到 ext_uart_buffer 中
//   always_ff @(posedge clk_50M) begin  // 接收到缓冲区 ext_uart_buffer
//     if (ext_uart_ready) begin
//       ext_uart_buffer <= ext_uart_rx;
//       ext_uart_avai   <= 1;
//     end else if (!ext_uart_busy && ext_uart_avai) begin
//       ext_uart_avai <= 0;
//     end
//   end
//   always_ff @(posedge clk_50M) begin  // 将缓冲区 ext_uart_buffer 发送出去
//     if (!ext_uart_busy && ext_uart_avai) begin
//       ext_uart_tx <= ext_uart_buffer;
//       ext_uart_start <= 1;
//     end else begin
//       ext_uart_start <= 0;
//     end
//   end

//   // 发送模块，9600 无检验位
//   async_transmitter #(
//       .ClkFrequency(50000000),
//       .Baud(9600)
//   ) ext_uart_t (
//       .clk      (clk_50M),         // 外部时钟信号
//       .TxD      (txd),             // 串行信号输出
//       .TxD_busy (ext_uart_busy),   // 发送器忙状态指示
//       .TxD_start(ext_uart_start),  // 开始发送信号
//       .TxD_data (ext_uart_tx)      // 待发送的数据
//   );

//   // 图像输出演示，分辨率 800x600@72Hz，像素时钟为 50MHz
//   logic [11:0] hdata;
//   assign video_red   = hdata < 266 ? 3'b111 : 0;  // 红色竖条
//   assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0;  // 绿色竖条
//   assign video_blue  = hdata >= 532 ? 2'b11 : 0;  // 蓝色竖条
//   assign video_clk   = clk_50M;
//   vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at72 (
//       .clk        (clk_50M),
//       .hdata      (hdata),        // 横坐标
//       .vdata      (),             // 纵坐标
//       .hsync      (video_hsync),
//       .vsync      (video_vsync),
//       .data_enable(video_de)
//   );
  /* =========== Demo code end =========== */
