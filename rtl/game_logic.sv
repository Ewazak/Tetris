module game_logic (
    input  logic clk,
    input  logic rst,
    input  logic load_new_block,
    input  logic [2:0] block_type,                 // z randomizera
    input  logic [3:0][3:0] block_map,             // z block_generatora
    output logic block_placed,
    output logic [2:0] board [0:9][0:19]           // 10x20 plansza
);

    timeunit 1ns;
    timeprecision 1ps;

    // Współrzędne lewego górnego rogu klocka na planszy
    logic [3:0] active_x;
    logic [4:0] active_y;

    // Flaga ruchu
    logic can_move;

    // -------------------------
    // Inicjalizacja planszy (pusta)
    // -------------------------
    initial begin
        for (int x = 0; x < 10; x++) begin
            for (int y = 0; y < 20; y++) begin
                board[x][y] = 3'd0;
            end
        end
    end

    // -------------------------
    // KOLIZJA: czy można przesunąć klocek w dół
    // -------------------------
    always_comb begin
        can_move = 1;
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                if (block_map[i][j] != 3'd0) begin
                    int x_pos = active_x + j;
                    int y_pos = active_y + i + 1;
                    if (y_pos >= 20) begin
                        can_move = 0;
                    end else if (x_pos >= 0 && x_pos < 10 && board[x_pos][y_pos] != 3'd0) begin
                        can_move = 0;
                    end
                end
            end
        end
    end

    // -------------------------
    // Główna logika gry
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int x = 0; x < 10; x++) begin
                for (int y = 0; y < 20; y++) begin
                    board[x][y] <= 3'd0;
                end
            end
            active_x <= 3;
            active_y <= 0;
            block_placed <= 0;
        end
        else if (load_new_block) begin
            active_x <= 3; // start po środku
            active_y <= 0;
            block_placed <= 0;
        end
        else begin
            if (can_move) begin
                active_y <= active_y + 1;
                block_placed <= 0;
            end else begin
                // Zapisz klocek do planszy
                for (int i = 0; i < 4; i++) begin
                    for (int j = 0; j < 4; j++) begin
                        if (block_map[i][j] != 3'd0) begin
                            int x_pos = active_x + j;
                            int y_pos = active_y + i;
                            if (x_pos >= 0 && x_pos < 10 && y_pos >= 0 && y_pos < 20)
                                board[x_pos][y_pos] <= block_type;
                        end
                    end
                end
                block_placed <= 1;

                // Sprawdź i usuń pełne linie
                for (int row = 0; row < 20; row++) begin
                    logic full = 1;
                    for (int col = 0; col < 10; col++) begin
                        if (board[col][row] == 3'd0)
                            full = 0;
                    end
                    if (full) begin
                        // Przesuń wiersze w dół
                        for (int r = row; r > 0; r--) begin
                            for (int c = 0; c < 10; c++) begin
                                board[c][r] <= board[c][r-1];
                            end
                        end
                        // Górny wiersz = pusty
                        for (int c = 0; c < 10; c++) begin
                            board[c][0] <= 3'd0;
                        end
                    end
                end
            end
        end
    end

endmodule