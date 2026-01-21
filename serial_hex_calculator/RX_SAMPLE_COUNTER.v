`timescale 1ns / 1ps

module RX_SAMPLE_COUNTER
(
	input UART_CE, 
	input RXCT_R, 
	input CLK, 
	input RST,
	
	output RX_CE
);

reg [3:0] RX_SAMP_CT; 

initial RX_SAMP_CT = 0;

always@(posedge CLK, posedge RST)
begin
	if(RST) RX_SAMP_CT <= 4'd0;
	else if(RXCT_R) RX_SAMP_CT <= 4'd0;
	else if(UART_CE)
	begin
		RX_SAMP_CT <= RX_SAMP_CT + 1'b1;
	end
end

assign RX_CE = UART_CE & (~RX_SAMP_CT[3]) & RX_SAMP_CT[2] & RX_SAMP_CT[1] & RX_SAMP_CT[0];

endmodule
