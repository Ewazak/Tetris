module game_logic (
    input  logic clk,
    input  logic rst,
    input  logic load_new_block,
    input  logic move_left,
    input  logic move_right,
    input  logic [2:0] block_type,
    input  logic [3:0][3:0] block_map,
    output logic block_placed,
    output logic [2:0] board [0:199],
    output logic [2:0] lines_removed   // nowy output
);

    timeunit 1ns;
    timeprecision 1ps;

    logic [3:0] active_x;
    logic [4:0] active_y;

    logic can_move_down;
    logic can_move_left;
    logic can_move_right;

    // -------------------------
    // Sprawdzanie kolizji w dół
    // -------------------------
    always_comb begin
        can_move_down = 1;
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                if (block_map[i][j] != 3'd0) begin
                    int x_pos = active_x + j;
                    int y_pos = active_y + i + 1;
                    int idx = y_pos * 10 + x_pos;
                    if (y_pos >= 20) begin
                        can_move_down = 0;
                    end else if (x_pos >= 0 && x_pos < 10 && board[idx] != 3'd0) begin
                        can_move_down = 0;
                    end
                end
            end
        end
    end

    // -------------------------
    // Sprawdzanie kolizji w lewo
    // -------------------------
    always_comb begin
        can_move_left = 1;
        if (active_x == 0) begin
            can_move_left = 0;
        end else begin
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    if (block_map[i][j] != 3'd0) begin
                        int x_pos = active_x + j - 1;
                        int y_pos = active_y + i;
                        int idx = y_pos * 10 + x_pos;
                        if (x_pos < 0 || (x_pos < 10 && board[idx] != 3'd0)) begin
                            can_move_left = 0;
                        end
                    end
                end
            end
        end
    end

    // -------------------------
    // Sprawdzanie kolizji w prawo
    // -------------------------
    always_comb begin
        can_move_right = 1;
        if (active_x + 4 >= 10) begin
            can_move_right = 0;
        end else begin
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 4; j++) begin
                    if (block_map[i][j] != 3'd0) begin
                        int x_pos = active_x + j + 1;
                        int y_pos = active_y + i;
                        int idx = y_pos * 10 + x_pos;
                        if (x_pos >= 10 || (x_pos >= 0 && board[idx] != 3'd0)) begin
                            can_move_right = 0;
                        end
                    end
                end
            end
        end
    end

    // -------------------------
    // Inicjalizacja planszy (pusta)
    // -------------------------
    initial begin
        for (int i = 0; i < 200; i++) begin
            board[i] = 3'd0;
        end
    end

    // -------------------------
    // Główna logika gry
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 200; i++) begin
                board[i] <= 3'd0;
            end
            active_x <= 3;
            active_y <= 0;
            block_placed <= 0;
            lines_removed <= 0;   // resetujemy licznik linii
        end
        else if (load_new_block) begin
            active_x <= 3; // start po środku
            active_y <= 0;
            block_placed <= 0;
            lines_removed <= 0;   // resetujemy licznik przy nowym bloku
        end
        else begin
            // Ruchy poziome
            if (move_left && can_move_left) begin
                active_x <= active_x - 1;
            end else if (move_right && can_move_right) begin
                active_x <= active_x + 1;
            end

            if (can_move_down) begin
                active_y <= active_y + 1;
                block_placed <= 0;
                lines_removed <= 0;  // nie usuwamy nic w trakcie spadania
            end else begin
                // Umieszczenie klocka w planszy
                for (int i = 0; i < 4; i++) begin
                    for (int j = 0; j < 4; j++) begin
                        if (block_map[i][j] != 3'd0) begin
                            int x_pos = active_x + j;
                            int y_pos = active_y + i;
                            int idx = y_pos * 10 + x_pos;
                            if (x_pos >= 0 && x_pos < 10 && y_pos >= 0 && y_pos < 20) begin
                                board[idx] <= block_type;
                            end
                        end
                    end
                end
                block_placed <= 1;

                // Sprawdzenie i usuwanie pełnych linii oraz zliczanie ich
                lines_removed <= 0;
                for (int row = 0; row < 20; row++) begin
                    logic full = 1;
                    for (int col = 0; col < 10; col++) begin
                        int idx = row * 10 + col;
                        if (board[idx] == 3'd0) full = 0;
                    end
                    if (full) begin
                        lines_removed <= lines_removed + 1;
                        // przesuwanie wierszy w dół
                        for (int r = row; r > 0; r--) begin
                            for (int c = 0; c < 10; c++) begin
                                board[r * 10 + c] <= board[(r - 1) * 10 + c];
                            end
                        end
                        // zerowanie górnego wiersza
                        for (int c = 0; c < 10; c++) begin
                            board[c] <= 3'd0;
                        end
                    end
                end
            end
        end
    end

endmodule
