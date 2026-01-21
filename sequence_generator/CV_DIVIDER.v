module CV_DIVIDER # (parameter CNT_WDT = 3, parameter DIV_VAL = 8)
(
  input CLK, RST,
  output reg CEO
);
  
reg [CNT_WDT-1:0] STATE;

initial
begin
  STATE = 0;
  CEO = 0;
end
  
always@(posedge CLK, posedge RST)
begin
  if(RST)
  begin
    CEO <= 0;
    STATE <= {CNT_WDT{1'b0}};
  end
  else
  begin
    if(STATE == DIV_VAL - 1)
    begin
      STATE <= {CNT_WDT{1'b0}};
      CEO <= 1;
    end
    else
    begin
      STATE <= STATE + 1;
      CEO <= 0;
    end
  end
end
  
endmodule
