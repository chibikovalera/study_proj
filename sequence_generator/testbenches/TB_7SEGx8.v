module TB_7SEGx8();
  
reg CLK, RST, CE;
reg[31:0]HEX_IN;
reg[7:0]DP_IN;
wire[7:0]AN;
wire[7:0]CAT;
  
//blank
wire [7:0] BLANK;
reg [7:1] registr1;
  
always@(posedge CLK, posedge RST)
begin
  if (RST) registr1 <= 7'b1111111;
  else if (CE) registr1 <= {registr1[6:1], 1'b0};
end
assign BLANK = {registr1, 1'b0};

CV_7SEGx8 uut1
(
  .CLK(CLK),
  .RST(RST),
  .CE(CE),
  .HEX_IN(HEX_IN),
  .DP_IN(DP_IN),
  .BLANK(BLANK),
  .AN(AN),
  .CAT(CAT)
);
  
localparam PERIOD_CLK = 20.8;
localparam DUTY_CYCLE_CLK = 0.4;
  
always
begin
  CLK = 0;
  #(PERIOD_CLK * (1 - DUTY_CYCLE_CLK));
  CLK = 1;
  #(PERIOD_CLK * DUTY_CYCLE_CLK);
end
  
initial
begin
  RST = 1;
  CE = 1;
  HEX_IN = 32'h9C32A792;
  DP_IN = 8'h74;
  #100 RST = 0;
end
  
endmodule
