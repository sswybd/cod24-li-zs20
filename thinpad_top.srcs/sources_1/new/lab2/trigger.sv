module trigger(
    input wire clk,
    input wire reset,
    input wire push_btn,
    output wire trigger
);

logic push_btn_d0;

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        push_btn_d0 <= 1'd0;
    end
    else begin
        push_btn_d0 <= push_btn;
    end
end

assign trigger = (~push_btn_d0) & push_btn;

endmodule