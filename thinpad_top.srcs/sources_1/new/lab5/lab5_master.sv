module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter [ADDR_WIDTH-1:0] UART_STATE_ADDR = 'h10000005,
    parameter [ADDR_WIDTH-1:0] UART_DATA_ADDR = 'h10000000
) (
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] addr_i,  // from `dip_sw`

    // wishbone master
    output logic wb_cyc_o,
    output logic wb_stb_o,
    input wire wb_ack_i,
    output logic [ADDR_WIDTH-1:0] wb_adr_o,
    output wire [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output logic [DATA_WIDTH/8-1:0] wb_sel_o,
    output logic wb_we_o
);

localparam UART_DATA_WIDTH = 16;
localparam [UART_DATA_WIDTH-1:0] UART_READ_READY = 'h01_00;
localparam [UART_DATA_WIDTH-1:0] UART_WRITE_READY = 'h20_00;

localparam USEFUL_DATA_WIDTH = 8;  // for the experiment, we only need one byte

logic [USEFUL_DATA_WIDTH-1:0] dat_o;  // same as `wb_dat_o`, only the width is different
assign wb_dat_o = {{(DATA_WIDTH - USEFUL_DATA_WIDTH){1'b0}}, dat_o};

// similar to the previous paragraph
wire [UART_DATA_WIDTH-1:0] uart_state_dat_i;
wire [USEFUL_DATA_WIDTH-1:0] dat_i;
assign uart_state_dat_i = wb_dat_i[UART_DATA_WIDTH-1:0];
assign dat_i = wb_dat_i[USEFUL_DATA_WIDTH-1:0];

logic [ADDR_WIDTH-1:0] sram_addr_saved;
logic sram_addr_saved_flag;
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        sram_addr_saved <= '0;
        sram_addr_saved_flag <= 1'd0;
    end
    else begin
        sram_addr_saved_flag <= 1'd1;
        if (!sram_addr_saved_flag) begin
            sram_addr_saved <= addr_i;
        end
    end
end

typedef enum logic [3:0] { IDLE, RD_WAIT, RD_WAIT_CHK, RD_DATA, WR_SRAM, 
                           WR_SRAM_DONE, WR_WAIT, WR_WAIT_CHK, WR_DATA, ERROR } state_t;

state_t this_state, next_state;

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        this_state <= IDLE;
    end
    else begin
        this_state <= next_state;
    end
end

logic [UART_DATA_WIDTH-1:0] uart_state_dat_reg;  // stores the data that reflects whether uart is ready
logic [USEFUL_DATA_WIDTH-1:0] dat_reg;  // stores the real data from the uart
logic [ADDR_WIDTH-1:0] wr_cnt;  // Related to sram addr calculation. It counts the rounds handled.
// `wr_cnt` can count up to 2^32 uart inputs. (Only for easy calculation of the sram addr did I 
// choose 32-bit width, so that I didn't need to consider width discrepancy/disparity during calculation.)

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        uart_state_dat_reg <= 'd0;
        dat_reg <= 'd0;
        wr_cnt <= 5'd0;
        dat_o <= 'd0;
        wb_we_o <= 1'd0;
        wb_sel_o <= 4'b0000;
        wb_adr_o <= 'd0;
        wb_cyc_o <= 1'd0;
        wb_stb_o <= 1'd0;
    end
    else begin
        case (this_state)
            IDLE: begin
                wb_sel_o <= 4'b0010;
                wb_adr_o <= UART_STATE_ADDR;
                wb_cyc_o <= 1'd1;
                wb_stb_o <= 1'd1;
            end
            RD_WAIT: begin
                if (wb_ack_i) begin
                    uart_state_dat_reg <= uart_state_dat_i;
                    wb_cyc_o <= 1'd0;
                    wb_stb_o <= 1'd0;
                end
            end
            RD_WAIT_CHK: begin
                if (uart_state_dat_reg[8]) begin
                    wb_sel_o <= 4'b0001;
                    wb_adr_o <= UART_DATA_ADDR;
                end
                else begin
                    wb_sel_o <= 4'b0010;
                    wb_adr_o <= UART_STATE_ADDR;
                end
                wb_cyc_o <= 1'd1;
                wb_stb_o <= 1'd1;
            end
            RD_DATA: begin
                if (wb_ack_i) begin
                    dat_reg <= dat_i;
                    wb_cyc_o <= 1'd0;
                    wb_stb_o <= 1'd0;
                end
            end
            WR_SRAM: begin
                dat_o <= dat_reg;
                if (!wb_ack_i) begin
                    wb_we_o <= 1'd1;
                    wb_cyc_o <= 1'd1;
                    wb_stb_o <= 1'd1;
                end
                else begin
                    wb_we_o <= 1'd0;  // restore we to 0
                    wb_cyc_o <= 1'd0;
                    wb_stb_o <= 1'd0;
                end
                wb_sel_o <= 4'b0001;
                wb_adr_o <= sram_addr_saved + wr_cnt << 2;  // + wr_cnt * 4
            end
            WR_SRAM_DONE: begin
                wr_cnt <= wr_cnt + 5'd1;
                wb_sel_o <= 4'b0010;
                wb_adr_o <= UART_STATE_ADDR;
                wb_cyc_o <= 1'd1;
                wb_stb_o <= 1'd1;
            end
            WR_WAIT: begin
                if (wb_ack_i) begin
                    uart_state_dat_reg <= uart_state_dat_i;
                    wb_cyc_o <= 1'd0;
                    wb_stb_o <= 1'd0;
                end
            end
            WR_WAIT_CHK: begin
                if (uart_state_dat_reg[13]) begin
                    dat_o <= dat_reg;
                    wb_we_o <= 1'd1;
                    wb_sel_o <= 4'b0001;
                    wb_adr_o <= UART_DATA_ADDR;
                end
                else begin
                    wb_sel_o <= 4'b0010;
                    wb_adr_o <= UART_STATE_ADDR;
                end
                wb_cyc_o <= 1'd1;
                wb_stb_o <= 1'd1;
            end
            WR_DATA: begin
                if (wb_ack_i) begin
                    wb_we_o <= 1'd0;
                    wb_cyc_o <= 1'd0;
                    wb_stb_o <= 1'd0;
                end
            end
            ERROR: begin end
            default: begin end
        endcase
    end
end

always_comb begin
    next_state = IDLE;
    case (this_state)
        IDLE: begin
            if (rst_i == 1'd0) begin
                next_state = RD_WAIT;
            end
            else begin
                next_state = IDLE;
            end
        end
        RD_WAIT: begin
            if (wb_ack_i) begin
                next_state = RD_WAIT_CHK;
            end
            else begin
                next_state = RD_WAIT;
            end
        end
        RD_WAIT_CHK: begin
            if (uart_state_dat_reg[8]) begin
                next_state = RD_DATA;
            end
            else begin
                next_state = RD_WAIT;
            end
        end
        RD_DATA: begin
            if (wb_ack_i) begin
                next_state = WR_SRAM;
            end
            else begin
                next_state = RD_DATA;
            end
        end
        WR_SRAM: begin
            if (wb_ack_i) begin
                next_state = WR_SRAM_DONE;
            end
            else begin
                next_state = WR_SRAM;
            end
        end
        WR_SRAM_DONE: begin
            next_state = WR_WAIT;
        end
        WR_WAIT: begin
            if (wb_ack_i) begin
                next_state = WR_WAIT_CHK;
            end
            else begin
                next_state = WR_WAIT;
            end
        end
        WR_WAIT_CHK: begin
            if (uart_state_dat_reg[13]) begin
                next_state = WR_DATA;
            end
            else begin
                next_state = WR_WAIT;
            end            
        end
        WR_DATA: begin
            if (wb_ack_i) begin
                next_state = IDLE;
            end
            else begin
                next_state = WR_DATA;
            end
        end
        ERROR: begin
            next_state = ERROR;
        end
        default: begin
            next_state = ERROR;  // maybe forget to handle a certain state in the code
        end
    endcase
end

endmodule
