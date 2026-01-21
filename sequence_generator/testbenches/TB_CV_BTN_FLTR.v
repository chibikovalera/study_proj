module TB_CV_BTN_FLTR;

reg CLK;
localparam PERIOD_CLK = 20.8;
localparam DUTY_CYCLE_CLK = 0.4;

always
begin
  CLK = 0;
  #(PERIOD_CLK * (1 - DUTY_CYCLE_CLK));
  CLK = 1;
  #(PERIOD_CLK * DUTY_CYCLE_CLK);
end
  
reg RST;

initial
begin
  RST = 1;
  #100;
  @(posedge CLK);
  #(PERIOD_CLK*0.2); // реализация задержек реального физического сигнала
  RST = 0;  
end
  
reg btn = 0;
reg [10:0] range = 50;
reg [10:0] waitfor = 600;
  
initial 
begin
  repeat (range)
  begin
  btn = $random;
  #1;
  end
  btn = 1;
  #waitfor;
  repeat (range)
  begin
    btn = $random;
    #1;
  end
  btn = 0;
  #waitfor;
  repeat (range)
  begin
    btn = $random;
    #1;
  end
  btn = 1;
  #waitfor;
  repeat (range)
  begin
    btn = $random;
    #1;
  end
  btn = 0;
  #waitfor;
  $finish;
end
  
wire btn_out;
wire btn_ceo;

CV_BTN_FLTR fltr1
(
  .BTN_IN(btn),
  .RST(RST),
  .CLK(CLK),
  .CE(1'b1),
  .BTN_OUT(btn_out),
  .BTN_CEO(btn_ceo)
);
  
endmodule
