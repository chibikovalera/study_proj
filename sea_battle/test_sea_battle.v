`timescale 1ns / 1ps

// Тестовый модуль
module test_sea_battle;
    reg clk;
    reg rst;
    wire hsync, vsync;
    wire [3:0] red, green, blue;
    
    // Внутренние сигналы для отладки
    wire clk_vga;
    wire [9:0] pixel_x, pixel_y;
    wire nrst;
    assign nrst = ~rst;
    
    sea_battle dut (
        .clk(clk),
        .sys_nrst(nrst),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .ps2_data(),
        .ps2_clk()
    );
    
    // Доступ к внутренним сигналам
    assign clk_vga = dut.clk_vga;
    assign pixel_x = dut.display.pixel_x;  // Координаты из VGA модуля
    assign pixel_y = dut.display.pixel_y;
    
    // Такт 100 MHz
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        
        $display("=== Starting Simulation ===");
        $display("Time: %0t, rst=%b", $time, rst);
        
        #100;
        rst = 0;
        $display("Time: %0t, rst=%b", $time, rst);
        
        #2000000;
        $display("=== Simulation Finished ===");
        $finish;
    end
    
    // Мониторинг координат и цветов
    integer frame_count = 0;
    always @(posedge vsync) begin
        frame_count <= frame_count + 1;
        $display("Frame %0d completed", frame_count);
        if (frame_count >= 2) begin // Остановить после 2 кадров
            $finish;
        end
    end
    
    // Отслеживание попадания в области полей
    reg in_grid1_prev = 0, in_grid2_prev = 0;
    wire in_grid1, in_grid2;
    
    // Проверка попадания в первое поле (50,50) - (350,350)
    assign in_grid1 = (pixel_x >= 50) && (pixel_x < 350) && 
                      (pixel_y >= 50) && (pixel_y < 350);
    
    // Проверка попадания во второе поле (400,50) - (700,350)
    assign in_grid2 = (pixel_x >= 400) && (pixel_x < 700) && 
                      (pixel_y >= 50) && (pixel_y < 350);
    
    always @(posedge clk_vga) begin
        // Логируем переходы в/из областей полей
        if (in_grid1 && !in_grid1_prev) begin
            $display("ENTER Grid1: time=%0t, pixel_x=%0d, pixel_y=%0d, rgb=%h%h%h", 
                     $time, pixel_x, pixel_y, red, green, blue);
        end
        if (!in_grid1 && in_grid1_prev) begin
            $display("EXIT Grid1:  time=%0t, pixel_x=%0d, pixel_y=%0d", 
                     $time, pixel_x, pixel_y);
        end
        
        if (in_grid2 && !in_grid2_prev) begin
            $display("ENTER Grid2: time=%0t, pixel_x=%0d, pixel_y=%0d, rgb=%h%h%h", 
                     $time, pixel_x, pixel_y, red, green, blue);
        end
        if (!in_grid2 && in_grid2_prev) begin
            $display("EXIT Grid2:  time=%0t, pixel_x=%0d, pixel_y=%0d", 
                     $time, pixel_x, pixel_y);
        end
        
        in_grid1_prev <= in_grid1;
        in_grid2_prev <= in_grid2;
        
        // Логируем несколько конкретных точек
        if (pixel_x == 100 && pixel_y == 100) begin
            $display("Point(100,100): rgb=%h%h%h, in_grid1=%b, in_grid2=%b", 
                     red, green, blue, in_grid1, in_grid2);
        end
        if (pixel_x == 450 && pixel_y == 100) begin
            $display("Point(450,100): rgb=%h%h%h, in_grid1=%b, in_grid2=%b", 
                     red, green, blue, in_grid1, in_grid2);
        end
    end
    
    initial begin
        $dumpfile("debug.vcd");
        $dumpvars(0, test_sea_battle);
    end
    
endmodule
