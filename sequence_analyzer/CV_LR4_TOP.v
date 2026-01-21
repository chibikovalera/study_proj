module CV_LR4_TOP
(
	input SW_3, SW_2, SW_1, SW_0,
		    BTN_0,
		    CLK_48,
		    SYS_NRST,
	output reg N_ST,
	output wire [7:0] AN,
	output wire [7:0] CAT,
	output wire LED_F, LED_E, LED_D, LED_C, LED_B, LED_A, LED_9, LED_8, LED_7, LED_6, LED_5, LED_4, LED_3, LED_2, LED_1, LED_0
);

wire CEO_1KHz;
wire RST;

wire FSM_CE;

wire [15:0] NOM;
reg [31:0] SREG;

//Фильтр дребезга контактов
CV_BTN_FLTR #(4) fltr 
(
	.BTN_IN(BTN_0),
	.CE(CEO_1KHz),
	.CLK(CLK_48),
	.RST(RST),
	
	.BTN_OUT(),
	.BTN_CEO(FSM_CE)
);

//Делитель частоты
CV_DIVIDER # (.CNT_WDT(16), .DIV_VAL(48000)) dvdr
(
	.CLK(CLK_48),
	.RST(RST),
	
	.CEO(CEO_1KHz)
);
//Анализатор последовательности
CV_ANL_SEQ anlseq
(
	.DAT_I({SW_3, SW_2, SW_1, SW_0}),
	.CE(FSM_CE),
	.CLK(CLK_48),
	.RST(RST),
	.NOM(NOM)
);

//Динамический индикатор
CV_7SEGx8 semseg
(
	.HEX_IN(SREG),
	.BLANK(~NOM[7:0]),
	.DP_IN(8'h0),
	.CE(CEO_1KHz),
	.CLK(CLK_48),
	.RST(RST),
	
	.AN(AN),
	.CAT(CAT)
);
  
//Синхронизатор сброса
reg [1:0] SYNC_RST;
always@(posedge CLK_48, negedge SYS_NRST)
begin
	if(!SYS_NRST) SYNC_RST <= 2'b11;
	else SYNC_RST <= {SYNC_RST[0], 1'b0};
end
assign RST = SYNC_RST[1];

//Сброс Watch-Dog
always@(posedge CLK_48, posedge RST)
begin
	if(RST) N_ST <= 0;
	else if(CEO_1KHz) N_ST <= ~N_ST;
end

// Сдвиговый регистр
always@(posedge CLK_48, posedge RST) 
begin
	if (RST) SREG <= 32'h00000000;
	else if (FSM_CE) 
	begin
		SREG[3:0] <= {SW_3, SW_2, SW_1, SW_0};
		SREG[31:4] <= SREG[27:0];
	end
end

assign LED_F = ~NOM[15];
assign LED_E = ~NOM[14];
assign LED_D = ~NOM[13];
assign LED_C = ~NOM[12];
assign LED_B = ~NOM[11];
assign LED_A = ~NOM[10];
assign LED_9 = ~NOM[9];
assign LED_8 = ~NOM[8];
assign LED_7 = ~NOM[7];
assign LED_6 = ~NOM[6];
assign LED_5 = ~NOM[5];
assign LED_4 = ~NOM[4];
assign LED_3 = ~NOM[3];
assign LED_2 = ~NOM[2];
assign LED_1 = ~NOM[1];
assign LED_0 = ~NOM[0];

endmodule
