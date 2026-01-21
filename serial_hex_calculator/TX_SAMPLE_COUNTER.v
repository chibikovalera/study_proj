`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module TX_SAMPLE_COUNTER
(
    input UART_CE,
    input TXCT_R,
    input CLK,
    input RST,
    
    output TX_CE
);

reg [3:0] TX_SAMP_CT;
initial TX_SAMP_CT = 0;

always@(posedge CLK, posedge RST)
begin
    if (RST) TX_SAMP_CT         <= 4'd0;
    else if (TXCT_R) TX_SAMP_CT <= 4'd0;
    else if (UART_CE)
    begin
        TX_SAMP_CT <= TX_SAMP_CT + 1'b1;
    end
end

assign TX_CE = UART_CE & TX_SAMP_CT[3] & TX_SAMP_CT[2] & TX_SAMP_CT[1] & TX_SAMP_CT[0];

endmodule
