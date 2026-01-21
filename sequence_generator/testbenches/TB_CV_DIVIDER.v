module TB_CV_DIVIDER();
reg clk = 0;
reg rst = 0;
wire [2:0] state;
wire CE;
always #10 clk = ~clk;
  
CV_DIVIDER #(4,7) uut1
(
  .CLK(clk),
  .RST(rst),
  .CEO(CE),
  .STATE(state)
);
  
endmodule
