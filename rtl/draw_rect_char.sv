/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: draw_rect_char module - draws a single ASCII character at a given position.
*/
module draw_rect_char #(
    parameter int ORIGIN_X = 100,
    parameter int ORIGIN_Y = 100,
    parameter int CHAR_WIDTH  = 8,
    parameter int CHAR_HEIGHT = 16,
    parameter int SCALE = 1
)(
    input  logic clk,
    input  logic rst,
    input  logic [6:0] char_code,
    // VGA input signals
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,
    // RGB output
    output logic [11:0] rgb_out
);

    logic [3:0] char_line;
    logic [2:0] pixel_bit;
    logic [7:0] char_line_pixels;
    logic [11:0] rgb_nxt;

    assign char_line = ((vcount - ORIGIN_Y)/SCALE) % CHAR_HEIGHT;
    assign pixel_bit = 7 - (((hcount - ORIGIN_X)/SCALE) % CHAR_WIDTH);

// Font ROM instance
    font_rom rom_inst (
        .clk(clk),
        .addr({char_code, char_line}),
        .char_line_pixels(char_line_pixels)
    );

    always_comb begin
        if (vblnk || hblnk) begin
            rgb_nxt = rgb_in;
        end else if (vcount >= ORIGIN_Y && vcount < ORIGIN_Y + CHAR_HEIGHT*SCALE &&
                     hcount >= ORIGIN_X && hcount < ORIGIN_X + CHAR_WIDTH*SCALE) begin
            if (char_line_pixels[pixel_bit])
                rgb_nxt = 12'hFFF;
            else
                rgb_nxt = rgb_in;
        end else begin
            rgb_nxt = rgb_in;
        end
    end

    always_ff @(posedge clk) begin
        if (rst)
            rgb_out <= 12'h000;
        else
            rgb_out <= rgb_nxt;
    end

endmodule