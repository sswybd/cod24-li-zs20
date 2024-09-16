module counter(
    input wire clk,
    input wire reset,
    input wire trigger,
    output logic [3:0] count
);

parameter STOP_COUNT = 4'hF;  // == 15

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        count <= 4'd0;
    end
    else if (trigger && count < STOP_COUNT) begin
        count <= count + 4'd1;
    end
end

endmodule