module ID_to_EXE_regs #(

) (
    input wire sys_clk,
    input wire sys_rst,
    input wire wr_en,
    input wire ,
    input wire ,
    input wire ,
    input wire ,
    input wire ,
    input wire ,
    input wire ,
    input wire ,
    input wire ,
    output logic ,
    output logic ,
    output logic ,
    output logic ,
    output logic ,
    output logic ,
    output logic ,
    output logic ,
);

always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
         <= ;
    end
    else if (wr_en) begin
         <= ;
    end
end





endmodule