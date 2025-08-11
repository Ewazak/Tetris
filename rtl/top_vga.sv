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
    input  logic rst,
    input  logic rx,
    output logic tx,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    input  logic ps2_clk,
    input  logic ps2_data,
    input  logic game_over_flag
);

    // -----------------------------
    // Połączenie z logiką gry
    // -----------------------------
    logic [2:0]  board [0:199];
    logic [15:0] my_score, enemy_score;
    logic [3:0][3:0] current_block_map;
    logic [2:0]  current_block_type;
    logic [10:0] block_pos_x, block_pos_y;
    logic        block_placed;

    top_game u_top_game (
        .clk(clk),
        .rst(rst),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .rx(rx),
        .tx(tx),
        .game_over_flag(game_over_flag),
        .board(board),
        .my_score(my_score),
        .enemy_score(enemy_score),
        .current_block_map(current_block_map),
        .current_block_type(current_block_type),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .block_placed(block_placed)
    );

    // -----------------------------
    // VGA timing
    // -----------------------------
    wire [10:0] hcount, vcount;
    wire hblnk, vblnk;
    wire hsync, vsync;

    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .hcount(hcount),
        .hsync(hsync),
        .hblnk(hblnk),
        .vcount(vcount),
        .vsync(vsync),
        .vblnk(vblnk)
    );

    // -----------------------------
    // Render planszy
    // -----------------------------
    logic [11:0] board_rgb;
    board_renderer u_board_renderer (
        .clk(clk),
        .hcount(hcount),
        .vcount(vcount),
        .board(board),
        .rgb_out(board_rgb)
    );

    // -----------------------------
    // Render aktywnego klocka
    // -----------------------------
    logic [11:0] block_rgb;
    block_draw u_block_draw (
        .hcount(hcount),
        .vcount(vcount),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .block_map(current_block_map),
        .block_type(current_block_type),
        .rgb_out(block_rgb)
    );

    // -----------------------------
    // Tło gry (np. ROM z grafiką)
    // -----------------------------
    vga_if vga_game();
    draw_game_screen #(
        .SCALE(16)
    ) u_draw_game_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount),
        .vsync_in(vsync),
        .vblnk_in(vblnk),
        .hcount_in(hcount),
        .hsync_in(hsync),
        .hblnk_in(hblnk),
        .out(vga_game)
    );

    // -----------------------------
    // MUX RGB
    // -----------------------------
    logic [11:0] final_rgb;
    always_comb begin
        if (block_rgb != 12'h000)
            final_rgb = block_rgb;
        else if (board_rgb != 12'h000)
            final_rgb = board_rgb;
        else
            final_rgb = vga_game.rgb;
    end

    // -----------------------------
    // Wyjścia VGA
    // -----------------------------
    assign vs = vsync;
    assign hs = hsync;
    assign {r, g, b} = final_rgb;

endmodule