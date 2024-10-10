module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
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
localparam UART_READ_READY = (UART_DATA_WIDTH)'h01_00;
localparam UART_WRITE_READY = (UART_DATA_WIDTH)'h20_00;

localparam USEFUL_DATA_WIDTH = 8;  // for the experiment, we only need one byte

logic [USEFUL_DATA_WIDTH-1:0] dat_o;  // same as `wb_dat_o`, only the width is different
assign wb_dat_o = {(DATA_WIDTH-USEFUL_DATA_WIDTH){1'b0}, dat_o};

// similar to the previous paragraph
wire [UART_DATA_WIDTH-1:0] uart_state_dat_i;
wire [USEFUL_DATA_WIDTH-1:0] dat_i;
assign uart_state_dat_i = wb_dat_i[UART_DATA_WIDTH-1:0];
assign dat_i = wb_dat_i[USEFUL_DATA_WIDTH-1:0];

wire wb_valid;  // internal signal for convenience
assign wb_valid = wb_cyc_o & wb_stb_o;

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

logic [UART_DATA_WIDTH-1:0] check_data_reg;  // stores the data that reflects whether uart is ready
logic [USEFUL_DATA_WIDTH-1:0] data_reg;  // stores the real data from the uart

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        check_data_reg <= 'd0;
        data_reg <= 'd0;
    end
    else begin
        case (this_state)
            IDLE: begin

            end
            RD_WAIT: begin
                if (wb_valid && wb_ack_i) begin
                    check_data_reg <= uart_state_dat_i;
                end
            end
            RD_WAIT_CHK: begin

            end
            RD_DATA: begin

            end
            WR_SRAM: begin

            end
            WR_SRAM_DONE: begin

            end
            WR_WAIT: begin
                
            end
            WR_WAIT_CHK: begin

            end
            WR_DATA: begin

            end
            ERROR: begin
                
            end
            default: begin
                
            end
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
            if (wb_ack_i && wb_valid) begin
                next_state = RD_WAIT_CHK;
            end
            else if (wb_valid) begin
                next_state = RD_WAIT;
            end
            else begin
                next_state = ERROR;
            end
        end
        RD_WAIT_CHK: begin
            if (check_data_reg == UART_READ_READY) begin
                next_state = RD_DATA
            end
            else begin
                next_state = RD_WAIT;
            end
        end
        RD_DATA: begin

        end
        WR_SRAM: begin

        end
        WR_SRAM_DONE: begin

        end
        WR_WAIT: begin
            if (wb_ack_i && wb_valid) begin
                next_state = WR_WAIT_CHK;
            end
            else if (wb_valid) begin
                next_state = WR_WAIT;
            end
            else begin
                next_state = ERROR;
            end
        end
        WR_WAIT_CHK: begin

        end
        WR_DATA: begin

        end
        ERROR: begin
            next_state = ERROR;
        end
        default: begin
            next_state = ERROR;
        end
    endcase
end


endmodule
