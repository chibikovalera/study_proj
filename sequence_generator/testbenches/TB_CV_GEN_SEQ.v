module TB_CV_GEN_SEQ;
  
reg CLK;
reg RST;
reg STEP;
reg LOAD;
reg UP;
reg [3:0] DAT_I;
wire [3:0] NOM;
wire [3:0] SEQ;
always #5 CLK = ~CLK;
always #5 STEP = ~STEP;

CV_GEN_SEQ uut 
(
  .CLK(CLK),
  .RST(RST),
  .STEP(STEP),
  .LOAD(LOAD),
  .UP(UP),
  .DAT_I(DAT_I),
  .SEQ(SEQ),
  .NOM(NOM)
);
  
initial
begin
  CLK = 0;
  RST = 0;
  STEP = 0;
  LOAD = 0;
  UP = 0;
  DAT_I = 0;
  #30;
  //Полный цикл прямой генерации
  LOAD = 1;
  UP = 1;
  #10
  LOAD = 0;
  //Полный цикл обратной генерации
  #200
  UP = 0;
  #200
  //Сброс
  RST = 1;
  #5;
  RST = 0;
  //Загрузка значения
  UP = 1;
  DAT_I = 4'h9;
  LOAD = 1;
  #10;
  LOAD = 0;
end
  
endmodule
