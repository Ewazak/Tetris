module draw_rect_char #(
    parameter int CHAR_X = 200,
    parameter int CHAR_Y = 200
)( 
    input  logic clk,
    input  logic rst,
    input  logic [7:0] char_line_pixels,
    output logic [7:0] char_xy,
    output logic [3:0] char_line,


    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    //Parameters
    localparam CHAR_WIDTH     = 8;
    localparam CHAR_HEIGHT    = 16;
    localparam TEXT_COLS      = 32;
    localparam TEXT_ROWS      = 8;  

    logic [11:0] rgb_nxt;
    logic [11:0] rgb_d1, rgb_d2, rgb_d3;
    logic [10:0] hcount_d1, hcount_d2, hcount_d3,
                 vcount_d1, vcount_d2, vcount_d3;
    logic hblnk_d1, hblnk_d2, hblnk_d3,
          vblnk_d1, vblnk_d2, vblnk_d3,
          hsync_d1, hsync_d2, hsync_d3,
          vsync_d1, vsync_d2, vsync_d3;
    logic [7:0] char_xy_nxt;
    logic [3:0] char_line_nxt;
    logic [2:0] pixel_bit; 
    logic [2:0] row_index;
    logic [4:0] col_index;

    //Delay 1
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_d1 <= '0;
            vblnk_d1  <= '0;
            hcount_d1 <= '0;
            hblnk_d1  <= '0;
            hsync_d1  <= '0;
            vsync_d1  <= '0;
        end else begin
            vcount_d1 <= in.vcount;
            vblnk_d1  <= in.vblnk;
            hcount_d1 <= in.hcount;
            hblnk_d1  <= in.hblnk;
            hsync_d1  <= in.hsync;
            vsync_d1  <= in.vsync;
        end
    end

    //Delay 2
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_d2 <= '0;
            vblnk_d2  <= '0;
            hcount_d2 <= '0;
            hblnk_d2  <= '0;
            hsync_d2  <= '0;
            vsync_d2  <= '0;
        end else begin
            vcount_d2 <= vcount_d1;
            vblnk_d2  <= vblnk_d1;
            hcount_d2 <= hcount_d1;
            hblnk_d2  <= hblnk_d1;
            hsync_d2  <= hsync_d1;
            vsync_d2  <= vsync_d1;
        end
    end

    //Delay 3
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_d3 <= '0;
            vblnk_d3  <= '0;
            hcount_d3 <= '0;
            hblnk_d3  <= '0;
            hsync_d3  <= '0;
            vsync_d3  <= '0;
        end else begin
            vcount_d3 <= vcount_d2;
            vblnk_d3  <= vblnk_d2;
            hcount_d3 <= hcount_d2;
            hblnk_d3  <= hblnk_d2;
            hsync_d3  <= hsync_d2;
            vsync_d3  <= vsync_d2;
        end
    end

    //Delay 4 (out)
    always_ff @(posedge clk) begin
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync  <= '0;
            out.hblnk  <= '0;
            out.rgb    <= '0;
            char_xy <= '0;
            char_line <= '0;
        end else begin
            out.vcount <= vcount_d3;
            out.vblnk  <= vblnk_d3;
            out.hcount <= hcount_d3;
            out.hblnk  <= hblnk_d3;
            out.hsync  <= hsync_d3;
            out.vsync  <= vsync_d3;
            out.rgb    <= rgb_nxt;
            char_xy <= char_xy_nxt;
            char_line <= char_line_nxt;
        end
    end

    always_comb begin
    row_index = (in.vcount - CHAR_Y) >> 4;
    col_index = (in.hcount - CHAR_X) >> 3;
    char_xy_nxt = {row_index, col_index};
    char_line_nxt = (vcount_d1 - CHAR_Y);
    pixel_bit = (hcount_d3 - CHAR_X);
    end

    always_comb begin
        if ((vcount_d3 >= CHAR_Y) && (vcount_d3 < (CHAR_HEIGHT*TEXT_ROWS)+ CHAR_Y) && 
           (hcount_d3 >= CHAR_X) && (hcount_d3 < (CHAR_WIDTH*TEXT_COLS)+ CHAR_X)) begin

            if (char_line_pixels[7 - pixel_bit]) begin
                rgb_nxt = 12'hFFF;
            end else begin
                rgb_nxt = in.rgb;
            end
        end else begin
            rgb_nxt = in.rgb;
        end
    
    end

endmodule