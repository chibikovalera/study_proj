`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////////////////////

module CV_LR5_TOP
(
    input CLK,
    input SYS_NRST,
    input UART_RXD,
    
    output wire UART_TXD,
    output [7:0] LED
);

wire [130:0] CMD_DATA_T; 
wire CMD_RDY_T;
wire CMD_RDY_R;
wire [80:0] RES_DATA_R;
wire RES_RDY_T;
wire RES_RDY_R;

wire RST;
wire CE_1KHz;

wire TX_RDY_T;
wire TX_RDY_R;
wire [7:0] TX_DATA_R;

wire [9:0]RX_DATA_T;
wire RX_DATA_EN;

wire [3:0] DC_HEX_DATA;
wire [3:0] HEX_DATA;
wire HEX_FLG;

wire [7:0] DC_ASCII_DATA;
wire [7:0] ASCII_DATA;

wire [6:0] ADDR;
wire [7:0] DATA; 


wire S_EX_REQ;
wire [7:0] S_D_RD;
wire [39:0] S_ADDR;
wire [2:0] S_CMD;
wire [7:0] S_D_WR;


wire I2_S_EX_REQ;
wire I1_S_EX_REQ;
wire I1_S_ADDR;
wire [2:0] I1_S_CMD;
wire [7:0] I1_S_D_WR;
wire I1_S_EX_ACK;
wire [7:0] I1_S_D_RD;


wire [4:0] I2_S_ADDR;
wire [2:0] I2_S_CMD;
wire [7:0] I2_S_D_WR;
wire I2_S_EX_ACK;
wire [7:0] I2_S_D_RD;

/////////////////////////////////////////////////////////////////////////////////////////////////////

//Синхронизатор сброса
reg [1:0] SYNC_RST;
always@(posedge CLK, negedge SYS_NRST)
begin
    if(!SYS_NRST) SYNC_RST <= 2'b11;
    else SYNC_RST          <= {SYNC_RST[0], 1'b0};
end

assign RST = SYNC_RST[1];

///////////////////////////////////////////////////////////////////////////////////////////////////////

//Контроллер UART
CV_UART uart
(
    .RXD(UART_RXD),
    .CLK(CLK),
    .RST(RST),
    .TX_DATA_R(TX_DATA_R),
    .TX_RDY_T(TX_RDY_T),
    
    .RX_DATA_EN(RX_DATA_EN),
    .RX_DATA_T(RX_DATA_T),
    .TX_RDY_R(TX_RDY_R),
    .TXD(UART_TXD)
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Дешифратор ASCII->HEX
CV_DC_ASCII_HEX dc_ascii_hex
(
    .ASCII(ASCII_DATA),
    
    .HEX(DC_HEX_DATA),
    .HEX_FLG(HEX_FLG)
);

//Дешифратор HEX->ASCII
CV_DC_HEX_ASCII dc_hex_ascii
(
    .HEX(HEX_DATA),
    
    .ASCII(DC_ASCII_DATA)
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Анализатор
CV_ANALYZER analyzer
(
    .CLK(CLK),
    .RST(RST),
    .RX_DATA_EN(RX_DATA_EN),
    .RX_DATA_R(RX_DATA_T[7:0]),
    
    .HEX_FLG(HEX_FLG),
    .DC_ASCII_HEX(DC_HEX_DATA),
    .CMD_RDY_R(CMD_RDY_R),
    
    .ASCII_DATA(ASCII_DATA),
    .CMD_DATA_T(CMD_DATA_T),
    .CMD_RDY_T(CMD_RDY_T)    
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Обработчик команд
CV_HANDLER_CMD handler
(
    .CLK(CLK),
    .RST(RST),
    .CMD_RDY_T(CMD_RDY_T),
    .CMD_DATA_T(CMD_DATA_T),
    .RES_RDY_R(RES_RDY_R),
    .S_EX_ACK(S_EX_ACK),
    .S_D_RD(S_D_RD),


    .CMD_RDY_R(CMD_RDY_R),
    .RES_RDY_T(RES_RDY_T),
    .RES_DATA_T(RES_DATA_R),
    .S_EX_REQ(S_EX_REQ),
    .S_ADDR(S_ADDR), 
    .S_CMD(S_CMD), 
    .S_D_WR(S_D_WR) 
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Генератор сообщений
CV_GEN_MSG gen_msg 
(
    .CLK(CLK),
    .RST(RST),

    .TX_RDY_R(TX_RDY_R),
    .TX_RDY_T(TX_RDY_T),
    .TX_DATA_T(TX_DATA_R),

    .RES_RDY_T(RES_RDY_T),
    .RES_DATA_R (RES_DATA_R),
    .RES_RDY_R(RES_RDY_R),

    .DC_ASCII_DATA(DC_ASCII_DATA),
    .HEX_DATA(HEX_DATA),

    .ADDR(ADDR),
    .DATA(DATA)
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Системная шина
CV_INFS_40B inf
(
    .T_S_EX_REQ(S_EX_REQ),
    .T_S_ADDR(S_ADDR),
    .T_S_CMD(S_CMD),
    .T_S_D_WR(S_D_WR),
    .T_S_EX_ACK(S_EX_ACK),
    .T_S_D_RD(S_D_RD),

    .I1_S_EX_ACK(I1_S_EX_ACK),
    .I1_S_D_RD(I1_S_D_RD),
    .I1_S_EX_REQ(I1_S_EX_REQ),
    .I1_S_ADDR(I1_S_ADDR),
    .I1_S_CMD(I1_S_CMD),
    .I1_S_D_WR(I1_S_D_WR),

    .I2_S_EX_REQ(I2_S_EX_REQ),
    .I2_S_ADDR(I2_S_ADDR),
    .I2_S_CMD(I2_S_CMD),
    .I2_S_D_WR(I2_S_D_WR),


    .I2_S_EX_ACK(I2_S_EX_ACK),
    .I2_S_D_RD(I2_S_D_RD)
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [7:0] DATA_1;
wire [4:0] ADDR_1;

//RAM
CV_RAM ram 
(
    .CLK(CLK),

    .S_EX_REQ(I2_S_EX_REQ),
    .S_ADDR(I2_S_ADDR),
    .S_CMD(I2_S_CMD),
    .S_D_WR(I2_S_D_WR),

    .S_EX_ACK(I2_S_EX_ACK),
    .S_D_RD(I2_S_D_RD),

    .ADDR(ADDR_1),
    .DATA(DATA_1)
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Контроллер LED
CV_CNTRL_LEDS led 
( 
    .CLK(CLK),
    .RST(RST),

    .S_EX_REQ(I1_S_EX_REQ),
    .S_ADDR(I1_S_ADDR),
    .S_CMD(I1_S_CMD),
    .S_D_WR(I1_S_D_WR),

    .S_EX_ACK(I1_S_EX_ACK),
    .S_D_RD(I1_S_D_RD),

    .LED(LED),
    
    .DATA(DATA_1),
    .ADDR(ADDR_1)
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ОЗУ
CV_ROM rom
(
    .ADDR(ADDR),
    
    .DATA(DATA)
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
