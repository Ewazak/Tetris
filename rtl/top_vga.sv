/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk, Ewa Żakowska, Adrianna Solińska
 *
 * Description: The project top module.
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
    // Connection with game logic
    // -----------------------------
    logic [2:0]  board [0:199];
    logic [15:0] my_score, enemy_score;
    logic [3:0][3:0] current_block_map;
    logic [2:0]  current_block_type;
    logic [10:0] block_pos_x, block_pos_y;
    logic        block_placed;
    logic in_game, in_start_screen, in_game_over, in_score;
    logic other_ready;
    logic kb_start_flag;
    logic is_player1;

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
        .in_score(in_score),
        .block_placed(block_placed),
        .other_ready(other_ready),
        .kb_start_flag(kb_start_flag),
        .is_player1(is_player1)
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
    // Render board and block
    // -----------------------------
    logic [11:0] board_rgb, block_rgb, points_rgb;
    logic is_board_pixel_drawn, is_block_pixel_drawn;

    logic [3*200-1:0] board_flat;
    always_comb begin
        integer i;
        for (i = 0; i < 200; i++)
            board_flat[i*3 +: 3] = board[i];
    end

    localparam BLOCK_SIZE = 32;
    localparam BOARD_WIDTH_PIXELS = 10 * BLOCK_SIZE;
    localparam BOARD_HEIGHT_PIXELS = 20 * BLOCK_SIZE;
    localparam BOARD_X_CENTERED = (HOR_PIXELS - BOARD_WIDTH_PIXELS)/2;
    localparam BOARD_Y_CENTERED = (VER_PIXELS - BOARD_HEIGHT_PIXELS)/2;

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

    logic [11:0] start_text_rgb;

    draw_text #(
        .SCALE(4),
        .FROM_MIDDLE(35),
        .LEN(14),
        .LINE("ENTER to start")
    ) u_start_screen_text (
        .clk(clk),
        .rst(rst),
        .hcount(hcount),
        .vcount(vcount),
        .hblnk(hblnk),
        .vblnk(vblnk),
        .rgb_in(vga_start_screen.rgb),
        .rgb_out(start_text_rgb)
    );

    logic [11:0] waiting_text_rgb;

    draw_text #(
        .SCALE(4),
        .FROM_MIDDLE(35),
        .LEN(23),
        .LINE("Wait for second player")
    ) u_waiting_for_enemy_text (
        .clk(clk),
        .rst(rst),
        .hcount(hcount),
        .vcount(vcount),
        .hblnk(hblnk),
        .vblnk(vblnk),
        .rgb_in(vga_start_screen.rgb),
        .rgb_out(waiting_text_rgb)
    );

    // -----------------------------
    // Game screen background
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
// Game over display
// -----------------------------
    vga_if vga_game_over();
    draw_game_over_screen #(
        .SCALE(8)
    ) u_draw_game_over_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount),
        .vsync_in(vsync),
        .vblnk_in(vblnk),
        .hcount_in(hcount),
        .hsync_in(hsync),
        .hblnk_in(hblnk),
        .out(vga_game_over)
    );

    logic [11:0] game_over_text_rgb;
    draw_text #(
        .SCALE(4),
        .FROM_MIDDLE(200),
        .LEN(18),
        .LINE("ENTER to see score")
    ) u_click_text (
        .clk(clk),
        .rst(rst),
        .hcount(hcount),
        .vcount(vcount),
        .hblnk(hblnk),
        .vblnk(vblnk),
        .rgb_in(vga_game_over.rgb),
        .rgb_out(game_over_text_rgb)
    );

    logic [11:0] waiting_for_end_text_rgb;
    draw_text #(
        .SCALE(4),
        .FROM_MIDDLE(200),
        .LEN(23),
        .LINE("Wait for second player")
    ) u_waiting_for_end_text (
        .clk(clk),
        .rst(rst),
        .hcount(hcount),
        .vcount(vcount),
        .hblnk(hblnk),
        .vblnk(vblnk),
        .rgb_in(vga_game_over.rgb),
        .rgb_out(waiting_for_end_text_rgb)
    );

    // -----------------------------
    // Score display
    // -----------------------------
    vga_if vga_score_screen();
    draw_score_screen #(
        .SCALE(16)
    ) u_draw_score_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount),
        .vsync_in(vsync),
        .vblnk_in(vblnk),
        .hcount_in(hcount),
        .hsync_in(hsync),
        .hblnk_in(hblnk),
        .out(vga_score_screen)
    );
    
// -----------------------------
// Points & Player indicator
// -----------------------------
    logic [11:0] vga_game_ff;
    always_ff @(posedge clk or posedge rst)
        vga_game_ff <= rst ? 12'h000 : vga_game.rgb;


    points_display u_points_display (
        .clk(clk),
        .rst(rst),
        .score(my_score),
        .hcount(hcount),
        .vcount(vcount),
        .hblnk(hblnk),
        .vblnk(vblnk),
        .rgb_in(vga_game_ff),
        .rgb_out(points_rgb)
    );

    logic [11:0] points_rgb_ff;
    always_ff @(posedge clk or posedge rst)
        points_rgb_ff <= rst ? 12'h000 : points_rgb;

    logic [11:0] player_text_rgb;
    player_indicator_text u_player_indicator (
        .clk(clk), .rst(rst),
        .hcount(hcount), .vcount(vcount),
        .hblnk(hblnk), .vblnk(vblnk),
        .rgb_in(points_rgb_ff),
        .is_player1(is_player1),
        .rgb_out(player_text_rgb)
    );
    logic [11:0] player_text_rgb_ff;
    always_ff @(posedge clk or posedge rst)
        player_text_rgb_ff <= rst ? 12'h000 : player_text_rgb;

    logic [11:0] board_rgb_ff, block_rgb_ff;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            board_rgb_ff <= 12'h000;
            block_rgb_ff <= 12'h000;
        end else begin
            board_rgb_ff <= is_board_pixel_drawn ? board_rgb : player_text_rgb_ff;
            block_rgb_ff <= is_block_pixel_drawn ? block_rgb : board_rgb_ff;
        end
    end

    // -----------------------------
    // Pipeline: ready screen images
    // -----------------------------
    logic [11:0] start_screen_rgb_reg;
    logic [11:0] game_over_screen_rgb_reg;
    logic [11:0] score_screen_rgb_reg;

    always_ff @(posedge clk) begin
        if (rst)
            start_screen_rgb_reg <= 12'h000;
        else if (in_start_screen) begin
            // First player hasn't pressed ENTER yet
            if (!kb_start_flag && !other_ready)
                start_screen_rgb_reg <= start_text_rgb;
            // One ready, other not
            else if ((kb_start_flag && !other_ready) || (!kb_start_flag && other_ready))
                start_screen_rgb_reg <= waiting_text_rgb;
            // Both ready
            else
                start_screen_rgb_reg <= vga_start_screen.rgb;
        end else
            start_screen_rgb_reg <= 12'h000;
    end

    always_ff @(posedge clk) begin
        if (rst)
            game_over_screen_rgb_reg <= 12'h000;
        else if (in_game_over) begin
            if (!kb_start_flag && !other_ready)
                game_over_screen_rgb_reg <= game_over_text_rgb;
            else if (kb_start_flag && !other_ready)
                game_over_screen_rgb_reg <= waiting_for_end_text_rgb;
            else
                game_over_screen_rgb_reg <= vga_game_over.rgb;
        end else
            game_over_screen_rgb_reg <= 12'h000;
    end

    always_ff @(posedge clk) begin
        if (rst)
            score_screen_rgb_reg <= 12'h000;
        else if (in_score)
            score_screen_rgb_reg <= points_rgb_ff;
        else
            score_screen_rgb_reg <= 12'h000;
    end

    // -----------------------------
    // MUX RGB
    // -----------------------------
    logic [11:0] final_rgb;

    always_comb begin

        final_rgb = 12'h000;

        if (in_start_screen)
            final_rgb = start_screen_rgb_reg;
        else if (in_game)
            final_rgb = block_rgb_ff;
        else if (in_game_over)
            final_rgb = game_over_screen_rgb_reg;
        else if (in_score)
            final_rgb = score_screen_rgb_reg;
        else
            final_rgb = 12'h000;
    end

    // -----------------------------
    // VGA outputs
    // -----------------------------
    assign vs = vsync;
    assign hs = hsync;
    assign {r, g, b} = final_rgb;

endmodule