module game_logic #(
    parameter BOARD_X = 100,
    parameter BOARD_Y = 50,
    parameter BLOCK_SIZE = 32
)(
    input logic clk,
    input logic rst,
    input logic load_new_block,
    input logic move_left,
    input logic move_right,
    input logic move_down,
    input logic [2:0] block_type,
    input logic [3:0][3:0] block_map,
    output logic block_placed,
    output logic [3:0] active_x,
    output logic [4:0] active_y,
    output logic [10:0] block_pos_x,
    output logic [10:0] block_pos_y,
    output logic [2:0] board [0:199],
    output logic [2:0] lines_removed,
    output logic game_over_flag
);

localparam FALL_LIMIT = 65_000_000;
logic [31:0] fall_counter;

// Poprzedni stan przycisków do detekcji zbocza
logic move_left_prev, move_right_prev;

// -------------------------
// Funkcja sprawdzania kolizji
// -------------------------
function logic check_collision(
    input int nx,
    input int ny,
    input logic [3:0][3:0] shape,
    input logic [2:0] b [0:199]
);
    check_collision = 0;
    for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
            if (shape[i][j]) begin
                int tx = nx + j;
                int ty = ny + i;
                if (tx < 0 || tx >= 10 || ty >= 20) begin
                    check_collision = 1;
                end
                else if (b[ty*10 + tx] != 3'd0) begin
                    check_collision = 1;
                end
            end
        end
    end
endfunction

// -------------------------
// Zadanie: umieszczenie klocka i czyszczenie linii
// -------------------------
task place_block;
    logic full_row[0:19];
    begin
        // Umieszczenie klocka w planszy
        for (int i=0; i<4; i++) begin
            for (int j=0; j<4; j++) begin
                if (block_map[i][j]) begin
                    int idx = (active_y+i)*10 + (active_x+j);
                    if (idx >= 0 && idx < 200)
                        board[idx] <= block_type;
                end
            end
        end
        block_placed <= 1;

        // Sprawdzenie pełnych linii
        lines_removed <= 0;
        for (int row=0; row<20; row++) begin
            full_row[row] = 1;
            for (int col=0; col<10; col++) begin
                if (board[row*10 + col] == 3'd0)
                    full_row[row] = 0;
            end
        end

        // Usuwanie pełnych linii od dołu do góry
        for (int row=19; row>=0; row--) begin
            if (full_row[row]) begin
                lines_removed <= lines_removed + 1;
                // przesunięcie w dół wszystkich wyższych linii
                for (int r=row; r>0; r--) begin
                    for (int c=0; c<10; c++) begin
                        board[r*10 + c] <= board[(r-1)*10 + c];
                    end
                end
                // zerowanie górnej linii
                for (int c=0; c<10; c++) begin
                    board[c] <= 3'd0;
                end
            end
        end
    end
endtask

// -------------------------
// Główna logika gry
// -------------------------
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 0; i < 200; i++) board[i] <= 3'd0;
        active_x <= 3;
        active_y <= 0;
        fall_counter <= 0;
        lines_removed <= 0;
        block_placed <= 0;
        game_over_flag <= 0;
        move_left_prev <= 0;
        move_right_prev <= 0;
    end
    else begin
        // Aktualizacja poprzedniego stanu przycisków
        move_left_prev <= move_left;
        move_right_prev <= move_right;

        if (load_new_block) begin
            active_x <= 3;
            active_y <= 0;
            block_placed <= 0;
            fall_counter <= 0;
            lines_removed <= 0; // reset przy wczytaniu nowego klocka

            if (check_collision(3, 0, block_map, board)) begin
                game_over_flag <= 1;
            end else begin
                game_over_flag <= 0;
            end
        end
        else if (!game_over_flag) begin
            block_placed <= 0;

            // Ruchy poziome (po pojedynczym naciśnięciu)
            if (move_left && !move_left_prev && !check_collision(active_x-1, active_y, block_map, board)) begin
                active_x <= active_x - 1;
                fall_counter <= 0;
            end
            else if (move_right && !move_right_prev && !check_collision(active_x+1, active_y, block_map, board)) begin
                active_x <= active_x + 1;
                fall_counter <= 0;
            end

            // Ręczne przesunięcie w dół
                if (move_down && !check_collision(active_x, active_y+1, block_map, board)) begin
                    active_y <= active_y + 1;
                end

                // Automatyczne opadanie
                fall_counter <= fall_counter + 1;
                if (fall_counter >= FALL_LIMIT) begin
                    fall_counter <= 0;
                    if (!check_collision(active_x, active_y+1, block_map, board)) begin
                        active_y <= active_y + 1;
                    end else begin
                        place_block();
                    end
                end
            end
        end
    end

// Pozycja piksela do rysowania
assign block_pos_x = BOARD_X + (active_x << 5);
assign block_pos_y = BOARD_Y + (active_y << 5);

endmodule