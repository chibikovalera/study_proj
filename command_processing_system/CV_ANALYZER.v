`timescale 1ns / 1ps

module CV_ANALYZER
( 
    input CLK,
    input RST,
    input RX_DATA_EN,
    input [7:0] RX_DATA_R,    
    input HEX_FLG,
    input [3:0] DC_ASCII_HEX,
    input CMD_RDY_R,
    
    output [7:0] ASCII_DATA,
    output reg [130:0] CMD_DATA_T = 0,
    output reg CMD_RDY_T
);

//Состояния для распознавания ключевых слов/////////////////////////////////////////////////////////////////////////////////////////////////////

localparam A_add = 1,
           D_add1 = 2,
           D_add2= 3,
           num3_add = 4,
           num6_add = 5,
           
           M_mul = 6,
           U_mul = 7,
           L_mul = 8,
           num6_mul = 9,
           num4_mul = 10,
           
           W_wr = 11,
           R_wr = 12,
           num4_wr = 13,
           num0_wr = 14,
           underline_wr = 15,
           num8_wr = 16,
           
           O_onff = 17,
           N_on = 18,
           num4_on = 19,
           num0_on = 20,
           underline_on = 21,
           num8_on = 22,
           
           F_off1 = 24,
           F_off2 = 25,
           num4_off = 26,
           num0_off = 27,
           underline_off = 28,
           num8_off = 29,
           
           L_led = 30,
           E_led = 31,
           D_led = 32,
           num4_led = 33,
           num0_led = 34,
           underline_led = 35,
           num8_led = 36;

///////////////////////////////////////////////////////////////////////////////

localparam IDLE = 0,
           SROPR = 37,
           TRANS = 38,
           ROPR = 39,
           EROPR = 40,
           ERCMD = 41;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam A = 8'h41,
           D = 8'h44,
           E = 8'h45,
           F = 8'h46,
           L = 8'h4C,
           M = 8'h4D,
           N = 8'h4E,
           O = 8'h4F,
           R = 8'h52,
           U = 8'h55,
           W = 8'h57,
           
           underline = 8'h5F,
           space = 8'h20,
           CR = 8'h0D,
           LF = 8'h0A,

           number_0 = 8'h30,
           number_1 = 8'h31,
           number_2 = 8'h32,
           number_3 = 8'h33,
           number_4 = 8'h34,
           number_5 = 8'h35,
           number_6 = 8'h36,
           number_7 = 8'h37,                        
           number_8 = 8'h38;

/////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam ADD36 = 3'b001,
           MUL64 = 3'b010,
           WR40_8 = 3'b111,
           ON40_8 = 3'b000,
           OFF40_8 = 3'b011,
           LED40_8 = 3'b100,
           error = 3'b101;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg [3:0] END_CT = 0;
reg [5:0] STATE; 
reg [3:0] DATA_CT = 0; 
reg OPR2_FLG = 0; 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge CLK, posedge RST)
    begin
        if (RST)
        begin
            CMD_RDY_T <= 1'b0;
            CMD_DATA_T <= {131{1'b0}};
            DATA_CT <= 4'h0;
            OPR2_FLG <= 1'b0;
            STATE <= IDLE;
        end
        else 
        case(STATE)
            IDLE:
            begin
                if (RX_DATA_EN)
                begin
                    if (RX_DATA_R == A) STATE <= A_add; 
                    else if (RX_DATA_R == M) STATE <= M_mul; 
                    else if (RX_DATA_R == W) STATE <= W_wr;  
                    else if (RX_DATA_R == O) STATE <= O_onff; 
                    else if (RX_DATA_R == L) STATE <= L_led;  
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
                end
            end
            
//ADD36///////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            A_add: begin
                if (RX_DATA_EN) 
                begin
                    if (RX_DATA_R == D) STATE <= D_add1;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
                end 
            end   
                
            D_add1: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == D) STATE <= D_add2;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end 
            end    
                
            D_add2: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_3) STATE <= num3_add;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
            
            num3_add: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_6)
                        STATE <= num6_add;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
            
            num6_add: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == space)
                    begin
                        CMD_DATA_T[130 -: 3] <= 3'b001;
                        STATE <= SROPR;
                    end
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
             end
                
//MUL64/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      
            M_mul: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == U)
                        STATE <= U_mul;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            U_mul: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == L)
                        STATE <= L_mul;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            L_mul: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_6)
                        STATE <= num6_mul;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num6_mul: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_4)
                        STATE <= num4_mul;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num4_mul: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == space)
                    begin
                        STATE <= SROPR;
                        CMD_DATA_T[130 -: 3] <= MUL64;
                    end
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                    
//WR40_8/////////////////////////////////////////////////////////////////////////////////////////////////////////

            W_wr: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == R)
                        STATE <= R_wr;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            R_wr: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_4)
                        STATE <= num4_wr;
                    else
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num4_wr: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_0)
                        STATE <= num0_wr;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num0_wr: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == underline)
                        STATE <= underline_wr;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            underline_wr: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_8)
                        STATE <= num8_wr;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
            
            num8_wr: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == space)
                    begin
                        STATE <= SROPR;
                        CMD_DATA_T[130 -: 3] <= WR40_8;
                    end
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
//ON40_8 & OFF40_8//////////////////////////////////////////////////////////////////////////////////////////////////////

            O_onff: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == N)
                        STATE <= N_on;
                    else if (RX_DATA_R == F)
                        STATE <= F_off1;
                    else
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
            
            N_on: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_4)
                        STATE <= num4_on;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num4_on: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_0)
                        STATE <= num0_on;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num0_on: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == underline)
                        STATE <= underline_on;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            underline_on: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_8)
                        STATE <= num8_on;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num8_on: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == space)
                    begin
                        STATE <= SROPR;
                        CMD_DATA_T[130 -: 3] <= 3'b000;
                    end
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end            
/////////

            F_off1: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == F)
                        STATE <= F_off2;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            F_off2: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_4)
                        STATE <= num4_off;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num4_off: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_0)
                        STATE <= num0_off;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num0_off: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == underline)
                        STATE <= underline_off;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            underline_off: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_8)
                        STATE <= num8_off;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num8_off: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == space)
                    begin
                        STATE <= SROPR;
                        CMD_DATA_T[130 -: 3] <= OFF40_8;
                    end
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end        
//LED40_8////////////////////////////////////////////////////////////////////////////////////////////////////

            L_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == E)
                        STATE <= E_led;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                    
            E_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == D)
                        STATE <= D_led;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            D_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_4)
                        STATE <= num4_led;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num4_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_0)
                        STATE <= num0_led;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num0_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == underline)
                        STATE <= underline_led;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            underline_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == number_8)
                        STATE <= num8_led;
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            num8_led: begin
                if (RX_DATA_EN)
                    if (RX_DATA_R == space)
                    begin
                        STATE <= SROPR;
                        CMD_DATA_T[130 -: 3] <= LED40_8;
                    end
                    else 
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end        
////////////////////////////////////////////////////////////////////////////////////////////////////////////

            SROPR: begin
                if (RX_DATA_EN)
                    if (HEX_FLG)
                    begin
                        CMD_DATA_T[127:0] <= {CMD_DATA_T[123:0], DC_ASCII_HEX};
                        DATA_CT <= DATA_CT + 1'b1;
                        STATE <= ROPR;
                    end
                    else
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
            
            ROPR: begin
                if (RX_DATA_EN)
                    if (HEX_FLG)
                    begin
                        CMD_DATA_T[127:0] <= {CMD_DATA_T[123:0], DC_ASCII_HEX};
                        if (DATA_CT == END_CT)
                        begin
                            DATA_CT <= 4'b0000;
                            STATE <= EROPR;
                        end
                        else DATA_CT <= DATA_CT + 1'b1;
                    end
                    else begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            EROPR: begin
                if (RX_DATA_EN)
                    if (~OPR2_FLG && (RX_DATA_R == space))
                        begin
                            OPR2_FLG <= 1'b1;
                            STATE <= SROPR;
                        end
                    else if (OPR2_FLG && (RX_DATA_R == CR))
                    begin
                        STATE <= ERCMD;
                    end
                    else
                    begin
                        CMD_DATA_T[130 -: 3] <= error;
                        CMD_RDY_T <= 1'b1;
                        STATE <= TRANS;
                    end
            end
                
            ERCMD: begin
                if (RX_DATA_EN)
                begin
                    CMD_RDY_T <= 1'b1;
                    if (RX_DATA_R == LF)
                        STATE <= TRANS;
                    else begin
                        CMD_DATA_T[130 -: 3] <= error;
                        STATE <= TRANS;
                    end
                end
            end
            
            TRANS: begin
                if (CMD_RDY_R)
                begin
                    CMD_RDY_T <= 1'b0;
                    OPR2_FLG <= 1'b0;
                    STATE <= IDLE;
                end
            end
        
        endcase
    end
    
////////////////////////////////////////////////////////////////////////////////    
    
assign ASCII_DATA[7:0] = RX_DATA_R[7:0];

always @*
begin
    if (~OPR2_FLG) begin
        case (CMD_DATA_T [130 -: 3])
            3'b000: END_CT = 4'd9;
            3'b001: END_CT = 4'd8;
            3'b010: END_CT = 4'd15;
            3'b011: END_CT = 4'd9;
            3'b100: END_CT = 4'd9;
            3'b101: END_CT = 4'd0;
            3'b110: END_CT = 4'd0;
            3'b111: END_CT = 4'd9;
        endcase
    end
    else begin
        case (CMD_DATA_T [130 -: 3])
            3'b000: END_CT = 4'd1;
            3'b001: END_CT = 4'd8;
            3'b010: END_CT = 4'd15;
            3'b011: END_CT = 4'd1;
            3'b100: END_CT = 4'd1;
            3'b101: END_CT = 4'd0;
            3'b110: END_CT = 4'd0;
            3'b111: END_CT = 4'd1;
        endcase
    end
end

endmodule

