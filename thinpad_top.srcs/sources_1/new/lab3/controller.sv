`default_nettype none

module controller (
    // control signals
    input  wire           clk,
    input  wire           reset,
    input  wire           step,    // equal to the output `trigger` of `trigger.sv`
    input  wire   [31:0]  dip_sw,  // 32-bit DIP switch
    output logic  [15:0]  leds,
    
    // connect to register file
    output logic  [ 4:0]  rf_raddr_a,
    input  wire   [15:0]  rf_rdata_a,
    output logic  [ 4:0]  rf_raddr_b,
    input  wire   [15:0]  rf_rdata_b,
    output logic  [ 4:0]  rf_waddr,
    output logic  [15:0]  rf_wdata,
    output logic          rf_we,

    // connect to ALU
    output logic  [15:0]  alu_a,
    output logic  [15:0]  alu_b,
    output logic  [ 3:0]  alu_op,
    input  wire   [15:0]  alu_y,

    // connect to `inDECODE_STATEr`
    input  wire           is_rtype,
    input  wire           is_itype,
    input  wire           is_peek,
    input  wire           is_poke,
    input  wire   [15:0]  imm,
    input  wire   [ 4:0]  rd,
    input  wire   [ 4:0]  rs1,
    input  wire   [ 4:0]  rs2,
    input  wire   [ 3:0]  opcode,
    output logic  [31:0]  inst_reg  // instruction register
);

typedef enum logic [3:0] {
    INIT_STATE,
    DECODE_STATE,
    CALC_STATE,
    READ_REG_STATE,
    WRITE_REG_STATE
} state_t;

state_t state;

always_ff @(posedge clk) begin
    if (reset) begin
        state       <= INIT_STATE;
        leds        <= 16'd0;
        rf_raddr_a  <=  5'd0;
        rf_raddr_b  <=  5'd0;
        rf_waddr    <=  5'd0;
        rf_wdata    <= 16'd0;
        rf_we       <=  1'd0;
        alu_a       <= 16'd0;
        alu_b       <= 16'd0;
        alu_op      <=  4'd0;
        inst_reg    <= 32'd0;
    end 
    else begin
        case (state)
            INIT_STATE: begin
                rf_we        <=  1'd0;
                if (step) begin
                    inst_reg <= dip_sw;
                    state    <= DECODE_STATE;
                end
            end

            DECODE_STATE: begin
                if (is_rtype) begin
                    rf_raddr_a <= rs1;
                    rf_raddr_b <= rs2;
                    rf_waddr <= rd;
                    state      <= CALC_STATE;
                end
                else if (is_peek) begin
                    rf_raddr_a <= rd;
                    state <= READ_REG_STATE;
                end
                else if (is_poke) begin
                    rf_waddr <= rd;
                    state <= WRITE_REG_STATE;
                end
                else begin
                    state <= INIT_STATE;  // unknown instruction
                end
            end

            CALC_STATE: begin
                alu_a <= rf_rdata_a;
                alu_b <= rf_rdata_b;
                alu_op <= opcode;
                state <= WRITE_REG_STATE;
            end

            WRITE_REG_STATE: begin
                rf_we <= 1'b1;
                if (is_rtype) begin
                    rf_wdata <= alu_y;  // `alu_y` has already been calculated, so no rw confict if at the same reg addr
                end
                else begin
                    rf_wdata <= imm;
                end
                state <= INIT_STATE;
            end

            READ_REG_STATE: begin
                leds  <= rf_rdata_a;
                state <= INIT_STATE;
            end

            default: begin
                state <= INIT_STATE;
            end
        endcase
    end
end

endmodule