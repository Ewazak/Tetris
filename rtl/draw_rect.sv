module draw_rect (
    input logic clk,
    input logic rst,
    input logic [11:0] xpos,
    input logic [11:0] ypos,
    input logic [11:0] rgb_pixel,
    output logic [11:0] pixel_addr,
    vga_if.in in,
    vga_if.out out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    localparam RECT_WIDTH = 48;
    localparam RECT_HEIGHT = 64;

    logic [11:0] rgb_nxt;
    logic [11:0] rgb_d1, rgb_d2;
    logic [10:0] hcount_d1, hcount_d2;
    logic [11:0] xpos_d1, xpos_d2 ;
    logic [10:0] vcount_d1, vcount_d2;
    logic [11:0] ypos_d1, ypos_d2;
    logic hblnk_d1, hblnk_d2;
    logic vblnk_d1, vblnk_d2;
    logic hsync_d1, hsync_d2;
    logic vsync_d1, vsync_d2;

    //Delays
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_d1 <= '0;
            ypos_d1 <= '0;
            vblnk_d1 <= '0;
            xpos_d1 <= '0;
            hcount_d1 <= '0;
            hblnk_d1 <= '0;
            rgb_d1 <= '0;
            hsync_d1 <= '0;
            vsync_d1 <= '0;
            pixel_addr <= '0;
        end else begin
            vcount_d1 <= in.vcount;
            ypos_d1 <= ypos;
            vblnk_d1 <= in.vblnk;
            xpos_d1 <= xpos;
            hcount_d1 <= in.hcount;
            hblnk_d1 <= in.hblnk;
            rgb_d1 <= in.rgb;
            hsync_d1 <= in.hsync;
            vsync_d1 <= in.vsync;
            pixel_addr <= {6'(in.vcount - ypos), 6'(in.hcount - xpos)};
        end
    end
    
    
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_d2 <= '0;
            ypos_d2 <= '0;
            vblnk_d2 <= '0;
            xpos_d2 <= '0;
            hcount_d2 <= '0;
            hblnk_d2 <= '0;
            rgb_d2 <= '0;
            hsync_d2 <= '0;
            vsync_d2 <= '0;
        end else begin  
            vcount_d2 <= vcount_d1;
            ypos_d2 <= ypos_d1;
            vblnk_d2 <= vblnk_d1;
            xpos_d2 <= xpos_d1;
            hcount_d2 <= hcount_d1;
            hblnk_d2 <= hblnk_d1;
            rgb_d2 <= rgb_d1;
            hsync_d2 <= hsync_d1;
            vsync_d2 <= vsync_d1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            out.vsync <= '0;
            out.vcount <= '0;
            out.vblnk <= '0;
            out.hsync <= '0;
            out.hcount <= '0;
            out.hblnk <= '0;
            out.rgb <= '0;
        end else begin
            out.vsync <= vsync_d2;
            out.vcount <= vcount_d2;
            out.vblnk <= vblnk_d2;
            out.hsync <= hsync_d2;
            out.hcount <= hcount_d2;
            out.hblnk <= hblnk_d2;
            out.rgb <= rgb_nxt;
        end
    end
    
    
    always_comb begin : rect_comb_blk
        if ((vcount_d2 >= ypos_d2) && (vcount_d2 < (ypos_d2 + RECT_HEIGHT)) &&
            (hcount_d2 >= xpos_d2) && (hcount_d2 < (xpos_d2 + RECT_WIDTH)) &&
            !vblnk_d2 && !hblnk_d2) begin
                rgb_nxt = rgb_pixel;
            end else begin
                rgb_nxt = rgb_d2;
            end
    end

endmodule



