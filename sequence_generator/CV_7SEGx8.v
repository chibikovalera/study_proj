module CV_7SEGx8
(
  input CLK, RST, CE,
  input [31:0] HEX_IN,
  input [7:0] BLANK,
  input [7:0] DP_IN,
  output reg [7:0] AN,
  output [7:0] CAT
);
  
reg [2:0] count;  
  
//Счетчик разрядов
always@(posedge CLK, posedge RST)
begin
  if(RST)
    count <= 3'b0;
  else if(CE)
    count <= count + 1;
end

//Анодный дешифратор
always@(count)
begin
  case(count)
    3'b000: AN <= 8'b01111111;
    3'b001: AN <= 8'b10111111;
    3'b010: AN <= 8'b11011111;
    3'b011: AN <= 8'b11101111;
    3'b100: AN <= 8'b11110111;
    3'b101: AN <= 8'b11111011;
    3'b110: AN <= 8'b11111101;
    3'b111: AN <= 8'b11111110;
  endcase
end
  
//4-разрядный мультиплексор 8:1
reg [3:0] mx;
always@(count, HEX_IN)
  case(count)
    3'b000: mx = HEX_IN[3:0];
    3'b001: mx = HEX_IN[7:4];
    3'b010: mx = HEX_IN[11:8];
    3'b011: mx = HEX_IN[15:12];
    3'b100: mx = HEX_IN[19:16];
    3'b101: mx = HEX_IN[23:20];
    3'b110: mx = HEX_IN[27:24];
    3'b111: mx = HEX_IN[31:28];
  endcase

assign CAT[7] = ~DP_IN[7 - count];
  
//mx 8:1
reg blank;
always@(count, BLANK)
  case(count)
    3'b000: blank = ~BLANK[0];
    3'b001: blank = ~BLANK[1];
    3'b010: blank = ~BLANK[2];
    3'b011: blank = ~BLANK[3];
    3'b100: blank = ~BLANK[4];
    3'b101: blank = ~BLANK[5];
    3'b110: blank = ~BLANK[6];
    3'b111: blank = ~BLANK[7];
  endcase
  
//7-сегментный дешифратор
wire [6:0] catseg;
assign CAT[6:0] = ~catseg;
M_7SEG_DECODER_V11 dc (.I_CODE(mx), .I_EN(blank),
 .O_SEG_A(catseg[0]),
.O_SEG_B(catseg[1]),
 .O_SEG_C(catseg[2]),
.O_SEG_D(catseg[3]),
 .O_SEG_E(catseg[4]),
.O_SEG_F(catseg[5]),
 .O_SEG_G(catseg[6]));
  
endmodule
