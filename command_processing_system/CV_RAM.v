`timescale 1ns / 1ps

module CV_RAM #(parameter AW = 5)
(
    input CLK,
    
    input S_EX_REQ,
    input [AW - 1:0] S_ADDR,
    input [2:0] S_CMD,
    input [7:0] S_D_WR,
    output S_EX_ACK,
    output [7:0] S_D_RD,
    
    input [AW - 1:0] ADDR,
    output [7:0] DATA
);

assign S_EX_ACK = 1;

reg [7:0] ROM0 [0:2**AW - 1];

assign DATA = ROM0[ADDR];
assign S_D_RD = ROM0[S_ADDR];

always@(posedge CLK) begin
    if(S_CMD[2:0]==1 & S_EX_REQ) begin
        ROM0[S_ADDR] <= S_D_WR;
    end
end

endmodule
