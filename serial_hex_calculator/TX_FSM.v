`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module TX_FSM
(
    input  CLK,
    input RST,
    input UART_CE,
    input TX_CE,
    input [7:0] TX_DATA_R,
    input TX_RDY_T,
    
    output reg TXCT_R,
    output reg TX_RDY_R,
    output reg TXD
);

localparam IDLE = 3'd0,
           WCE = 3'd1,
           TSTRB = 3'd2,
           TDT = 3'd3,
           TPARB = 3'd4,
           TSTB1 = 3'd5;

reg [2:0] STATE;
reg [2:0] TX_DATA_CT;
reg [7:0] TX_DATA;
reg TX_PAR_BIT_RG;

always@(posedge CLK, posedge RST)
begin
    if(RST)
    begin
        TX_DATA       <= 8'h00;
        TX_PAR_BIT_RG <= 1'b0;
        TX_RDY_R      <= 1'b1;
        TX_DATA_CT    <= 3'b000;
        TXD           <= 1'b1;
        TXCT_R        <= 1'b1;
        STATE         <= IDLE;
    end
    else
    begin
        case(STATE)
            IDLE:
                if (TX_RDY_T)
                begin
                    TX_DATA       <= TX_DATA_R;
                    TX_PAR_BIT_RG <= ^(TX_DATA_R);
                    TX_RDY_R      <= 1'b0;
                    if (UART_CE)
                    begin
                        TXD    <= 1'b0;
                        TXCT_R <= 1'b0;
                        STATE  <= TSTRB;
                    end
                    else STATE <= WCE;
                end 
            WCE:
                if (UART_CE)
                begin
                    TXD    <= 1'b0;
                    TXCT_R <= 1'b0;
                    STATE  <= TSTRB;
                end
            TSTRB:
                if (TX_CE)
                begin
                    TXD     <= TX_DATA[0];
                    TX_DATA <= {1'b0, TX_DATA[7:1]};
                    STATE   <= TDT;
                end
            TDT:
                if (TX_CE)
                begin
                    TX_DATA    <= {1'b0, TX_DATA[7:1]};
                    TX_DATA_CT <= TX_DATA_CT + 1'b1;
                    if (TX_DATA_CT == 4'h7)
                    begin
                        TXD   <= TX_PAR_BIT_RG;
                        STATE <= TPARB;
                    end
                    else TXD <= TX_DATA[0];
                end
           TPARB:
                if (TX_CE)
                begin
                    TXD   <= 1'b1;
                    STATE <= TSTB1;
                end
           TSTB1:
                if (TX_CE)
                begin
                    TXD      <= 1'b1; 
                    STATE    <= IDLE;
                    TX_RDY_R <= 1'b1;
                    TXCT_R   <= 1'b1;
                end
       endcase
    end
end
endmodule
