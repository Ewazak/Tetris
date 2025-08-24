/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: top_game module - main game module which integrates all submodules.
*/
module top_game (
    input  logic        clk,
    input  logic        rst,
    // Keyboard
    input  logic        ps2_clk,
    input  logic        ps2_data,
    // UART
    input  logic        rx,
    output logic        tx,
    // Game over flag
    output  logic        game_over_flag,
    // Outputs for rendering (e.g. to top_vga)
    output logic [2:0]  board   [0:199], // current board state
    output logic [15:0] my_score,
    output logic [15:0] enemy_score,
    output logic [3:0][3:0] current_block_map,
    output logic [2:0]  current_block_type,
    output logic [10:0] block_pos_x,
    output logic [10:0] block_pos_y,
    output logic in_game,
    output logic in_start_screen,
    output logic in_game_over,
    output logic in_score,
    output logic block_placed,
    output logic other_ready,
    output logic kb_start_flag,
    output logic is_player1
);

    import vga_pkg::*;

    // -----------------------------
    // Keyboard
    // -----------------------------
    logic [15:0] keycode;
    logic kb_rotate, kb_down, kb_left, kb_right, kb_start, kb_falling;
    logic kb_start_prev, kb_start_edge;
    logic load_new_block;

    receiver u_receiver (
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .keycode(keycode),
        .oflag()
    );

    KeyboardCtl u_KeyboardCtl (
        .keycode(keycode),
        .kb_rotate(kb_rotate),
        .kb_down(kb_down),
        .kb_left(kb_left),
        .kb_right(kb_right),
        .kb_start(kb_start),
        .kb_falling(kb_falling)
    );

    always_ff @(posedge clk) kb_start_prev <= kb_start;
    assign kb_start_edge = kb_start & ~kb_start_prev;

    logic prev_in_score_flag;
    always_ff @(posedge clk) begin
        if (rst) begin
            prev_in_score_flag <= 1'b0;
            kb_start_flag      <= 1'b0;
        end else begin
            prev_in_score_flag <= in_score;

            // Reset flag when entering SCORE
            if (in_score && !prev_in_score_flag)
                kb_start_flag <= 1'b0;
            // Latch for START/GAME_OVER
            else if ((in_start_screen || in_game_over) && kb_start_edge)
                kb_start_flag <= 1'b1;
            // Default: in other states set to 0
            else if (!(in_start_screen || in_game_over))
                kb_start_flag <= 1'b0;
        end
    end

// -----------------------------
// Determining who is Player 1
// -----------------------------
logic player_assigned;
logic is_player1_reg;

always_ff @(posedge clk) begin
    if (rst) begin
        player_assigned <= 1'b0;
        is_player1_reg  <= 1'b0;
    end else begin
        // RESET: after leaving SCORE
        if (prev_in_score_flag && !in_score) begin
            player_assigned <= 1'b0;
            is_player1_reg  <= 1'b0;
        end

        // Assign player only if not decided yet
        if (!player_assigned) begin
            if (kb_start_flag && !other_ready) begin
                is_player1_reg  <= 1'b1;   // I pressed first
                player_assigned <= 1'b1;
            end
            else if (other_ready && !kb_start_flag) begin
                is_player1_reg  <= 1'b0;   // opponent pressed first
                player_assigned <= 1'b1;
            end
            else if (kb_start_flag && other_ready) begin
                is_player1_reg  <= 1'b1;   // tie
                player_assigned <= 1'b1;
            end
        end
    end
end


    assign is_player1 = is_player1_reg;

    // -----------------------------
    // Game FSM
    // -----------------------------
    game_controller u_game_controller (
        .clk(clk),
        .rst(rst),
        .me_ready(kb_start_flag),
        .other_ready(other_ready),
        .game_over_flag(game_over_flag),
        .block_placed(block_placed),
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over),
        .in_score(in_score),
        .load_new_block(load_new_block)
    );

    // -----------------------------
    // Block generator and game logic
    // -----------------------------
    logic [1:0] rotation;
    logic kb_rotate_prev, kb_rotate_edge;
    logic [2:0] lines_removed;
    logic [3:0] active_x;
    logic [4:0] active_y;

    parameter BLOCK_SIZE = 32;
    parameter BOARD_WIDTH_BLOCKS = 10;
    parameter BOARD_HEIGHT_BLOCKS = 20;

    localparam BOARD_WIDTH_PIXELS  = BOARD_WIDTH_BLOCKS  * BLOCK_SIZE;
    localparam BOARD_HEIGHT_PIXELS = BOARD_HEIGHT_BLOCKS * BLOCK_SIZE;
    localparam BOARD_X_CENTERED = (HOR_PIXELS - BOARD_WIDTH_PIXELS) / 2;
    localparam BOARD_Y_CENTERED = (VER_PIXELS - BOARD_HEIGHT_PIXELS) / 2;

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

    always_ff @(posedge clk) kb_rotate_prev <= kb_rotate;
    assign kb_rotate_edge = kb_rotate & ~kb_rotate_prev;

    always_ff @(posedge clk) begin
        if (in_game && kb_rotate_edge)
            rotation <= (rotation + 1) % 4;
    end

    game_logic #(
    .BOARD_X(BOARD_X_CENTERED),
    .BOARD_Y(BOARD_Y_CENTERED),
    .BLOCK_SIZE(BLOCK_SIZE)
    ) u_game_logic (
        .clk(clk),
        .rst(rst),
        .load_new_block(load_new_block),
        .block_type(current_block_type),
        .block_map(current_block_map),
        .block_placed(block_placed),
        .active_x(active_x),
        .active_y(active_y),
        .move_left(kb_left && in_game),
        .move_right(kb_right && in_game),
        .move_down(kb_down && in_game),
        .board(board),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .lines_removed(lines_removed),
        .game_over_flag(game_over_flag)
    );

    // -----------------------------
    // Points
    // -----------------------------
    points_counter u_points_counter (
        .clk(clk),
        .reset(rst),
        .lines_cleared(lines_removed),
        .add_block(block_placed),
        .score(my_score)
    );

    // -----------------------------
    // UART signal exchange
    // -----------------------------
    logic [7:0] uart_data_send, uart_data_received;
    wire ready_for_peer = kb_start_flag & (in_start_screen | in_game_over);
    assign uart_data_send = { ready_for_peer, my_score[6:0] };

    top_uart u_top_uart (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .uart_data_send(uart_data_send),
        .uart_data_received(uart_data_received),
        .tx(tx)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            other_ready <= 1'b0;
        else
            other_ready <= uart_data_received[7];
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            enemy_score <= 16'd0;
        else
            enemy_score <= {8'd0, 1'b0, uart_data_received[6:0]};
    end

endmodule
