module CV_LR3_TOP
(
  input SW_3, SW_2, SW_1, SW_0,
        SW_4,
        BTN_0, BTN_1,
        CLK_48,
        SYS_NRST,

  output reg N_ST,
  output wire [7:0] AN,
  output wire [7:0] CAT,
  output LED_7, LED_6, LED_5, LED_4, LED_3, LED_2, LED_1, LED_0
);
  
wire CEO_1KHz;
wire RST;
  
wire LOAD;
wire STEP;
  
wire [3:0] NOM;
wire [3:0] SEQ;
  
wire [31:0] HEX_IN;
wire [7:0] BLANK;

//Фильтры дребезга контактов
CV_BTN_FLTR # (4) fltr1
(
  .BTN_IN(BTN_0),
  .CE(CEO_1KHz),
  .CLK(CLK_48),
  .RST(RST),
  .BTN_OUT(),
  .BTN_CEO(LOAD)
);

CV_BTN_FLTR # (4) fltr2
(
  .BTN_IN(BTN_1),
  .CE(CEO_1KHz),
  .CLK(CLK_48),
  .RST(RST),
  .BTN_OUT(),
  .BTN_CEO(STEP)
);

//Делитель частоты
CV_DIVIDER # (.CNT_WDT(16), .DIV_VAL(48000)) dvdr
(
  .CLK(CLK_48),
  .RST(RST),
  .CEO(CEO_1KHz)
);

//Генератор последовательности
CV_GEN_SEQ genseq
(
  .DATA_I({SW_3, SW_2, SW_1, SW_0}),
  .UP(SW_4),
  .LOAD(LOAD),
  .STEP(STEP),
  .CLK(CLK_48),
  .RST(RST),
  .NOM(NOM),
  .SEQ(SEQ)
);

//Динамический индикатор
CV_7SEGx8 semseg
(
  .HEX_IN(HEX_IN),
  .BLANK(BLANK),
  .DP_IN(8'h00),
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

//Регистр, где BLANK формируется
reg [7:1] registr1;
always@(posedge CLK_48, posedge RST)
begin
  if (RST) registr1 <= 7'b1111111;
  else if (LOAD | STEP) registr1 <= {registr1[6:1], 1'b0};
end

assign BLANK = {registr1, 1'b0};

// Сдвиговый регистр
reg [31:4] registr2;
always@(posedge CLK_48, posedge RST)
begin
  if (RST) registr2 <= 28'h0000000;
  else if (LOAD | STEP) registr2 <= {registr2[27:4], SEQ};
end

assign HEX_IN = {registr2, SEQ};
assign LED_7 = ~SEQ[3];
assign LED_6 = ~SEQ[2];
assign LED_5 = ~SEQ[1];
assign LED_4 = ~SEQ[0];
assign LED_3 = ~NOM[3];
assign LED_2 = ~NOM[2];
assign LED_1 = ~NOM[1];
assign LED_0 = ~NOM[0];
  
endmodule
