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

// -----------------------------
// Arbiter and font_rom
// -----------------------------
    localparam int FONT_CLIENTS = 7;
    logic [FONT_CLIENTS-1:0]       font_req;
    logic [10:0]                   font_addr_arr [0:FONT_CLIENTS-1];
    logic [7:0]                    font_data;
    logic [FONT_CLIENTS-1:0]       font_grant_onehot;
    logic                          font_data_valid;
    logic [10:0]                   font_rom_addr;
    logic                          font_rom_req;

    font_arbiter #(.NCLIENTS(FONT_CLIENTS)) u_font_arb (
        .clk(clk),
        .rst(rst),
        .req(font_req),
        .addr(font_addr_arr),
        .rom_addr(font_rom_addr),
        .rom_req(font_rom_req),
        .rom_data(font_data),
        .grant_onehot(font_grant_onehot),
        .data_valid(font_data_valid)
    );

    // single font ROM
    font_rom font_mem_inst (
        .clk(clk),
        .addr(font_rom_addr),
        .char_line_pixels(font_data)
    );

    // -----------------------------
    // Text instances
    // -----------------------------
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
        .font_req(font_req[0]),
        .font_addr(font_addr_arr[0]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[0]),
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
        .font_req(font_req[1]),
        .font_addr(font_addr_arr[1]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[1]),
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
        .font_req(font_req[2]),
        .font_addr(font_addr_arr[2]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[2]),
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
        .font_req(font_req[3]),
        .font_addr(font_addr_arr[3]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[3]),
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
    // Score
    // -----------------------------
    logic [15:0] my_score_sync, enemy_score_sync;

    always_ff @(posedge clk) begin
    my_score_sync    <= my_score;
    enemy_score_sync <= enemy_score;
    end

    logic [11:0] score_screen_text_rgb;

    score_screen_text #(
        .SCALE(2)
    ) u_score_screen_text (
        .clk(clk),
        .rst(rst),
        .hcount(hcount),
        .vcount(vcount),
        .hblnk(hblnk),
        .vblnk(vblnk),
        .rgb_in(vga_score_screen.rgb),
        .my_score(my_score_sync),
        .enemy_score(enemy_score_sync),
        .is_player1(is_player1),
        .font_req(font_req[4]),
        .font_addr(font_addr_arr[4]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[4]),
        .rgb_out(score_screen_text_rgb)
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
        .font_req(font_req[5]),
        .font_addr(font_addr_arr[5]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[5]),
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
        .font_req(font_req[6]),
        .font_addr(font_addr_arr[6]),
        .font_data(font_data),
        .font_grant(font_grant_onehot[6]),
        .rgb_out(player_text_rgb)
    );
    logic [11:0] player_text_rgb_ff;
    always_ff @(posedge clk or posedge rst)
        player_text_rgb_ff <= rst ? 12'h000 : player_text_rgb;

    logic [11:0] board_rgb_ff;
    always_ff @(posedge clk or posedge rst)
        board_rgb_ff <= rst ? 12'h000
                            : (is_board_pixel_drawn ? board_rgb : player_text_rgb_ff);

    logic [11:0] block_rgb_ff;
    always_ff @(posedge clk or posedge rst)
        block_rgb_ff <= rst ? 12'h000
                            : (is_block_pixel_drawn ? block_rgb : board_rgb_ff);

    // -----------------------------
    // Pipeline: ready screen images
    // -----------------------------
    logic [11:0] start_screen_rgb_reg;
    logic [11:0] game_over_screen_rgb_reg;

    always_comb begin
        if (in_start_screen) begin
            if (!kb_start_flag)
                start_screen_rgb_reg = start_text_rgb;
            else if (!other_ready)
                start_screen_rgb_reg = vga_start_screen.rgb | waiting_text_rgb;
            else
                start_screen_rgb_reg = vga_start_screen.rgb;
        end else
            start_screen_rgb_reg = 12'h000;
    end

    always_comb begin
        if (in_game_over) begin
            if (!kb_start_flag)
                game_over_screen_rgb_reg = game_over_text_rgb;         // lokalny nie kliknął
            else if (!other_ready)
                game_over_screen_rgb_reg = vga_game_over.rgb | waiting_for_end_text_rgb; // nakłada się na tło
            else
                game_over_screen_rgb_reg = vga_game_over.rgb;         // obaj gotowi
        end else
            game_over_screen_rgb_reg = 12'h000;
    end

    // -----------------------------
    // MUX RGB
    // -----------------------------
    logic [11:0] final_rgb;

    always_comb begin
    if (in_start_screen)
        final_rgb = start_screen_rgb_reg;
    else if (in_game)
        final_rgb = block_rgb_ff;
    else if (in_game_over)
        final_rgb = game_over_screen_rgb_reg;
    else if (in_score)
        final_rgb = score_screen_text_rgb;
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