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
    output logic game_over_flag
);
    
    import vga_pkg::*;

    // -----------------------------
    // Połączenie z logiką gry
    // -----------------------------
    logic [2:0]  board [0:199];
    logic [15:0] my_score, enemy_score;
    logic [3:0][3:0] current_block_map;
    logic [2:0]  current_block_type;
    logic [10:0] block_pos_x, block_pos_y;
    logic        block_placed;
    logic in_game, in_start_screen, in_game_over;
    
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
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over),
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
    // Parametry VGA
    localparam BLOCK_SIZE = 32;

    // Wymiary planszy w klockach
    localparam BOARD_WIDTH_BLOCKS = 10;
    localparam BOARD_HEIGHT_BLOCKS = 20;

    // Obliczanie wyśrodkowanej pozycji planszy w pikselach
    localparam BOARD_WIDTH_PIXELS = BOARD_WIDTH_BLOCKS * BLOCK_SIZE;
    localparam BOARD_HEIGHT_PIXELS = BOARD_HEIGHT_BLOCKS * BLOCK_SIZE;
    localparam BOARD_X_CENTERED = (HOR_PIXELS - BOARD_WIDTH_PIXELS) / 2;
    localparam BOARD_Y_CENTERED = (VER_PIXELS - BOARD_HEIGHT_PIXELS) / 2;
    
    logic [11:0] board_rgb;
    logic is_board_pixel_drawn;
    logic [3*200-1:0] board_flat;

    always_comb begin
        integer i;
        for (i = 0; i < 200; i++) begin
            board_flat[i*3 +: 3] = board[i];
        end
    end

    board_renderer #(
    .BOARD_X(BOARD_X_CENTERED),
    .BOARD_Y(BOARD_Y_CENTERED),
    .BLOCK_SIZE(BLOCK_SIZE)
    ) u_board_renderer (
        .hcount(hcount),
        .vcount(vcount),
        .board_flat(board_flat),
        .is_board_pixel_drawn(is_board_pixel_drawn),
        .rgb_out(board_rgb)
    );

    // -----------------------------
    // Render aktywnego klocka
    // -----------------------------
    logic [11:0] block_rgb;
    logic is_block_pixel_drawn;
    block_draw u_block_draw (
        .hcount(hcount),
        .vcount(vcount),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .block_map(current_block_map),
        .block_type(current_block_type),
        .is_block_pixel_drawn(is_block_pixel_drawn),
        .rgb_out(block_rgb)
    );

    // ---------------------------------------
    // Start screen
    // ---------------------------------------
    vga_if vga_start_screen();
    draw_start_screen #(
    .SCALE(8)
    )u_draw_start_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount),
        .vsync_in(vsync),
        .vblnk_in(vblnk),
        .hcount_in(hcount),
        .hsync_in(hsync),
        .hblnk_in(hblnk),
        .out(vga_start_screen)
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
        if (in_start_screen) begin
            final_rgb = vga_start_screen.rgb;
        end else if (in_game) begin
        // Kolejność: klocek > plansza > tło z ROM-u
            if (is_block_pixel_drawn)
                final_rgb = block_rgb;
            else if (is_block_pixel_drawn)
                final_rgb = board_rgb;
            else
            final_rgb = vga_game.rgb;  // tło z ROM-u
        end else begin
            final_rgb = 12'h000; // fallback na czarne
        end
    end

    // -----------------------------
    // Wyjścia VGA
    // -----------------------------
    assign vs = vsync;
    assign hs = hsync;
    assign {r, g, b} = final_rgb;

endmodule