`timescale 1ns / 1ps

module CV_INFS_40B
(
    input T_S_EX_REQ,
          wire [39:0] T_S_ADDR,
          wire [2:0] T_S_CMD,
          wire [7:0] T_S_D_WR,
          
    output T_S_EX_ACK,
           wire [7:0] T_S_D_RD,
           
    //initiator-1
    output I1_S_EX_REQ,
           I1_S_ADDR,
           wire [2:0] I1_S_CMD,
           wire [7:0] I1_S_D_WR,
          
    input I1_S_EX_ACK,
          wire [7:0] I1_S_D_RD,
           
    //initiator-2
    output I2_S_EX_REQ,
           wire [4:0] I2_S_ADDR,
           wire [2:0] I2_S_CMD,
           wire [7:0] I2_S_D_WR,
          
    input I2_S_EX_ACK,
          wire [7:0] I2_S_D_RD                             
);

reg [1:0] EN = 0;

//0010111101110101001110011001100011101110 LED
//1001101101111101000110101100010111100000 RAM

always@(*)
begin
    casex({T_S_CMD, T_S_ADDR})
        43'bx00001011110111010100111001100110001110111x: EN = 2'b01;
        43'bx0110011011011111010001101011000101111xxxxx: EN = 2'b10;
        default: EN = 2'b00;
    endcase
end

assign I1_S_EX_REQ = EN[0] & T_S_EX_REQ;
assign I2_S_EX_REQ = EN[1] & T_S_EX_REQ;

assign I1_S_ADDR = T_S_ADDR[0];
assign I2_S_ADDR = T_S_ADDR[4:0];

assign I1_S_CMD = T_S_CMD;
assign I2_S_CMD = T_S_CMD;

assign I1_S_D_WR = T_S_D_WR;
assign I2_S_D_WR = T_S_D_WR;

assign T_S_EX_ACK = (I1_S_EX_ACK | ~EN[0]) & (I2_S_EX_ACK | ~EN[1]);

assign T_S_D_RD = (I1_S_D_RD | ~{8{EN[0]}}) & (I2_S_D_RD | ~{8{EN[1]}});

endmodule
