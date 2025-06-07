module block (
    input  logic [2:0] block_type,   // 0..6 typ klocka (I,O,T,S,Z,J,L)
    input  logic [1:0] rotation,     // 0..3 rotacja klocka
    input  logic [1:0] x,             // 0..3 współrzędna x w 4x4 macierzy
    input  logic [1:0] y,             // 0..3 współrzędna y w 4x4 macierzy
    output logic       occupied       // 1 jeśli pixel zajęty, 0 jeśli pusty
);

    always_comb begin
        occupied = 1'b0; // domyślnie pusty
        case (block_type)
            3'd0: // I-block
                case (rotation)
                    2'd0: occupied = (y == 1);
                    2'd1: occupied = (x == 2);
                    2'd2: occupied = (y == 2);
                    2'd3: occupied = (x == 1);
                endcase

            3'd1: // O-block (kwadrat)
                occupied = (x <= 1) && (y <= 1);

            3'd2: // T-block
                case (rotation)
                    2'd0: occupied = (y == 1 && x != 2) || (y == 2 && x == 1);
                    2'd1: occupied = (x == 1 && y != 0) || (x == 2 && y == 1);
                    2'd2: occupied = (y == 1 && x != 1) || (y == 2 && x == 2);
                    2'd3: occupied = (x == 2 && y != 3) || (x == 1 && y == 2);
                endcase

            3'd3: // S-block
                case (rotation)
                    2'd0: occupied = ((y == 1 && (x == 1 || x == 2)) || (y == 2 && (x == 0 || x == 1)));
                    2'd1: occupied = ((x == 1 && (y == 0 || y == 1)) || (x == 2 && (y == 1 || y == 2)));
                    2'd2: occupied = ((y == 1 && (x == 1 || x == 2)) || (y == 2 && (x == 0 || x == 1)));
                    2'd3: occupied = ((x == 1 && (y == 0 || y == 1)) || (x == 2 && (y == 1 || y == 2)));
                endcase

            3'd4: // Z-block
                case (rotation)
                    2'd0: occupied = ((y == 1 && (x == 0 || x == 1)) || (y == 2 && (x == 1 || x == 2)));
                    2'd1: occupied = ((x == 1 && (y == 1 || y == 2)) || (x == 2 && (y == 0 || y == 1)));
                    2'd2: occupied = ((y == 1 && (x == 0 || x == 1)) || (y == 2 && (x == 1 || x == 2)));
                    2'd3: occupied = ((x == 1 && (y == 1 || y == 2)) || (x == 2 && (y == 0 || y == 1)));
                endcase

            3'd5: // J-block
                case (rotation)
                    2'd0: occupied = (x == 0 && y != 3) || (y == 2 && x != 3);
                    2'd1: occupied = (y == 0 && x != 3) || (x == 1 && y != 3);
                    2'd2: occupied = (x == 2 && y != 3) || (y == 1 && x != 3);
                    2'd3: occupied = (y == 2 && x != 3) || (x == 1 && y != 3);
                endcase

            3'd6: // L-block
                case (rotation)
                    2'd0: occupied = (x == 2 && y != 3) || (y == 2 && x != 3);
                    2'd1: occupied = (y == 0 && x != 3) || (x == 2 && y != 3);
                    2'd2: occupied = (x == 1 && y != 3) || (y == 1 && x != 3);
                    2'd3: occupied = (y == 2 && x != 3) || (x == 2 && y != 3);
                endcase

            default: occupied = 1'b0;
        endcase
    end

endmodule