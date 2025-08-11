module top_game (
    input  logic        clk,
    input  logic        rst,
    // Klawiatura
    input  logic        ps2_clk,
    input  logic        ps2_data,
    // UART
    input  logic        rx,
    output logic        tx,
    // Flaga końca gry
    input  logic        game_over_flag,
    // Wyjścia do rysowania (np. do top_vga)
    output logic [2:0]  board   [0:199], // aktualny stan planszy
    output logic [15:0] my_score,
    output logic [15:0] enemy_score,
    output logic [3:0][3:0] current_block_map,
    output logic [2:0]  current_block_type,
    output logic [10:0] block_pos_x,
    output logic [10:0] block_pos_y,
    output logic        block_placed
);

    // -----------------------------
    // Klawiatura
    // -----------------------------
    logic [15:0] keycode;
    logic kb_rotate, kb_down, kb_left, kb_right, kb_start, kb_falling;
    logic kb_start_prev, kb_start_edge;

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

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            kb_start_prev <= 1'b0;
        end else begin
            kb_start_prev <= kb_start;
        end
    end
    assign kb_start_edge = kb_start && !kb_start_prev;

    // -----------------------------
    // FSM gry
    // -----------------------------
    logic in_game, in_start_screen, in_game_over, load_new_block;

    game_controller u_game_controller (
        .clk(clk),
        .rst(rst),
        .enter_pressed(kb_start_edge),
        .game_over_flag(game_over_flag),
        .block_placed(block_placed),
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over),
        .load_new_block(load_new_block)
    );

    // -----------------------------
    // Generator klocków
    // -----------------------------
    logic [1:0] rotation;

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

    // -----------------------------
    // Logika gry
    // -----------------------------
    logic [2:0] lines_removed;

    game_logic u_game_logic (
        .clk(clk),
        .rst(rst),
        .load_new_block(load_new_block),
        .block_type(current_block_type),
        .block_map(current_block_map),
        .block_placed(block_placed),
        .board(board),
        .lines_removed(lines_removed)
    );

    // -----------------------------
    // Punkty
    // -----------------------------
    score_counter u_score_counter (
        .clk(clk),
        .reset(rst),
        .lines_cleared(lines_removed),
        .score(my_score)
    );

    // -----------------------------
    // UART wymiana punktów
    // -----------------------------
    logic [7:0] uart_data_send, uart_data_received;

    top_uart u_top_uart (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .uart_data_send(uart_data_send),
        .uart_data_received(uart_data_received),
        .tx(tx)
    );

    // Wynik przeciwnika z UART
    assign enemy_score = {8'd0, uart_data_received}; // jeśli tylko 8 bitów

endmodule