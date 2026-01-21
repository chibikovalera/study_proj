module clock_divider 
(
    input wire clk,        // 100 MHz вход
    input wire rst,        // сброс 
    output reg clk_vga     // 25 MHz выход
);
reg [1:0] counter;  

always @(posedge clk or posedge rst) begin
    if (rst) 
    begin
        counter <= 0;
        clk_vga <= 0;
    end 
    else 
    begin
        counter <= counter + 1;
        clk_vga <= counter[1]; 
    end
end

endmodule
