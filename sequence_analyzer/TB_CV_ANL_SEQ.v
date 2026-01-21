TB_CV_ANL_SEQ;

reg CLK, CE;
reg RST;
reg [3:0] DAT_I;
wire [15:0] NOM;
CV_ANL_SEQ uut1
(
    .CLK(CLK), 
    .RST(RST), 
    .CE(CE), 
    .DAT_I(DAT_I), 
    .NOM(NOM)
);

initial
begin
    DAT_I=0;
    RST=0;
    CE=1;
    CLK=0;
    #20 DAT_I=4'h7;
    #20 DAT_I=4'h4;
    #20 RST = 1;
    #20 RST = 0;    
    #20 DAT_I=4'h7;
    #20 DAT_I=4'h4;
    #20 DAT_I=4'h9; //ошибка
    #20 DAT_I=4'h7;
    #20 DAT_I=4'h4;
    #20 DAT_I=4'h1;
    #20 DAT_I=4'h4;
    #20 DAT_I=4'h2;
    #20 DAT_I=4'hA;
    #20 DAT_I=4'h0;
    #20 DAT_I=4'h8;
    #20 DAT_I=4'h9;
    #20 DAT_I=4'hC;
    #20 DAT_I=4'h3;
    #20 DAT_I=4'h2;
    #20 DAT_I=4'hA;
    #20 DAT_I=4'h7;
    #20 DAT_I=4'h9;
    #20 DAT_I=4'h2;
end
always #10 CLK=~CLK;
endmodule
