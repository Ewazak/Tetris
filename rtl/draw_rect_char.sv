/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: draw_rect_char module - draws a single ASCII character at a given position.
*/
module draw_rect_char #(
    parameter ORIGIN_X = 100,
    parameter ORIGIN_Y = 100,
    parameter CHAR_WIDTH  = 8,
    parameter CHAR_HEIGHT = 16,
    parameter SCALE = 1
)(
    input  logic clk,
    input  logic rst,
    input  logic [7:0] char_line_pixels,   // 8-bit font row
    // VGA input signals
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,
    // RGB output
    output logic [11:0] rgb_out
);

    logic [2:0] pixel_bit;
    logic [11:0] rgb_nxt;

    assign pixel_bit = 7 - (((hcount - ORIGIN_X)/SCALE) % CHAR_WIDTH);

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