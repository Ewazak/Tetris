/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: draw_start_screen module - displays a scaled start screen image from ROM.
*/
module draw_start_screen #(
    parameter SCALE = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] vcount_in,
    input  logic        vsync_in,
    input  logic        vblnk_in,
    input  logic [10:0] hcount_in,
    input  logic        hsync_in,
    input  logic        hblnk_in,
    vga_if.out          out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    // Original image dimensions in ROM
    localparam IMAGE_WIDTH_ORIG  = 128;
    localparam IMAGE_HEIGHT_ORIG = 96;

    // Scaled image dimensions
    localparam IMAGE_WIDTH  = IMAGE_WIDTH_ORIG * SCALE;
    localparam IMAGE_HEIGHT = IMAGE_HEIGHT_ORIG * SCALE;

    // Image position (center on the screen)
    localparam XPOS = (HOR_PIXELS - IMAGE_WIDTH) / 2;
    localparam YPOS = (VER_PIXELS - IMAGE_HEIGHT) / 2;

    // Signals
    logic [13:0] pixel_addr;       // ROM address
    logic [11:0] pixel_data;       // data from ROM
    logic [11:0] rgb_nxt;

    // ROM instance (small image)
    start_screen_rom rom_inst (
        .clk(clk),
        .addr(pixel_addr),
        .pixel_data(pixel_data)
    );

    // Pipeline 1 - compute ROM address with scalling
    always_ff @(posedge clk) begin
        if (rst) begin
            pixel_addr <= '0;
        end else begin
            if ((hcount_in >= XPOS) && (hcount_in < XPOS + IMAGE_WIDTH) &&
                (vcount_in >= YPOS) && (vcount_in < YPOS + IMAGE_HEIGHT)) begin

                pixel_addr <= ((vcount_in - YPOS) / SCALE) * IMAGE_WIDTH_ORIG +
                              ((hcount_in - XPOS) / SCALE);
            end else begin
                pixel_addr <= 0;
            end
        end
    end

    // Pipeline 2 - ROM read
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb_nxt <= 12'h000;
        end else begin
            rgb_nxt <= pixel_data;
        end
    end

    // Pipeline 3 - delay VGA signals by 2 cycles
    logic [10:0] hcount_d1, vcount_d1, hcount_d2, vcount_d2;
    logic        hsync_d1, vsync_d1, hsync_d2, vsync_d2;
    logic        hblnk_d1, vblnk_d1, hblnk_d2, vblnk_d2;

    always_ff @(posedge clk) begin
        if (rst) begin
            hcount_d1 <= 0; vcount_d1 <= 0;
            hcount_d2 <= 0; vcount_d2 <= 0;
            hsync_d1  <= 0; vsync_d1  <= 0;
            hsync_d2  <= 0; vsync_d2  <= 0;
            hblnk_d1  <= 0; vblnk_d1  <= 0;
            hblnk_d2  <= 0; vblnk_d2  <= 0;
        end else begin
            // 1st delay cycle
            hcount_d1 <= hcount_in;
            vcount_d1 <= vcount_in;
            hsync_d1  <= hsync_in;
            vsync_d1  <= vsync_in;
            hblnk_d1  <= hblnk_in;
            vblnk_d1  <= vblnk_in;

            // 2nd delay cycle
            hcount_d2 <= hcount_d1;
            vcount_d2 <= vcount_d1;
            hsync_d2  <= hsync_d1;
            vsync_d2  <= vsync_d1;
            hblnk_d2  <= hblnk_d1;
            vblnk_d2  <= vblnk_d1;
        end
    end

    // Pipeline 4 - output
    always_ff @(posedge clk) begin
        if (rst) begin
            out.hcount <= 0;
            out.vcount <= 0;
            out.hsync  <= 0;
            out.vsync  <= 0;
            out.hblnk  <= 0;
            out.vblnk  <= 0;
            out.rgb    <= 12'h000;
        end else begin
            out.hcount <= hcount_d2;
            out.vcount <= vcount_d2;
            out.hsync  <= hsync_d2;
            out.vsync  <= vsync_d2;
            out.hblnk  <= hblnk_d2;
            out.vblnk  <= vblnk_d2;

            if (hblnk_d2 || vblnk_d2) begin
                out.rgb <= 12'h000; // blanking
            end else if ((hcount_d2 >= XPOS) && (hcount_d2 < XPOS + IMAGE_WIDTH) &&
                         (vcount_d2 >= YPOS) && (vcount_d2 < YPOS + IMAGE_HEIGHT)) begin
                out.rgb <= rgb_nxt;
            end else begin
                out.rgb <= 12'hF00; // background
            end
        end
    end

endmodule
