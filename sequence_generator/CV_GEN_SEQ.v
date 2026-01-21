module CV_GEN_SEQ
(
  input CLK, RST, STEP, LOAD, UP,
  input [3:0] DAT_I,
  output reg [3:0] SEQ,
  output reg [3:0] NOM
);
  
function [3:0] Func;
input [3:0] in;
begin
  case(in)
    4'h0: Func = 4'h7;
    4'h1: Func = 4'h4;
    4'h2: Func = 4'h1;
    4'h3: Func = 4'h4;
    4'h4: Func = 4'h2;
    4'h5: Func = 4'hA;
    4'h6: Func = 4'h0;
    4'h7: Func = 4'h8;
    4'h8: Func = 4'h9;
    4'h9: Func = 4'hC;
    4'hA: Func = 4'h3;
    4'hB: Func = 4'h2;
    4'hC: Func = 4'hA;
    4'hD: Func = 4'h7;
    4'hE: Func = 4'h9;
    default: Func = 4'h2;
  endcase
end
endfunction
  
always@(posedge CLK, posedge RST)
begin
  if(RST)
  begin
    NOM <= 4'h0;
    SEQ <= Func(4'h0);
  end
  else if(LOAD)
  begin
    NOM <= DAT_I;
    SEQ <= Func(DAT_I);
  end
  else if(STEP)
  begin
    if(~UP)
    begin
      NOM <= NOM - 1'b1;
      SEQ <= Func(NOM - 1'b1);
    end
    else
    begin
      NOM <= NOM + 1'b1;
      SEQ <= Func(NOM + 1'b1);
    end
  end
  
  else
  begin
    NOM <= NOM;
    SEQ <= SEQ;
  end
end
  
endmodule
