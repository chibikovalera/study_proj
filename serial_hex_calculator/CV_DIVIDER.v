`timescale 1ns / 1ps

module CV_DIVIDER #
(
	parameter DIV_VALUE =  325,
	parameter CNT_WDT = 9
)
(
	input CLK, 
	input RST,
	
	output reg UART_CE
);

reg [CNT_WDT - 1:0] counter;
always @(posedge CLK, posedge RST) begin
	if(RST)
		counter <= {CNT_WDT{1'b0}};
	else if(counter == DIV_VALUE - 1)
		counter <= {CNT_WDT{1'b0}};
	else
		counter <= counter + 1;
end

always @(posedge CLK, posedge RST) begin
	if(RST)
		UART_CE <= 1'b0;
	else if(counter == {CNT_WDT{1'b0}})
		UART_CE <= 1'b1;
	else
		UART_CE <= 1'b0;
end

initial begin
	UART_CE <= 1'b0;
	counter <= {CNT_WDT{1'b0}};
end

endmodule
