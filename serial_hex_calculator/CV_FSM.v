`timescale 1ns / 1ps
 
//////////////////////////////////////////////////////////////////////////////////

module CV_FSM
(
    input CLK,
    input RST,
    input RX_DATA_EN,
    input wire [9:0] RX_DATA_R,
    input TX_RDY_R,
    input HEX_FLG,
    input [3:0] DC_HEX_DATA,
    input [7:0] DC_ASCII_DATA,
    input [7:0] DATA,
          
    output reg TX_RDY_T,
    output reg [7:0] TX_DATA_T,
    output [7:0] ASCII_DATA,
    output reg [3:0] HEX_DATA,
    output reg [6:0] ADDR
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam IDLE = 4'd0,
           RDT = 4'd1,
           RCR = 4'd2,
           RLF = 4'd3,
           TRES = 4'd4,
           TMEM = 4'd5,
           TDT = 4'd6,
           TCR = 4'd7,
           TLF = 4'd8;
          
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////          
          
reg [3:0] DATA_CT; //счетчик принимаемых байтов
reg [4:0] RES_CT; //счетчик передаваемых байтов регистра результата
reg [67:0] RES_REG; //внутренний регистр результата.
reg [63:0] DATA_REG; //сдвиговый регистр, хранящий принимаемые данные.
reg [6:0] END_ADDR; //регистр, хранящий последний адрес, по которому обращаются к ПЗУ
reg RES_FLG; //флаг, показывающий, что нужно вывести результат выполнения операции.

reg [6:0] ERR_A0_MX;
reg [6:0] ERR_A1_MX;

reg [3:0] STATE;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign ASCII_DATA[7:0] = RX_DATA_R[7:0]; 

always@(*)
begin
    case(RES_CT)
        5'd00: HEX_DATA = RES_REG[67:64];
        5'd01: HEX_DATA = RES_REG[63:60];
        5'd02: HEX_DATA = RES_REG[59:56];
        5'd03: HEX_DATA = RES_REG[55:52];
        5'd04: HEX_DATA = RES_REG[51:48];
        5'd05: HEX_DATA = RES_REG[47:44];
        5'd06: HEX_DATA = RES_REG[43:40];
        5'd07: HEX_DATA = RES_REG[39:36];
        5'd08: HEX_DATA = RES_REG[35:32];
        5'd09: HEX_DATA = RES_REG[31:28];
        5'd10: HEX_DATA = RES_REG[27:24];
        5'd11: HEX_DATA = RES_REG[23:20];
        5'd12: HEX_DATA = RES_REG[19:16];
        5'd13: HEX_DATA = RES_REG[15:12];
        5'd14: HEX_DATA = RES_REG[11:8];
        5'd15: HEX_DATA = RES_REG[7:4];
        5'd16: HEX_DATA = RES_REG[3:0];
        default: HEX_DATA = 4'd0;
    endcase
end

always@(*)
begin
    case(RX_DATA_R[9:8])
        2'b00: ERR_A0_MX[6:0] = 7'h08;
        2'b01: ERR_A0_MX[6:0] = 7'h1A;
        2'b10: ERR_A0_MX[6:0] = 7'h2C;
        2'b11: ERR_A0_MX[6:0] = 7'h43;
    endcase    
end

always@(*)
begin
    case(RX_DATA_R[9:8])
        2'b00: ERR_A1_MX[6:0] = 7'h19;
        2'b01: ERR_A1_MX[6:0] = 7'h2B;
        2'b10: ERR_A1_MX[6:0] = 7'h42;
        2'b11: ERR_A1_MX[6:0] = 7'h4D;
    endcase    
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge CLK, posedge RST)
begin
    if (RST)
    begin
        STATE     <= IDLE;
        TX_DATA_T <= 8'h00;
        TX_RDY_T  <= 1'b0;
        DATA_CT   <= {4{1'b0}};
        RES_CT    <= {5{1'b0}}; 
        RES_REG   <= {68{1'b0}};
        DATA_REG  <= {64{1'b0}};
        ADDR      <= {7{1'b0}};
        END_ADDR  <= {7{1'b0}};
        RES_FLG   <= 1'b0;
    end
    else
    begin
        case(STATE)
            IDLE:
                if(RX_DATA_EN)
                begin                   
                    if(RX_DATA_R[9]|RX_DATA_R[8]|~HEX_FLG)
                    begin
                        ADDR     <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                        STATE    <= TRES;
                    end   
                    else if(HEX_FLG)
                    begin
                        ADDR     <= 7'h00;
                        END_ADDR <= 7'h07;
                        DATA_REG <= {DATA_REG[59:0], DC_HEX_DATA}; 
                        DATA_CT  <= DATA_CT + 1'b1;
                        STATE    <= RDT;
                    end                                    
                end
            RDT:
                if(RX_DATA_EN)
                begin
                    if(RX_DATA_R[9]|RX_DATA_R[8]|~HEX_FLG)
                    begin
                        ADDR     <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                        STATE    <= TRES;
                    end
                    else if(HEX_FLG)
                    begin
                        DATA_REG <= {DATA_REG[59:0], DC_HEX_DATA};
                        DATA_CT  <= DATA_CT + 1'b1;
                        if(DATA_CT == 15) 
                        begin
                            DATA_CT <= {4{1'b0}};
                            STATE   <= RCR;
                        end
                    end 
                end
            RCR:
                if(RX_DATA_EN)
                begin
                    if(RX_DATA_R[9]|RX_DATA_R[8]|RX_DATA_R[7:0] != 8'h0D)
                    begin
                        ADDR     <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                        STATE    <= TRES;
                    end
                    else if(RX_DATA_R[7:0] == 8'h0D) STATE <=  RLF;   
                end
            RLF:
                if(RX_DATA_EN)
                begin
                    if(RX_DATA_R[9]|RX_DATA_R[8]|RX_DATA_R[7:0] != 8'h0A)
                    begin
                        ADDR     <= ERR_A0_MX;
                        END_ADDR <= ERR_A1_MX;
                        STATE    <= TRES;
                    end  
                    else if(RX_DATA_R[7:0] == 8'h0A)
                    begin
                        RES_REG <= RES_REG - DATA_REG;
                        RES_FLG <= 1'b1;
                        STATE   <= TRES;
                    end
                       
                end
            TRES:
            begin
                TX_DATA_T <= DATA;
                TX_RDY_T  <= 1'b1;
                ADDR      <= ADDR + 1'b1;
                STATE     <= TMEM;
            end    
            TMEM:
                if(TX_RDY_R)
                begin
                    if(ADDR == END_ADDR + 1)
                    begin
                        if(RES_FLG)
                        begin
                            RES_FLG   <= 1'b0;
                            TX_DATA_T <= DC_ASCII_DATA;
                            RES_CT    <= RES_CT + 1'b1;
                            STATE     <= TDT;
                        end
                        else
                        begin
                            TX_DATA_T <= 8'h0D;
                            STATE     <= TCR;
                        end
                    end
                    else
                    begin
                        TX_DATA_T <= DATA;
                        ADDR      <= ADDR + 1'b1;
                    end
                end
            TDT:
                if(TX_RDY_R)
                begin
                    if(RES_CT == 16) 
                    begin
                        TX_DATA_T <= 8'h0D;
                        RES_CT    <= {5{1'b0}}; 
                        STATE     <= TCR;
                    end
                    else
                    begin
                        TX_DATA_T <= DC_ASCII_DATA;
                        RES_CT    <= RES_CT + 1'b1;
                    end
                end
            TCR:
                if(TX_RDY_R)
                begin
                    TX_DATA_T <= 8'h0A;
                    STATE     <= TLF;
                end
            TLF:
                if(TX_RDY_R)
                begin
                    TX_RDY_T <= 1'b0;
                    STATE    <= IDLE;
                end
        endcase
    end
end
endmodule
