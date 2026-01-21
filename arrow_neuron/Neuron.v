module Neuron #
(
    parameter [255:0] k = 256'b0,
    parameter signed [15:0] b = 8'd0 
)(
    input clk,
    input  [255:0] x,
    output reg out
);

integer i;
reg signed [15:0] sum;

always @(*) begin
    sum = 0;
    for (i = 0; i < 256; i = i + 1) begin
        if (k[i])
            sum = sum + (x[i] ? 16'sd1 : -16'sd1);
    end
end

always @(posedge clk) out <= (sum >= b);

endmodule
