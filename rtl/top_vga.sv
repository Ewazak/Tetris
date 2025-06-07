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
    input  logic clk100MHz,
    input  logic rst,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,

    inout  ps2_clk,
    inout  ps2_data,
    input  logic enter_pressed,       // dodane wejście do FSM
    input  logic game_over_flag       // dodane wejście do FSM
);

    timeunit 1ns;
    timeprecision 1ps;

    // VGA sygnały pośrednie
    vga_if vga_start_screen_rom();
    vga_if vga_game();
    vga_if vga_final();

    logic [11:0] xpos, ypos;
    logic [11:0] xpos_bufor, ypos_bufor;
    logic left, right, middle;

    wire [10:0] vcount_tim, hcount_tim;
    wire        vsync_tim, hsync_tim;
    wire        vblnk_tim, hblnk_tim;

    // FSM sygnały stanu
    logic in_game, in_start_screen, in_game_over;

    // -----------------------------
    // GENERATOR SYGNAŁÓW VGA
    // -----------------------------
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

    // -----------------------------
    // EKRAN STARTOWY
    // -----------------------------
    draw_start_screen_rom u_draw_start_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .in(vga_start_screen_rom), // nie używany (można usunąć z interfejsu jeśli niepotrzebny)
        .out(vga_start_screen_rom)
    );

    // -----------------------------
    // STEROWANIE STANEM GRY
    // -----------------------------
    game_controller u_game_controller (
        .clk(clk),
        .rst(rst),
        .enter_pressed(enter_pressed),
        .game_over_flag(game_over_flag),
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over)
    );

    // -----------------------------
    // MULTIPLEXING OBRAZU
    // -----------------------------
    assign vga_final.vcount = in_start_screen ? vga_start_screen_rom.vcount : vga_game.vcount;
    assign vga_final.vsync  = in_start_screen ? vga_start_screen_rom.vsync  : vga_game.vsync;
    assign vga_final.vblnk  = in_start_screen ? vga_start_screen_rom.vblnk  : vga_game.vblnk;
    assign vga_final.hcount = in_start_screen ? vga_start_screen_rom.hcount : vga_game.hcount;
    assign vga_final.hsync  = in_start_screen ? vga_start_screen_rom.hsync  : vga_game.hsync;
    assign vga_final.hblnk  = in_start_screen ? vga_start_screen_rom.hblnk  : vga_game.hblnk;
    assign vga_final.rgb    = in_start_screen ? vga_start_screen_rom.rgb    : vga_game.rgb;

    // Wyjście na monitor
    assign vs = vga_final.vsync;
    assign hs = vga_final.hsync;
    assign {r, g, b} = vga_final.rgb;

    // -----------------------------
    // MYSZ
    // -----------------------------

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

    logic [2:0] current_block_type;
logic load_new_block;

// instancja generatora
block_randomizer u_block_randomizer (
    .clk(clk),
    .rst(rst),
    .load_new(load_new_block),
    .block_type(current_block_type)
);

// Przykładowe wartości do modułu block
logic [1:0] rotation;
logic [1:0] x_in, y_in;
logic occupied_pixel;

block u_block (
    .block_type(current_block_type),
    .rotation(rotation),
    .x(x_in),
    .y(y_in),
    .occupied(occupied_pixel)
);

endmodule