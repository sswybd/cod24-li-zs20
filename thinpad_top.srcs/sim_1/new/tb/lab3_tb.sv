`timescale 1ns / 1ps

`define WAIT_FOR_PLL_LOCKED 2500

module lab3_tb;
  wire clk_50M, clk_11M0592;

  reg push_btn;   // BTN5 按钮开关，带消抖电路，按下时为 1
  reg reset_btn;  // BTN6 复位按钮，带消抖电路，按下时为 1

  reg [3:0] touch_btn; // BTN1~BTN4，按钮开关，按下时为 1
  reg [31:0] dip_sw;   // 32 位拨码开关，拨到“ON”时为 1

  wire [15:0] leds;  // 16 位 LED，输出时 1 点亮
  wire [7:0] dpy0;   // 数码管低位信号，包括小数点，输出 1 点亮
  wire [7:0] dpy1;   // 数码管高位信号，包括小数点，输出 1 点亮

  // lab3 用到的指令格式
  `define inst_rtype(rd, rs1, rs2, op) \
    {7'b0, rs2, rs1, 3'b0, rd, op, 3'b001}

  `define inst_itype(rd, imm, op) \
    {imm, 4'b0, rd, op, 3'b010}
  
  `define inst_poke(rd, imm) `inst_itype(rd, imm, 4'b0001)
  `define inst_peek(rd, imm) `inst_itype(rd, imm, 4'b0010)

  // opcode table
  typedef enum logic [3:0] {
    ADD = 4'b0001,
    SUB = 4'b0010,
    AND = 4'b0011,
    OR  = 4'b0100,
    XOR = 4'b0101,
    NOT = 4'b0110,
    SLL = 4'b0111,
    SRL = 4'b1000,
    SRA = 4'b1001,
    ROL = 4'b1010
  } opcode_t;

  logic is_rtype, is_itype, is_load, is_store, is_unknown;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  // [1, 6]  ops as one group
  // [7, 10] ops as another group, because they're shifts and operand B can't be too big
  task test_op_one_round;
    input [3:0] low;
    input [3:0] high;

    rd  = $urandom_range(0, 31);
    rs1 = $urandom_range(0, 31);
    rs2 = $urandom_range(0, 31);

    dip_sw = `inst_peek(rs1, 16'd0);
    push_btn = 1;
    #100;
    push_btn = 0;
    #350;
    $display("%d: Read operand1: %d", $time, leds);

    if (low >= 4'd7) begin
      imm = $urandom_range(0, 16);  // shift at most 16 bits
      dip_sw = `inst_poke(rs2, imm);
      push_btn = 1;
      #100;
      push_btn = 0;
      #200;

      dip_sw = `inst_peek(rs2, 16'd0);
      push_btn = 1;
      #100;
      push_btn = 0;      
    end 
    else begin
      dip_sw = `inst_peek(rs2, 16'd0);
      push_btn = 1;
      #100;
      push_btn = 0;
    end
    #350;
    
    $display("%d: Read operand2: %d", $time, leds);

    opcode = $urandom_range(low, high);

    dip_sw = `inst_rtype(rd, rs1, rs2, opcode);  // random op type
    push_btn = 1;
    #100;
    push_btn = 0;
    #500;

    // check destination operand
    dip_sw = `inst_peek(rd, 16'd0);
    push_btn = 1;
    #100;
    push_btn = 0;
    #350;
    $display("%d: Read %d-opcode result: %d", $time, opcode, leds);
  endtask

  initial begin
    // 在这里可以自定义测试输入序列，例如：
    dip_sw = 32'h0;
    touch_btn = 0;
    reset_btn = 0;
    push_btn = 0;

    #100;
    reset_btn = 1;
    #100;
    reset_btn = 0;
    #`WAIT_FOR_PLL_LOCKED;

    // 样例：使用 POKE 指令为寄存器赋随机初值
    for (int i = 0; i < 32; i = i + 1) begin
      #100;
      rd = i;   // only lower 5 bits
      imm = $urandom_range(0, 65535);
      dip_sw = `inst_poke(rd, imm);
      push_btn = 1;
      #100;
      push_btn = 0;

      $display("%d: Write imm %d to reg #%d", $time, imm, i);

      #800;
    end
    #1200;

    // check all registers
    for (int i = 0; i < 32; i = i + 1) begin
      #100;
      rd = i;
      dip_sw = `inst_peek(rd, 16'd0);
      push_btn = 1;
      #100;
      push_btn = 0;
      #350;

      $display("%d: Read reg #%d: %d", $time, i, leds);

      #800;
    end
    #2000;

    // randomly test the operations
    for (int i = 0; i < 65; i++) begin
      test_op_one_round(4'd1, 4'd6);  // test operations other than shifts
      #350;
      test_op_one_round(4'd7, 4'd10);  // test shift operations
      #700;
    end
    
    #10000 $finish;
  end

  // 待测试用户设计
  lab3_top dut (
      .clk_50M(clk_50M),
      .clk_11M0592(clk_11M0592),
      .push_btn(push_btn),
      .reset_btn(reset_btn),
      .touch_btn(touch_btn),
      .dip_sw(dip_sw),
      .leds(leds),
      .dpy1(dpy1),
      .dpy0(dpy0),

      .txd(),
      .rxd(1'b1),
      .uart_rdn(),
      .uart_wrn(),
      .uart_dataready(1'b0),
      .uart_tbre(1'b0),
      .uart_tsre(1'b0),
      .base_ram_data(),
      .base_ram_addr(),
      .base_ram_ce_n(),
      .base_ram_oe_n(),
      .base_ram_we_n(),
      .base_ram_be_n(),
      .ext_ram_data(),
      .ext_ram_addr(),
      .ext_ram_ce_n(),
      .ext_ram_oe_n(),
      .ext_ram_we_n(),
      .ext_ram_be_n(),
      .flash_d(),
      .flash_a(),
      .flash_rp_n(),
      .flash_vpen(),
      .flash_oe_n(),
      .flash_ce_n(),
      .flash_byte_n(),
      .flash_we_n()
  );

  // 时钟源
  clock osc (
      .clk_11M0592(clk_11M0592),
      .clk_50M    (clk_50M)
  );

endmodule
