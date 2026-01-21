`timescale 1ns / 1ps

module VGA_display 
(
    input wire clk,
    input wire rst,
    output reg hsync,
    output reg vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    input wire [9:0] cursor_x,
    input wire [9:0] cursor_y
);

parameter H_DISPLAY = 640;
parameter H_FRONT = 16;
parameter H_SYNC = 96;
parameter H_BACK = 48;
parameter H_TOTAL = 800;
    
parameter V_DISPLAY = 480;
parameter V_FRONT = 10;
parameter V_SYNC = 2;
parameter V_BACK = 33;
parameter V_TOTAL = 525;
    
parameter GRID1_X = 20;
parameter GRID1_Y = 50;
parameter GRID2_X = 320;
parameter GRID2_Y = 50;
parameter CELL_SIZE = 30;
parameter GRID_SIZE = 300;

reg [9:0] h_count;
reg [9:0] v_count;
wire [9:0] pixel_x, pixel_y;
wire display_enable;

assign pixel_x = h_count;
assign pixel_y = v_count;
assign display_enable = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        h_count <= 0;
        v_count <= 0;
        hsync <= 1;
        vsync <= 1;
        red <= 0;
        green <= 0;
        blue <= 0;
    end 
    else 
    begin
        if (h_count < H_TOTAL - 1) h_count <= h_count + 1;
        else 
        begin
            h_count <= 0;
            if (v_count < V_TOTAL - 1) v_count <= v_count + 1;
            else v_count <= 0;
        end

        hsync <= ~((h_count >= H_DISPLAY + H_FRONT) && (h_count < H_DISPLAY + H_FRONT + H_SYNC));
        vsync <= ~((v_count >= V_DISPLAY + V_FRONT) && (v_count < V_DISPLAY + V_FRONT + V_SYNC));

        if (!display_enable) 
        begin
            red <= 0; green <= 0; blue <= 0;
        end 
        else 
        begin
            // Фон
            red <= 0; green <= 0; blue <= 8;

            // Игровое поле игрока
            if ((pixel_x >= GRID1_X) && (pixel_x < GRID1_X + GRID_SIZE) &&
                (pixel_y >= GRID1_Y) && (pixel_y < GRID1_Y + GRID_SIZE)) 
            begin
                if (((pixel_x - GRID1_X) % CELL_SIZE == 0) || ((pixel_y - GRID1_Y) % CELL_SIZE == 0)) 
                begin
                    red <= 15; green <= 15; blue <= 15;
                end 
                else 
                begin
                    red <= 0; green <= 6; blue <= 0;
                end
            end

            // Поле противника
            if ((pixel_x >= GRID2_X) && (pixel_x < GRID2_X + GRID_SIZE) &&
                (pixel_y >= GRID2_Y) && (pixel_y < GRID2_Y + GRID_SIZE)) 
            begin
                if (((pixel_x - GRID2_X) % CELL_SIZE == 0) || ((pixel_y - GRID2_Y) % CELL_SIZE == 0)) 
                begin
                    red <= 15; green <= 15; blue <= 15;
                end 
                else 
                begin
                    red <= 6; green <= 0; blue <= 0;
                end
            end

            // Курсор игрока (желтый квадрат)
            if ((pixel_x >= cursor_x) && (pixel_x < cursor_x + CELL_SIZE) &&
                (pixel_y >= cursor_y) && (pixel_y < cursor_y + CELL_SIZE)) 
            begin
                red <= 15; green <= 15; blue <= 0;
            end
        end
    end
end

endmodule
