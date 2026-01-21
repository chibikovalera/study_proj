`timescale 1ns / 1ps

module RX_FSM
(
	input RXD_RG, 
	input CLK, 
	input RST, 
	input RX_CE,
	
	output reg [9:0] RX_DATA_T, 
	output reg RX_DATA_EN,
	output reg RXCT_R
);

localparam IDLE  = 3'd0,
		   RSTRB = 3'd1,
	       RDT   = 3'd2,
		   RPARB = 3'd3,
	       RSTB1 = 3'd4,
		   WEND  = 3'd5;
			 
reg [2:0] STATE;
reg [3:0] RX_DATA_CT;

always@(posedge CLK, posedge RST)
begin
	if(RST)
	begin
		STATE      <= IDLE;
		RX_DATA_EN <= 1'b0;
		RXCT_R     <= 1'b1;
		RX_DATA_T  <= {10{1'b0}};
		RX_DATA_CT <= {3{1'b0}}; 
	end
	else
	begin
		case(STATE)
			IDLE:
				if(~RXD_RG)
				begin
					RX_DATA_EN   <= 1'b0;
					RX_DATA_T[9] <= 1'b0;
					RXCT_R       <= 1'b0;
					STATE        <= RSTRB;
				end
				else RX_DATA_EN <= 1'b0;
			RSTRB:
				if(RX_CE)
				begin
					if(RXD_RG)
					begin
						RXCT_R <= 1'b1;
						STATE  <= IDLE;
					end
					else STATE <= RDT; 
				end
			RDT:
				if(RX_CE)
				begin
					RX_DATA_T[7:0] <= {RXD_RG, RX_DATA_T[7:1]};
					RX_DATA_CT     <= RX_DATA_CT + 1'b1;
					if(RX_DATA_CT == 4'h7) STATE <= RPARB;
				end
			RPARB:
				if(RX_CE)
				begin		
					RX_DATA_T[8] <= ^(RX_DATA_T[7:0]) ^ RXD_RG;
					STATE <= RSTB1;
				end
			RSTB1:
				if(RX_CE)
				begin
					if(RXD_RG)
						begin
							RX_DATA_EN <= 1'b1;
							RXCT_R     <= 1'b1;
							STATE      <= IDLE;
						end
					else
						begin
							RX_DATA_T[9] <= 1'b1;
							STATE        <= WEND;
						end
				end
			WEND:
				begin
					if(RXD_RG) 
					begin
						RX_DATA_EN <= 1'b1;
						RXCT_R     <= 1'b1;
						STATE      <= IDLE;
					end
				end
		endcase
	end
end
endmodule
