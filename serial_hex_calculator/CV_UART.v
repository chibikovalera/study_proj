`timescale 1ns / 1ps

module CV_UART
(
	input RXD, 
    input CLK, 
    input RST,
    input wire [7:0] TX_DATA_R,
	input TX_RDY_T,
	
	output wire RX_DATA_EN, 
	output wire [9:0] RX_DATA_T,
	output TX_RDY_R,
	output TXD
);

wire RXD_RG;
wire UART_CE;
wire RXCT_R;
wire RX_CE;

CV_SYNCH synch
(
	.RXD(RXD),
	.CLK(CLK),
	.RST(RST),
	
	.RXD_RG(RXD_RG)
);

CV_DIVIDER divider
(
	.CLK(CLK),
	.RST(RST),
	
	.UART_CE(UART_CE)
);

RX_FSM rx_fsm
(
	.RXD_RG(RXD_RG),
	.CLK(CLK),
	.RST(RST),
	.RX_CE(RX_CE),
	
	.RXCT_R(RXCT_R),
	.RX_DATA_EN(RX_DATA_EN),
	.RX_DATA_T(RX_DATA_T)
);

RX_SAMPLE_COUNTER rx_samp_ct
(
	.UART_CE(UART_CE),
	.CLK(CLK),
	.RST(RST),
	.RXCT_R(RXCT_R),
	
	.RX_CE(RX_CE)
);

wire TX_CE;
wire TXCT_R;

TX_FSM tx_fsm
(
    .RST(RST),
    .CLK(CLK),
    .UART_CE(UART_CE),
    .TX_CE(TX_CE),
    .TX_RDY_T(TX_RDY_T),
    .TX_DATA_R(TX_DATA_R),
    
    .TXCT_R(TXCT_R),
    .TX_RDY_R(TX_RDY_R),
    .TXD(TXD)
);

TX_SAMPLE_COUNTER tx_samp_ct
(
    .RST(RST),
    .CLK(CLK),
    .UART_CE(UART_CE),
    .TXCT_R(TXCT_R),
    
    .TX_CE(TX_CE)
);

endmodule
