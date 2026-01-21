`timescale 1ns / 1ps

module CV_HANDLER_CMD 
(
    input CLK,
    input RST,
    input CMD_RDY_T,
    input [130:0] CMD_DATA_T, 
    input RES_RDY_R,
    input S_EX_ACK,
    input [7:0] S_D_RD,


    output reg CMD_RDY_R,
    output reg RES_RDY_T,
    output [80:0] RES_DATA_T,
    output reg S_EX_REQ,
    output reg [39:0] S_ADDR, 
    output reg [2:0] S_CMD, 
    output reg [7:0] S_D_WR 
);


reg [2:0] STATE;

localparam WDATA = 0,
           ALZ = 1,
           WR = 2,
           IORD = 3,
           IOWR = 4,
           TRANS = 5;

localparam ADD36 = 3'b001,
           MUL64 = 3'b010,
           WR40_8 = 3'b111,
           ON40_8 = 3'b000,
           OFF40_8 = 3'b011,
           LED40_8 = 3'b100,
           ERR = 3'b101;

reg [63:0] RES_DATA;
reg [6:0] START_ADDR;
reg [6:0] END_ADDR;
wire [2:0] RES_TYPE;

reg [130:0] CMD_DATA;

//////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge CLK, posedge RST)
begin
    if (RST)
    begin
        CMD_DATA <= {131{1'b0}}; 
        CMD_RDY_R <= 1'b1;
        RES_RDY_T <= 1'b0;
        RES_DATA <= {64{1'b0}};
        S_EX_REQ <= 1'b0;
        S_ADDR <= {40{1'b0}}; 
        S_CMD <= 3'b000;
        S_D_WR <= 8'h00;
        STATE <= WDATA;
    end
    
    else case (STATE)
        WDATA:
        if (CMD_RDY_T)
        begin
            CMD_DATA <= CMD_DATA_T; 
            CMD_RDY_R <= 1'b0;
            STATE <= ALZ;
        end

        ALZ:
        if (CMD_DATA[130:128] == 3'b001) 
        begin
            RES_DATA <= CMD_DATA[71:36] + CMD_DATA[35:0];
            RES_RDY_T <= 1'b1;
            STATE <= TRANS;
        end
        
        else if (CMD_DATA[130:128] == MUL64)
        begin
            RES_DATA <= CMD_DATA[127:64] * CMD_DATA[63:0];
            RES_RDY_T <= 1'b1;
            STATE <= TRANS;
        end

        else if (CMD_DATA[130:128] == ERR)
        begin
            RES_RDY_T <= 1'b1;
            STATE <= TRANS;
        end
                
        else if (CMD_DATA[130:128] == 3'b000 | CMD_DATA[130:128] == OFF40_8)
        begin
            S_EX_REQ <= 1'b1;
            S_ADDR <= CMD_DATA[47:8];
            S_CMD <= 3'b100; 
            STATE <= IORD;
        end
        
        else if (CMD_DATA[130:128] == LED40_8)
        begin
            S_EX_REQ <= 1'b1;
            S_ADDR <= CMD_DATA[47:8];
            S_CMD <= 3'b000; 
            S_D_WR <= CMD_DATA[7:0];
            STATE <= WR;
        end
        
        else if (CMD_DATA[130:128] == WR40_8)
        begin
            S_EX_REQ <= 1'b1;
            S_ADDR <= CMD_DATA[47:8];
            S_CMD <= 3'b001; 
            S_D_WR <= CMD_DATA[7:0];
            STATE <= WR;
        end
             
        WR:
        if (S_EX_ACK)
        begin
            RES_RDY_T <= 1'b1;
            S_EX_REQ <= 1'b0;
            STATE <= TRANS;
        end
        
        IORD:
        if (S_EX_ACK)
        begin
            S_CMD <= 3'b000; 
            if (CMD_DATA[130:128] == 3'b000) S_D_WR <= S_D_RD | CMD_DATA[7:0];
            else if (CMD_DATA[130:128] == OFF40_8) S_D_WR <= S_D_RD & ~CMD_DATA[7:0];
            STATE <= IOWR;
        end
        
        IOWR:
        if (S_EX_ACK)
        begin
            RES_RDY_T <= 1'b1;
            S_EX_REQ <= 1'b0;
            STATE <= TRANS;
        end

        TRANS:
        if (RES_RDY_R)
        begin
            RES_RDY_T <= 1'b0;
            CMD_RDY_R <= 1'b1;
            STATE <= WDATA;
        end
    endcase
end

//////////////////////////////////////////////////////////////////////////////////////////////////

always @(*)
begin
    case(CMD_DATA[130:128])
        3'b001:
        begin
            START_ADDR <= 7'h00;
            END_ADDR <= 7'h0D;
        end
        
        MUL64:
        begin
            START_ADDR <= 7'h0E;
            END_ADDR <= 7'h1B;
        end
        
        WR40_8:
        begin
            START_ADDR <= 7'h1C;
            END_ADDR <= 7'h29;
        end
        
        3'b000:
        begin
            START_ADDR <= 7'h2A;
            END_ADDR <= 7'h37;
        end
        
        OFF40_8:
        begin
            START_ADDR <= 7'h38;
            END_ADDR <= 7'h46;
        end
        
        LED40_8:
        begin
            START_ADDR <= 7'h47;
            END_ADDR <= 7'h55;
        end   
        
        ERR:
        begin
            START_ADDR <= 7'h56;
            END_ADDR <= 7'h65;
        end  
            
        default:
        begin
            START_ADDR <= 7'h00;
            END_ADDR <= 7'h00;     
        end
    endcase
end

assign RES_TYPE = CMD_DATA[130:128];
assign RES_DATA_T = {RES_TYPE, START_ADDR, END_ADDR, RES_DATA};

endmodule
