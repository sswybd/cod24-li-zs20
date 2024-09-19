`timescale 1ns / 1ps

`define WAIT_FOR_PLL_LOCKED 2500

module lab3_tb;
  wire clk_50M, clk_11M0592;

  reg push_btn;   // BTN5 按钮开关，带消抖电路，按下时为 1
  reg reset_btn;  // BTN6 复位按钮，带消抖电路，按下时为 1

  reg [31:0] dip_sw;   // 32 位拨码开关，拨到“ON”时为 1

  wire [15:0] leds;  // 16 位 LED，输出时 1 点亮

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

  task get_op_name;
    input [3:0] op;

    case (op)
      ADD: $display("ADD");
      SUB: $display("SUB");
      AND: $display("AND");
      OR:  $display("OR");
      XOR: $display("XOR");
      NOT: $display("NOT");
      SLL: $display("SLL");
      SRL: $display("SRL");
      SRA: $display("SRA");
      ROL: $display("ROL");
      default: $display("UNKNOWN");
    endcase
  endtask

  logic is_rtype, is_itype, is_load, is_store, is_unknown;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  logic [15:0] alu_a, alu_b, alu_y;  // temp storage of operands and result
  logic signed [15:0] tmp_alu_y;

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
    $display("%d: peek instruction %b", $time, dip_sw);
    $display("%d: Read operand1 from reg#%d: %d", $time, rs1, leds);
    alu_a = leds;

    if (low >= 4'd7) begin
      imm = $urandom_range(0, 16);  // shift at most 16 bits
      dip_sw = `inst_poke(rs2, imm);
      push_btn = 1;
      #100;
      push_btn = 0;
      #200;
      $display("%d: poke instruction %b", $time, dip_sw);
      $display("%d: Write imm %d to reg #%d", $time, imm, rs2);

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
    $display("%d: peek instruction %b", $time, dip_sw);
    $display("%d: Read operand2 from reg#%d: %d", $time, rs2, leds);
    alu_b = leds;

    opcode = $urandom_range(low, high);

    dip_sw = `inst_rtype(rd, rs1, rs2, opcode);  // random op type
    push_btn = 1;
    #100;
    push_btn = 0;
    #500;
    $display("%d: r instruction %b of opcode %d", $time, dip_sw, opcode);

    // check destination operand
    dip_sw = `inst_peek(rd, 16'd0);
    push_btn = 1;
    #100;
    push_btn = 0;
    #350;
    $display("%d: peek instruction %b", $time, dip_sw);
    $display("%d: Read %d-opcode result from reg#%d: %d", $time, opcode, rd, leds);
    get_op_name(opcode);

    case (opcode)
      ADD: begin
        alu_y = alu_a + alu_b;
      end
      SUB: begin
        alu_y = alu_a - alu_b;
      end
      AND: begin
        alu_y = alu_a & alu_b;
      end
      OR: begin
        alu_y = alu_a | alu_b;
      end
      XOR: begin
        alu_y = alu_a ^ alu_b;
      end
      NOT: begin
        alu_y = ~alu_a;
      end
      SLL: begin
        alu_y = alu_a << alu_b;
      end
      SRL: begin
        alu_y = alu_a >> alu_b;
      end
      SRA: begin
        tmp_alu_y = $signed(alu_a) >>> alu_b;
        alu_y = tmp_alu_y;
      end
      ROL: begin
        alu_y = (alu_a << alu_b) | (alu_a >> (16'd16 - alu_b));
      end
    endcase
    assert(alu_y == leds) else $display("ALU result mismatch!!");
  endtask

  // for actual input of the board
  task small_test;
    // only use reg 1, 2, 3; 4 is for shift operandB
    for (int i = 0; i < 5; i = i + 1) begin
      #100;
      rd = i;
      if (i == 4) begin
        imm = $urandom_range(2, 9);
      end
      else begin
        imm = $urandom_range(0, 65535);
      end
      dip_sw = `inst_poke(rd, imm);
      push_btn = 1;
      #100;
      push_btn = 0;

      $display("%d: poke instruction %b", $time, dip_sw);
      $display("%d: Write imm %d to reg #%d", $time, imm, i);

      #800;
    end
    #1200;

    // check 0, 1, 2, 3, 4, 5 (5 should be zero)
    for (int i = 0; i < 6; i = i + 1) begin
      #100;
      rd = i;
      dip_sw = `inst_peek(rd, 16'd0);
      push_btn = 1;
      #100;
      push_btn = 0;
      #350;

      $display("%d: peek instruction %b", $time, dip_sw);
      $display("%d: Read reg #%d: %d", $time, i, leds);

      #800;
    end
    #1200;

    // add #1 and #2, store to #3
    rd = 5'd3;
    rs1 = 5'd1;
    rs2 = 5'd2;
    opcode = ADD;

    while (opcode < SLL) begin
      dip_sw = `inst_rtype(rd, rs1, rs2, opcode);
      push_btn = 1;
      #100;
      push_btn = 0;
      #500;
      $display("%d: r instruction %b of opcode %d", $time, dip_sw, opcode);

      dip_sw = `inst_peek(rd, 16'd0);
      push_btn = 1;
      #100;
      push_btn = 0;

      #350;
      $display("%d: peek instruction %b", $time, dip_sw);
      $display("%d: Read %d-opcode result from reg#%d: %d", $time, opcode, rd, leds);
      get_op_name(opcode);

      opcode = opcode + 1;    
    end

    // shift #1 by #4, store to #3
    rd = 5'd3;
    rs1 = 5'd1;
    rs2 = 5'd4;

    while (opcode <= ROL) begin
      dip_sw = `inst_rtype(rd, rs1, rs2, opcode);
      push_btn = 1;
      #100;
      push_btn = 0;
      #500;
      $display("%d: r instruction %b of opcode %d", $time, dip_sw, opcode);

      dip_sw = `inst_peek(rd, 16'd0);
      push_btn = 1;
      #100;
      push_btn = 0;

      #350;
      $display("%d: peek instruction %b", $time, dip_sw);
      $display("%d: Read %d-opcode result from reg#%d: %d", $time, opcode, rd, leds);
      get_op_name(opcode);

      opcode = opcode + 1;    
    end

    $display("%d: two more!", $time);
    // srl shift x2 by x4, store to x3
    rd = 5'd3;
    rs1 = 5'd2;
    rs2 = 5'd4;
    opcode = SRL;

    dip_sw = `inst_rtype(rd, rs1, rs2, opcode);
    push_btn = 1;
    #100;
    push_btn = 0;
    #500;
    $display("%d: r instruction %b of opcode %d", $time, dip_sw, opcode);

    dip_sw = `inst_peek(rd, 16'd0);
    push_btn = 1;
    #100;
    push_btn = 0;

    #350;
    $display("%d: peek instruction %b", $time, dip_sw);
    $display("%d: Read %d-opcode result from reg#%d: %d", $time, opcode, rd, leds);
    get_op_name(opcode);

    // sra shift x2 by x4, store to x3
    rd = 5'd3;
    rs1 = 5'd2;
    rs2 = 5'd4;
    opcode = SRA;

    dip_sw = `inst_rtype(rd, rs1, rs2, opcode);
    push_btn = 1;
    #100;
    push_btn = 0;
    #500;
    $display("%d: r instruction %b of opcode %d", $time, dip_sw, opcode);

    dip_sw = `inst_peek(rd, 16'd0);
    push_btn = 1;
    #100;
    push_btn = 0;

    #350;
    $display("%d: peek instruction %b", $time, dip_sw);
    $display("%d: Read %d-opcode result from reg#%d: %d", $time, opcode, rd, leds);
    get_op_name(opcode);

    $display("%d: Finished small test case!!", $time);
  endtask

  initial begin
    // 在这里可以自定义测试输入序列，例如：
    dip_sw = 32'h0;
    reset_btn = 0;
    push_btn = 0;

    #100;
    reset_btn = 1;
    #100;
    reset_btn = 0;
    #`WAIT_FOR_PLL_LOCKED;

    small_test();

    // 样例：使用 POKE 指令为寄存器赋随机初值
    for (int i = 0; i < 32; i = i + 1) begin
      #100;
      rd = i;   // only lower 5 bits
      imm = $urandom_range(0, 65535);
      dip_sw = `inst_poke(rd, imm);
      push_btn = 1;
      #100;
      push_btn = 0;

      $display("%d: poke instruction %b", $time, dip_sw);
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

      $display("%d: peek instruction %b", $time, dip_sw);
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
    
    #4000 $finish;
  end

  // 待测试用户设计
  lab3_top dut (
      .clk_50M(clk_50M),
      .clk_11M0592(clk_11M0592),
      .push_btn(push_btn),
      .reset_btn(reset_btn),
      .touch_btn(),
      .dip_sw(dip_sw),
      .leds(leds),
      .dpy1(),
      .dpy0(),

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
