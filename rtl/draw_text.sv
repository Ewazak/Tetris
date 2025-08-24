/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: draw_text module - renders text string on the screen by using multiple "draw_rect_char" module.
*/
module draw_text #(
    parameter int SCALE       = 4,
    parameter int LEN         = 5,
    parameter string LINE     = "ERROR",   
    parameter int FROM_MIDDLE = 35
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,
    output logic [11:0] rgb_out
);

    import vga_pkg::*;

    // Array of ASCII codes 
    logic [6:0] TEXT [0:LEN-1];

    always_comb begin
        for (int i = 0; i < LEN; i++) begin
            if (i < LINE.len())
                TEXT[i] = LINE[i];
            else
                TEXT[i] = " ";
        end
    end

    // Calculate text position on the screen
    localparam int TEXT_PIXEL_WIDTH  = LEN * 8 * SCALE;
    localparam int TEXT_ORIGIN_X     = (HOR_PIXELS - TEXT_PIXEL_WIDTH)/2;
    localparam int TEXT_ORIGIN_Y     = VER_PIXELS/2 + FROM_MIDDLE;

    logic [11:0] draw_rgb [0:LEN-1];

    // Generate characters using draw_rect_char
    generate
        for (genvar i = 0; i < LEN; i++) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(TEXT_ORIGIN_X + i*8*SCALE),
                .ORIGIN_Y(TEXT_ORIGIN_Y),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(TEXT[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb[i])
            );
        end
    endgenerate

    // Merge character outputs into a single RGB signal
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        for (int i = 0; i < LEN; i++) begin
            if (draw_rgb[i] != rgb_in) begin
                rgb_nxt = draw_rgb[i];
                break;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst)
            rgb_out <= 12'h000;
        else
            rgb_out <= rgb_nxt;
    end

endmodule