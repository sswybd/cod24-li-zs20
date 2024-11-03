module link_mux #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input wire [ADDR_WIDTH-1:0] link_addr_i,
    input wire [DATA_WIDTH-1:0] alu_result_i,
    input wire is_uncond_jmp_ctrl_i,
    output wire [DATA_WIDTH-1:0] final_result_o
);

assign final_result_o = is_uncond_jmp_ctrl_i ? link_addr_i : alu_result_i;

endmodule