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
    output  logic        game_over_flag,
    // Wyjścia do rysowania (np. do top_vga)
    output logic [2:0]  board   [0:199], // aktualny stan planszy
    output logic [15:0] my_score,
    output logic [15:0] enemy_score,
    output logic [3:0][3:0] current_block_map,
    output logic [2:0]  current_block_type,
    output logic [10:0] block_pos_x,
    output logic [10:0] block_pos_y,
    output logic in_game,
    output logic in_start_screen,
    output logic in_game_over,
    output logic        block_placed
);

    import vga_pkg::*;

    // -----------------------------
    // Klawiatura
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

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            kb_start_prev <= 1'b0;
        else
            kb_start_prev <= kb_start;
    end
    assign kb_start_edge = kb_start && !kb_start_prev;

    // -----------------------------
    // FSM gry
    // -----------------------------
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

    logic kb_rotate_prev, kb_rotate_edge;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            kb_rotate_prev <= 1'b0;
        else
            kb_rotate_prev <= kb_rotate;
    end

    assign kb_rotate_edge = kb_rotate && !kb_rotate_prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            rotation <= 0;
        else if (in_game && kb_rotate_edge)
            rotation <= (rotation + 1) % 4;
    end
    
    // -----------------------------
    // Logika gry
    // -----------------------------
    logic [2:0] lines_removed;
    logic [3:0] active_x;
    logic [4:0] active_y;

    parameter BLOCK_SIZE = 32; // rozmiar klocka w pikselach na ekranie
    
    // Wymiary planszy w klockach
    parameter BOARD_WIDTH_BLOCKS = 10;
    parameter BOARD_HEIGHT_BLOCKS = 20;

    localparam BOARD_WIDTH_PIXELS = BOARD_WIDTH_BLOCKS * BLOCK_SIZE;
    localparam BOARD_HEIGHT_PIXELS = BOARD_HEIGHT_BLOCKS * BLOCK_SIZE;
    localparam BOARD_X_CENTERED = (HOR_PIXELS - BOARD_WIDTH_PIXELS) / 2;
    localparam BOARD_Y_CENTERED = (VER_PIXELS - BOARD_HEIGHT_PIXELS) / 2;

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
    // Punkty
    // -----------------------------
    score_counter u_score_counter (
        .clk(clk),
        .reset(rst),
        .lines_cleared(lines_removed),
        .add_block(block_placed),
        .score(my_score)
    );

    // -----------------------------
    // UART wymiana punktów
    // -----------------------------
    logic [7:0] uart_data_send, uart_data_received;

    assign uart_data_send = my_score[7:0]; // wysyłamy dolny bajt wyniku

    top_uart u_top_uart (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .uart_data_send(uart_data_send),
        .uart_data_received(uart_data_received),
        .tx(tx)
    );

    // Wynik przeciwnika z UART
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            enemy_score <= 16'd0;
        else
            enemy_score <= {8'd0, uart_data_received};
    end

endmodule
