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
    input  logic enter_pressed,
    input  logic game_over_flag
);

    timeunit 1ns;
    timeprecision 1ps;

    // VGA sygnały pośrednie
    vga_if vga_start_screen_rom();
    vga_if vga_game();
    vga_if vga_final();

    // Pozycje i przyciski myszy
    logic [11:0] xpos, ypos;
    logic left, right, middle;

    // Parametry klocka
    logic [3:0][3:0] current_block_map;
    logic [2:0] current_block_type;
    logic [1:0] rotation;
    logic [1:0] x_in, y_in;
    logic occupied_pixel;

    // Pozycja klocka w pikselach
    logic [10:0] block_pos_x = 100;  // np. środek planszy
    logic [10:0] block_pos_y = 50;

    // FSM sygnały stanu
    logic in_game, in_start_screen, in_game_over;

    // VGA sygnały
    wire [10:0] hcount_tim, vcount_tim;
    wire hsync_tim, vsync_tim, hblnk_tim, vblnk_tim;

    // Plansza 10x20: tablica z typami klocków
    logic [2:0] board [0:9][0:19];

    // Blok koloru z planszy
    logic [11:0] board_rgb;
    logic [11:0] block_rgb;

    // Wybrany kolor końcowy
    logic [11:0] final_rgb;

    // ---------------------------------------
    // VGA timing
    // ---------------------------------------
    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .hcount(hcount_tim),
        .hsync(hsync_tim),
        .hblnk(hblnk_tim),
        .vcount(vcount_tim),
        .vsync(vsync_tim),
        .vblnk(vblnk_tim)
    );

    // ---------------------------------------
    // Start screen
    // ---------------------------------------
    draw_start_screen #(
    .SCALE(8)
    )u_draw_start_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .out(vga_start_screen_rom)
    );
    // ---------------------------------------
    // FSM kontroler gry
    // ---------------------------------------
    logic block_placed;
    logic load_new_block;

    game_controller u_game_controller (
        .clk(clk),
        .rst(rst),
        .enter_pressed(enter_pressed),
        .game_over_flag(game_over_flag),
        .block_placed(block_placed),
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over),
        .load_new_block(load_new_block)
    );

    // ---------------------------------------
    // Obsługa myszy
    // ---------------------------------------
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

    // ---------------------------------------
    // Generator i mapa klocka
    // ---------------------------------------
    block_randomizer u_block_randomizer (
        .clk(clk),
        .rst(rst),
        .load_new(load_new_block),
        .block_type(current_block_type)
    );

    block_generator u_block_generator (
        .block_type(current_block_type),
        .rotation(rotation),
        .block_map(current_block_map)
    );

    assign occupied_pixel = current_block_map[y_in][x_in];

    // ---------------------------------------
    // Rysowanie aktualnego klocka
    // ---------------------------------------
    block_draw u_block_draw (
        .hcount(hcount_tim),
        .vcount(vcount_tim),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .block_map(current_block_map),
        .block_type(current_block_type),
        .rgb_out(block_rgb)
    );

    // ---------------------------------------
    // Renderowanie planszy (w tle)
    // ---------------------------------------
    board_renderer u_board_renderer (
        .clk(clk),
        .hcount(hcount_tim),
        .vcount(vcount_tim),
        .board(board),
        .rgb_out(board_rgb)
    );

    game_logic u_game_logic (
        .clk(clk),
        .rst(rst),
        .load_new_block(load_new_block),
        .block_type(current_block_type),
        .block_map(current_block_map),
        .block_placed(block_placed),
        .board(board)
    );

    // ---------------------------------------
    // MUX: co pokazywać
    // ---------------------------------------
    always_comb begin
        if (in_start_screen)
            final_rgb = vga_start_screen_rom.rgb;
        else begin
            // Jeśli piksel należy do klocka -> pokaż klocka
            final_rgb = (block_rgb != 12'h000) ? block_rgb : board_rgb;
        end
    end

    // ---------------------------------------
    // Przypisanie sygnałów końcowych
    // ---------------------------------------
    assign vs = vsync_tim;
    assign hs = hsync_tim;
    assign {r, g, b} = final_rgb;

endmodule