`timescale 1ns / 1ps

module cursor_controller 
(
    input wire clk,
    input wire rst,
    input wire [7:0] key_code,
    input wire key_valid,
    output reg [9:0] cursor_x,
    output reg [9:0] cursor_y
);
parameter GRID_X = 320;
parameter GRID_Y = 50;
parameter CELL_SIZE = 30;
parameter GRID_SIZE = 300;

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        cursor_x <= GRID_X;
        cursor_y <= GRID_Y;
    end 
    else if (key_valid) 
    begin
        case (key_code)
            8'h75: if(cursor_y > GRID_Y) cursor_y <= cursor_y - CELL_SIZE; // стрелка вверх
            8'h72: if(cursor_y < GRID_Y + GRID_SIZE - CELL_SIZE) cursor_y <= cursor_y + CELL_SIZE; // вниз
            8'h6B: if(cursor_x > GRID_X) cursor_x <= cursor_x - CELL_SIZE; // влево
            8'h74: if(cursor_x < GRID_X + GRID_SIZE - CELL_SIZE) cursor_x <= cursor_x + CELL_SIZE; // вправо
            default: ;
        endcase
    end
end

endmodule
