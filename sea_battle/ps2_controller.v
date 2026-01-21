module ps2_controller 
(
    input  wire clk,
    input  wire rst,
    input  wire ps2_clk,
    input  wire ps2_data,
    output reg  [7:0] key,
    output reg       key_valid
);
// синхронизируем линии
reg [1:0] ps2_clk_s, ps2_data_s;
reg ps2_clk_prev;

always @(posedge clk) 
begin
    ps2_clk_s  <= {ps2_clk_s[0], ps2_clk};
    ps2_data_s <= {ps2_data_s[0], ps2_data};
    ps2_clk_prev <= ps2_clk_s[1];
end
wire ps2_clk_f  = ps2_clk_s[1];
wire ps2_data_f = ps2_data_s[1];

reg [3:0] bitcnt;
reg [7:0] shift_byte;
reg got_e0; // префикс E0

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        bitcnt <= 0;
        shift_byte <= 8'd0;
        key <= 8'd0;
        key_valid <= 1'b0;
        got_e0 <= 1'b0;
    end 
    else 
    begin
        key_valid <= 1'b0;
        // обнаружение падающего фронта ps2_clk
        if (ps2_clk_prev && !ps2_clk_f) begin
            if (bitcnt == 0) begin
                // стартовый бит, ожидаем 1..8 — ничего не делаем с ним
                bitcnt <= 1;
            end else if (bitcnt >= 1 && bitcnt <= 8) begin
                // биты данных (LSB first)
                shift_byte <= {ps2_data_f, shift_byte[7:1]};
                bitcnt <= bitcnt + 1;
            end else if (bitcnt == 9) begin
                // parity (пропускаем)
                bitcnt <= bitcnt + 1;
            end else if (bitcnt == 10) begin
                // стоп-бит — полный байт собран
                bitcnt <= 0;
                // обработаем байт
                if (shift_byte == 8'hE0) begin
                    got_e0 <= 1'b1; // следующий байт расширенный
                end else if (shift_byte == 8'hF0) begin
                    // break — игнорируем (нажатие/отпускание не обрабатываем)
                    got_e0 <= 1'b0;
                end else begin
                    // make code — выдаём наружу (можно учитывать got_e0, если нужно)
                    key <= shift_byte;
                    key_valid <= 1'b1;
                    got_e0 <= 1'b0;
                end
            end
        end
    end
end

endmodule
