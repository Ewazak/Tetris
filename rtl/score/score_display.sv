module score_display (
    input  logic clk,
    input  logic rst,
    input  logic [15:0] score,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,
    output logic [11:0] rgb_out
);

// Konwersja bin - ASCII
    logic [6:0] ascii_digits[4:0];
    bin_ascii_sync bin_ascii_inst (
        .clk(clk),
        .rst(rst),
        .bin_in(score),
        .ascii_0(ascii_digits[0]),
        .ascii_1(ascii_digits[1]),
        .ascii_2(ascii_digits[2]),
        .ascii_3(ascii_digits[3]),
        .ascii_4(ascii_digits[4])
    );
    
// Tekst "SCORE:" + cyfry
    logic [6:0] char_text[10:0];
    always_comb begin
        char_text[0] = "S"; char_text[1] = "C"; char_text[2] = "O";
        char_text[3] = "R"; char_text[4] = "E"; char_text[5] = ":";
        for (int i = 0; i < 5; i++)
            char_text[6 + i] = ascii_digits[i];
    end

// Rysowanie znaków
    logic [11:0] draw_rgb[10:0];
    generate
        for (genvar i = 0; i < 11; i++) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(10 + i*8),
                .ORIGIN_Y(10)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(char_text[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb[i])
            );
        end
    endgenerate

// Scalanie RGB z wszystkich znaków
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        for (int i = 0; i < 11; i++) begin
            if (draw_rgb[i] != rgb_in) begin
                rgb_nxt = draw_rgb[i];
                break;
            end
        end
    end

    assign rgb_out = rgb_nxt;

endmodule