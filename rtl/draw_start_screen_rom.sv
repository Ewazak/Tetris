module draw_start_screen_rom (
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

    localparam IMAGE_WIDTH  = 128;
    localparam IMAGE_HEIGHT = 64;
    localparam XPOS = 556; // center horizontally (1240 - 128)/2
    localparam YPOS = 352; // center vertically (768 - 64)/2

    logic [11:0] rgb_nxt;
    logic [11:0] pixel_color;
    logic [12:0] pixel_addr; // 128 * 64 = 8192 = 13 bits

    // ROM containing image data (from start_screen.data)
    logic [11:0] rom [0:8191];
    initial $readmemh("../rtl/start_screen.dat", rom);

    always_ff @(posedge clk) begin : reg_out
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync  <= '0;
            out.hblnk  <= '0;
            out.rgb    <= '0;
        end else begin
            out.vcount <= vcount_in;
            out.vsync  <= vsync_in;
            out.vblnk  <= vblnk_in;
            out.hcount <= hcount_in;
            out.hsync  <= hsync_in;
            out.hblnk  <= hblnk_in;
            out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : comb_out
        if (vblnk_in || hblnk_in)
            rgb_nxt = 12'h000;
        else if (vcount_in >= YPOS && vcount_in < YPOS + IMAGE_HEIGHT &&
                 hcount_in >= XPOS && hcount_in < XPOS + IMAGE_WIDTH) begin
            pixel_addr = (vcount_in - YPOS) * IMAGE_WIDTH + (hcount_in - XPOS);
            rgb_nxt = rom[pixel_addr];
        end else
            rgb_nxt = 12'hF000; // background
    end

endmodule