`timescale 1ns / 1ps

module CV_CNTRL_LEDS 
(
    input CLK,
    input RST,
    input S_EX_REQ,
    input S_ADDR,
    input [2:0] S_CMD,
    input [7:0] S_D_WR,
    
    output S_EX_ACK,
    output reg [7:0] S_D_RD,
    output [7:0] LED,
    
    input [7:0] DATA,
    output reg [4:0] ADDR
);

reg [7:0] MASK;

always @*
begin
    if (S_ADDR)
        S_D_RD <= {3'b000, ADDR};
    else
        S_D_RD <= MASK;
end

always @(posedge CLK, posedge RST) begin
    if (RST) begin
        ADDR <= 5'b0000;
    end else if (S_EX_REQ & ~S_CMD[2] & S_ADDR) begin
        ADDR <= S_D_WR[4:0];
    end
end

always @(posedge CLK, posedge RST) begin
    if (RST) begin
        MASK <= 8'h00;
    end else if (S_EX_REQ & ~S_CMD[2] & ~S_ADDR) begin
        MASK <= S_D_WR;
    end
end

assign S_EX_ACK = 1'b1;
assign LED = DATA & MASK;

endmodule
