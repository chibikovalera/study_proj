module CV_ANL_SEQ
(
  input [3:0] DAT_I, 
	input CE, CLK, RST,
	output reg [15:0] NOM
);
  
reg [4:0] STATE = 0;
initial NOM = 16'b0000000000000000;
always@(posedge CLK, posedge RST)
begin
	if(RST) 
	begin
		NOM = 4'h0000;
		STATE = 0;
	end
	
	else if(CE)
	begin
		case(STATE)
		//Состояние 0
		4'h0: 
		begin
			if(DAT_I == 4'h7) 
				begin
					NOM = 16'b0000000000000001;
					STATE = STATE + 1;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 1
		4'h1:
		begin
			if(DAT_I == 4'h4) 
				begin
					NOM = 16'b0000000000000011;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
    //Состояние 2
		4'h2:
		begin
			if(DAT_I == 4'h1) 
				begin
					NOM = 16'b0000000000000111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 3
		4'h3:
		begin
			if(DAT_I == 4'h4) 
				begin
					NOM = 16'b0000000000001111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		4'h4:
		begin
			if(DAT_I == 4'h2) 
				begin
					NOM = 16'b0000000000011111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 5
		4'h5:
		begin
			if(DAT_I == 4'hA) 
				begin
					NOM = 16'b0000000000111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 6
		4'h6:
		begin
			if(DAT_I == 4'h0) 
				begin
					NOM = 16'b0000000001111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
    //Состояние 7
		4'h7:
		begin
			if(DAT_I == 4'h8) 
				begin
					NOM = 16'b0000000011111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 8
		4'h8:
		begin
			if(DAT_I == 4'h9) 
				begin
					NOM = 16'b0000000111111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
    //Состояние 9
		4'h9:
		begin
			if(DAT_I == 4'hC) 
				begin
					NOM = 16'b0000001111111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 10
		4'hA:
		begin
			if(DAT_I == 4'h3) 
				begin
					NOM = 16'b0000011111111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 11
		4'hB:
		begin
			if(DAT_I == 4'h2) 
				begin
					NOM = 16'b0000111111111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
    //Состояние 12
		4'hC:
		begin
			if(DAT_I == 4'hA) 
				begin
					NOM = 16'b0001111111111111;
					STATE = STATE + 1;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 13
		4'hD:
		begin
			if(DAT_I == 4'h7) 
				begin
					NOM = 16'b0011111111111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 14
		4'hE:
		begin
			if(DAT_I == 4'h9) 
				begin
					NOM = 16'b0111111111111111;
					STATE = STATE + 1;
				end
        else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 15
		4'hF:
		begin
			if(DAT_I == 4'h2) 
				begin
					NOM = 16'b1111111111111111;
					STATE = STATE + 1;;
				end
			else 
				begin
					NOM = 4'h0000;
					STATE = 0;
				end
		end
		//Состояние 16
		default:
		begin
			NOM = 16'b0000000000000000;
			STATE = 0;
		end
		endcase
	end
end

endmodule
