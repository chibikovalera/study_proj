module CV_BTN_FLTR # (parameter CNTR_WIDTH = 4)
(
	input BTN_IN, 
	input CLK, 
	input CE, 
	input RST,
	
	output BTN_OUT
);

reg BTN_S2;
reg BTN_S1;
reg BTN_D;

reg [CNTR_WIDTH-1:0] FLTR_CNT;

initial
begin
	FLTR_CNT = {CNTR_WIDTH{1'b0}};
	BTN_D = 0;
	BTN_S1 = 0;
	BTN_S2 = 0;
end

//Синхронизатор

always@(posedge CLK, posedge RST) 
begin
	if(RST)
	begin
		BTN_D  <= 1'b0;
		BTN_S1 <= 1'b0;
	end
	
	else
	begin
		BTN_D  <= BTN_IN;
		BTN_S1 <= BTN_D;
	end
end

//Счётчик

always@(posedge CLK, posedge RST)
begin
	if(RST)
		FLTR_CNT <= {CNTR_WIDTH{1'b0}};
	else
	begin
		if (BTN_S1 ^~ BTN_S2)
			FLTR_CNT <= {CNTR_WIDTH{1'b0}};
		else if (CE)
			FLTR_CNT <= FLTR_CNT + 1;
	end
end

//Выходной регистр

always@(posedge CLK, posedge RST)
begin
	if(RST)
		BTN_S2 <= 0;
	else if(CE && FLTR_CNT == {CNTR_WIDTH{1'b1}})
	begin
		BTN_S2 <= BTN_S1;
	end 
end

//Нижний регистр
assign BTN_OUT = BTN_S2;

endmodule
