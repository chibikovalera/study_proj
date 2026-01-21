`timescale 1ns / 1ps

module CV_GEN_MSG
(
    input CLK,
    input RST,

    input TX_RDY_R,
    output reg TX_RDY_T,
    output reg [7:0] TX_DATA_T,

    input RES_RDY_T,
    input [80:0] RES_DATA_R,
    output reg RES_RDY_R,

    input [7:0] DC_ASCII_DATA,
    output reg [3:0] HEX_DATA,

    input [7:0] DATA,
    output reg [6:0] ADDR
);

localparam IDLE = 0,
           TRES = 1,
           TMEM = 2,
           TDT = 3,
           TCR = 4,
           TLF = 5;

reg [2:0] STATE;

reg [6:0] END_ADDR;
reg [63:0] RES_DATA;
reg RES_FLG;

reg [3:0] RES_CT; 

wire [3:0] CT_MX; 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge CLK, posedge RST)
begin
    if (RST)
    begin
        TX_RDY_T <= 1'b0;
        TX_DATA_T <= 8'h00;
        RES_RDY_R <= 1'b1;
        RES_CT <= 4'b0000; 
        ADDR <= {7{1'b0}};
        END_ADDR <= {7{1'b0}};
        RES_DATA <= {64{1'b0}};
        RES_FLG <= 1'b0;
        STATE <= IDLE;
    end
    
    else
    case (STATE)
        IDLE: 
        begin
            if (RES_RDY_T)
            begin
                RES_RDY_R <= 1'b0;
                ADDR <= RES_DATA_R[77 -: 7];
                END_ADDR <= RES_DATA_R[70 -: 7];
                RES_DATA <= RES_DATA_R[63:0];
                RES_FLG <= (RES_DATA_R[80 -: 3] == 3'b001) | (RES_DATA_R[80 -: 3] == 3'b010);
                RES_CT <= CT_MX; 
                STATE <= TRES;
            end
        end
            
        TRES:
        begin
            TX_DATA_T <= DATA;
            TX_RDY_T <= 1'b1;
            ADDR <= ADDR + 1'b1;
            STATE <= TMEM;
        end
            
        TMEM:
        begin
            if (TX_RDY_R)
            begin
                if (ADDR == END_ADDR+1)
                begin
                    if (RES_FLG)
                    begin
                        RES_FLG <= 1'b0;
                        TX_DATA_T <= DC_ASCII_DATA;
                        RES_CT <= RES_CT + 1'b1;
                        STATE <= TDT;
                    end
                    else
                    begin
                        TX_DATA_T <= 8'h0D;
                        STATE <= TCR;
                    end
                end
                else
                begin
                    TX_DATA_T <= DATA;
                    ADDR <= ADDR + 1'b1;
                end
            end
        end
          
        TDT:
        begin
            if (TX_RDY_R)
            begin
                if (~|RES_CT) 
                begin
                    TX_DATA_T <= 8'h0D;
                    STATE <= TCR; 
                end
                else
                begin
                    TX_DATA_T <= DC_ASCII_DATA;
                    RES_CT <= RES_CT + 1'b1;
                end
            end 
        end
            
        TCR:
        begin
            if (TX_RDY_R)
            begin
                TX_DATA_T <= 8'h0A;
                STATE <= TLF;
            end
        end
          
        TLF:
            if (TX_RDY_R)
            begin
                TX_RDY_T <= 1'b0;
                RES_RDY_R <= 1'b1;
                STATE <= IDLE;
            end
    endcase
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign CT_MX = (RES_DATA_R[80 -: 3] == 3'b001) ? 7 : 0;

always @*
begin
    case (RES_CT)
        4'b0000: HEX_DATA <= RES_DATA[63:60];
        4'b0001: HEX_DATA <= RES_DATA[59:56];
        4'b0010: HEX_DATA <= RES_DATA[55:52];
        4'b0011: HEX_DATA <= RES_DATA[51:48];
        4'b0100: HEX_DATA <= RES_DATA[47:44];
        4'b0101: HEX_DATA <= RES_DATA[43:40];
        4'b0110: HEX_DATA <= RES_DATA[39:36];
        4'b0111: HEX_DATA <= RES_DATA[35:32];
        4'b1000: HEX_DATA <= RES_DATA[31:28];
        4'b1001: HEX_DATA <= RES_DATA[27:24];
        4'b1010: HEX_DATA <= RES_DATA[23:20];
        4'b1011: HEX_DATA <= RES_DATA[19:16];
        4'b1100: HEX_DATA <= RES_DATA[15:12];
        4'b1101: HEX_DATA <= RES_DATA[11:8];
        4'b1110: HEX_DATA <= RES_DATA[7:4];
        4'b1111: HEX_DATA <= RES_DATA[3:0];
    endcase
end

endmodule
