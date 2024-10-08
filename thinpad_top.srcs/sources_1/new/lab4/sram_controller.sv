module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)  
    // `clog2(N)` returns the necessary number of bits to index N items with a binary integer.
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output logic wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output wire [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output wire [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,  // tri-state
    output wire sram_ce_n,
    output wire sram_oe_n,
    output logic sram_we_n,
    output wire [SRAM_BYTES-1:0] sram_be_n
);

assign sram_addr = wb_adr_i >> SRAM_BYTE_WIDTH;  // divided by 4, right shift 2
assign sram_be_n = ~wb_sel_i;
// The case like accessing 0x5's four bytes is not handled yet, but I don't think this handling is needed.
// But accessing 0x5's one byte is handled correctly, because `wb_sel_i` is correctly set as 4'b0010.

assign sram_oe_n = wb_we_i;

wire sram_ce_i;  // internal signal for convenience
assign sram_ce_i = wb_cyc_i & wb_stb_i;

assign sram_ce_n = ~sram_ce_i;

typedef enum logic [1:0] { START, RD2, WR2, WR3 } state_t;

state_t this_state, next_state;

always_comb begin
    next_state = START;
    case (this_state)
        START: begin
            if (sram_ce_i) begin
                if (wb_we_i) begin
                    next_state = WR2;
                end
                else begin
                    next_state = RD2;
                end
            end
            else begin
                next_state = START;
            end
        end
        RD2: begin
            next_state = START;
        end
        WR2: begin
            next_state = WR3;
        end
        WR3: begin
            next_state = START;
        end
        default: begin
            next_state = START;
        end
    endcase
end

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        this_state <= START;
    end
    else begin
        this_state <= next_state;
    end
end

wire sram_data_en_n;  // 1 for z value on sram_data wire
wire [SRAM_DATA_WIDTH-1:0] sram_data_i;
wire [SRAM_DATA_WIDTH-1:0] sram_data_o;
assign sram_data = sram_data_en_n ? 'z : sram_data_o;
assign sram_data_i = sram_data;

assign sram_data_en_n = ~(sram_ce_i & wb_we_i);
assign sram_data_o = wb_dat_i;
assign wb_dat_o = sram_data_i;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        sram_we_n <= 1'd1;
        wb_ack_o <= 1'd0;
    end
    else begin
        case (this_state)
            START: begin
                if (sram_ce_i) begin
                    if (wb_we_i) begin  // write
                        sram_we_n <= 1'd0;
                    end
                    else begin  // read
                        sram_we_n <= 1'd1;
                        wb_ack_o <= 1'd1;
                    end
                end
            end
            RD2: begin
                wb_ack_o <= 1'd0;
            end
            WR2: begin
                sram_we_n <= 1'd1;
                wb_ack_o <= 1'd1;
            end
            WR3: begin
                wb_ack_o <= 1'd0;
            end
            default: begin
                sram_we_n <= 1'd1;
                wb_ack_o <= 1'd0;
            end            
        endcase
    end
end

endmodule
