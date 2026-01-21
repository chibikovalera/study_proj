`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////////////////////


module CV_PR1_TOP
(
    input CLK_48,
    input SYS_NRST,
    input BTN_0,
    input BTN_1,
    input UART_RXD,
    
    output wire UART_TXD      
);

wire RST;
wire CE_1KHz;
wire GEN_FRT_ERR;
wire GEN_PAR_ERR;
wire TX_RDY_T;
wire [9:0]RX_DATA_T;
wire [7:0] TX_DATA_R;
wire TX_RDY_R;
wire RX_DATA_EN;
wire [9:0] DATA_1;
wire HEX_FLG;
wire [3:0] DC_HEX_DATA;
wire [7:0] DC_ASCII_DATA;
wire [3:0] HEX_DATA;
wire [7:0] ASCII_DATA;
wire [6:0] ADDR;
wire [7:0] DATA; 

/////////////////////////////////////////////////////////////////////////////////////////////////////

//Синхронизатор сброса
reg [1:0] SYNC_RST;
always@(posedge CLK_48, negedge SYS_NRST)
begin
    if(!SYS_NRST) SYNC_RST <= 2'b11;
    else SYNC_RST          <= {SYNC_RST[0], 1'b0};
end

assign RST = SYNC_RST[1];

//////////////////////////////////////////////////////////////////////////////////////////////////////

//Делитель частоты
CV_DIVIDER # (8, 3) divider
(
    .CLK(CLK_48),
    .RST(RST),
    
    .UART_CE(CE_1KHz)
);

///////////////////////////////////////////////////////////////////////////////////////////////////////

//Фильтр дребезга ошибка формата 
CV_BTN_FLTR btn_fltr1
(
    .BTN_IN(BTN_0),
    .CLK(CLK_48),
    .CE(CE_1KHz),
    .RST(RST),
    
    .BTN_OUT(GEN_FRT_ERR)
);
//Фильтр дребезга ошибка четности
CV_BTN_FLTR btn_fltr2
(
    .BTN_IN(BTN_1),
    .CLK(CLK_48),
    .CE(CE_1KHz),
    .RST(RST),
    
    .BTN_OUT(GEN_PAR_ERR)
);

//////////////////////////////////////////////////////////////////////////////////////////////////////////

//Контроллер UART
CV_UART uart
(
    .RXD(UART_RXD),
    .CLK(CLK_48),
    .RST(RST),
    .TX_DATA_R(TX_DATA_R),
    .TX_RDY_T(TX_RDY_T),
    
    .RX_DATA_EN(RX_DATA_EN),
    .RX_DATA_T(RX_DATA_T),
    .TX_RDY_R(TX_RDY_R),
    .TXD(UART_TXD)
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////

//КС генерации ошибок
assign DATA_1[7:0] = RX_DATA_T[7:0];
assign DATA_1[8] = RX_DATA_T[8] ^ GEN_PAR_ERR;
assign DATA_1[9] = RX_DATA_T[9] ^ GEN_FRT_ERR;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
//Конечный автомат
CV_FSM fsm
(
    .CLK(CLK_48),
    .RST(RST),
    .RX_DATA_EN(RX_DATA_EN),
    .RX_DATA_R(DATA_1),
    .TX_RDY_R(TX_RDY_R),
    .HEX_FLG(HEX_FLG),
    .DC_HEX_DATA(DC_HEX_DATA),
    .DC_ASCII_DATA(DC_ASCII_DATA),
    .DATA(DATA),
    
    .TX_RDY_T(TX_RDY_T),
    .TX_DATA_T(TX_DATA_R),
    .ASCII_DATA(ASCII_DATA),
    .HEX_DATA(HEX_DATA),
    .ADDR(ADDR)
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

//ОЗУ
CV_ROM rom
(
    .ADDR(ADDR),
    
    .DATA(DATA)
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
