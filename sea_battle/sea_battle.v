`timescale 1ns / 1ps

// Основной модуль морского боя
module sea_battle 
(
    input wire clk,          
    input wire sys_nrst,
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue,
    input wire ps2_data,
    input wire ps2_clk
);

wire clk_vga; // 25 MHz для VGA
reg [1:0] sync_rst;
wire rst;

// Синхронизатор сброса
always@(posedge clk or negedge sys_nrst)
begin
    if(!sys_nrst) sync_rst <= 2'b11;
    else sync_rst          <= {sync_rst[0], 1'b0};
end

assign rst = sync_rst[1];

// Делитель частоты 100 MHz -> 25 MHz
clock_divider clock_div 
(
    .clk(clk),
    .rst(rst),
    .clk_vga(clk_vga)
);
   
// PS/2 клавиатура
wire [7:0] key_code;
wire key_ready;

ps2_controller ps2_ctrl 
(
    .clk(clk),
    .rst(rst),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .key(key_code),
    .key_valid(key_ready)
);

// Курсор 
wire [9:0] cursor_x;
wire [9:0] cursor_y;

cursor_controller cursor_ctrl 
(
    .clk(clk),
    .rst(rst),
    .key_code(key_code),
    .key_valid(key_ready),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y)
);   
    
// VGA
VGA_display display 
(
    .clk(clk_vga),      
    .rst(rst),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue),
    .cursor_x(cursor_x),
    .cursor_y(cursor_y)
);
    
endmodule
