`timescale 1ns / 1ps

module CV_SYNCH
(
	input RXD, 
	input CLK, 
	input RST,
	
	output RXD_RG
);

reg a, b, c;

initial
begin
		a <= 1'b1;
		b <= 1'b1;
		c <= 1'b1;
end

always@(posedge CLK, posedge RST)
begin
	if(RST)
	begin
		a <= 1'b1;
		b <= 1'b1;
		c <= 1'b1;
	end
	else
	begin
		a <= RXD;
		b <= a;
		c <= b;
	end
end 

assign RXD_RG = c;

endmodule
