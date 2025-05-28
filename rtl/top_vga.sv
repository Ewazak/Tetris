/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

 module top_vga (
    input  logic clk,
    input logic clk100MHz,
    input  logic rst,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,

    inout   ps2_clk,
    inout   ps2_data
);

    timeunit 1ns;
    timeprecision 1ps;

    vga_if draw_rect();
    vga_if draw_bg();
    vga_if draw_mouse();
    vga_if draw_rect_char();
    vga_if draw_rect_char_2();

    logic [11:0] xpos, ypos;
    logic [11:0] xpos_bufor, ypos_bufor;
    logic left, right, middle;
    logic [11:0] rgb_pixel;
    logic [11:0] pixel_addr;
    logic [11:0] address;
    logic [11:0] rgb;
    logic [11:0] xpos_ctl, ypos_ctl;
    logic [10:0] addr;
    logic [10:0] addr_2;
    logic [7:0] char_line_pixels;
    logic [7:0] char_line_pixels_2;
    logic [3:0] char_line;
    logic [3:0] char_line_2;
    logic [6:0] char_code;
    logic [6:0] char_code_2;
    logic [7:0] char_xy;
    logic [7:0] char_xy_2;

    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    assign vs = draw_mouse.vsync;
    assign hs = draw_mouse.hsync;
    assign {r, g, b} = draw_mouse.rgb;

    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .vcount(vcount_tim),
        .vsync(vsync_tim),
        .vblnk(vblnk_tim),
        .hcount(hcount_tim),
        .hsync(hsync_tim),
        .hblnk(hblnk_tim)
    );

    draw_bg u_draw_bg (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .out(draw_bg)
    );

    draw_rect u_draw_rect (
        .clk(clk),
        .rst(rst),
        .xpos(xpos_ctl),
        .ypos(ypos_ctl),
        .in(draw_rect_char_2),
        .out(draw_rect),
        .rgb_pixel(rgb),
        .pixel_addr(pixel_addr)
    );

    draw_rect_char #(
        .CHAR_X(70),
        .CHAR_Y(70)
    ) u_draw_rect_char (
        .clk(clk),
        .rst(rst),
        .char_line_pixels(char_line_pixels),
        .char_xy(char_xy),
        .char_line(char_line),
        .in(draw_bg),
        .out(draw_rect_char)
    );

     draw_rect_char #(
        .CHAR_X(350),
        .CHAR_Y(350)
    ) u_draw_rect_char_2 (
        .clk(clk),
        .rst(rst),
        .char_line_pixels(char_line_pixels_2),
        .char_xy(char_xy_2),
        .char_line(char_line_2),
        .in(draw_rect_char),
        .out(draw_rect_char_2)
    );

    draw_mouse u_draw_mouse (
        .clk(clk),
        .xpos(xpos_bufor),
        .ypos(ypos_bufor),
        .in(draw_rect),
        .out(draw_mouse),
        .rst(rst)
    );

    bufor_tim u_bufor_tim (
        .clk(clk),
        .rst(rst),
        .xpos(xpos),
        .ypos(ypos),
        .xpos_bufor(xpos_bufor),
        .ypos_bufor(ypos_bufor)
    );

    MouseCtl u_MouseCtl (
        .clk(clk100MHz),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos),
        .ypos(ypos),
        .left(left),
        .right(right),
        .middle(middle),
        .rst(rst),
        .value(),
        .setx(),
        .sety(),
        .setmax_x(),
        .setmax_y(),
        .new_event(),
        .zpos()
    );

    image_rom u_image_rom (
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb)
    );

    draw_rect_ctl u_draw_rect_ctl (
        .clk(clk),
        .rst(rst),
        .xpos(xpos_ctl),
        .ypos(ypos_ctl),
        .mouse_xpos(xpos),
        .mouse_ypos(ypos),
        .mouse_left(left)
    );

    font_rom u_font_rom(
        .clk(clk),
        .addr(addr),
        .char_line_pixels(char_line_pixels)
    );

     font_rom u_font_rom_2(
        .clk(clk),
        .addr(addr_2),
        .char_line_pixels(char_line_pixels_2)
    );

    char_rom u_char_rom(
        .clk(clk),
        .char_xy(char_xy),
        .char_code(char_code)
    );

    char_rom u_char_rom_2(
        .clk(clk),
        .char_xy(char_xy_2),
        .char_code(char_code_2)
    );

    assign addr = {char_code, char_line};
    assign addr_2 = {char_code_2, char_line_2};

endmodule