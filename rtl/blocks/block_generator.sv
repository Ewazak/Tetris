module block_generator (
    input  logic [2:0] block_type,   // typ klocka (0..6)
    input  logic [1:0] rotation,     // rotacja (0..3)
    output logic [3:0][3:0] block_map // 4x4 pole klocka: 1 = pixel zajęty, 0 = pusty
);

    integer x, y;

    always_comb begin
        // domyślnie wszystko puste
        for (y = 0; y < 4; y = y + 1)
            for (x = 0; x < 4; x = x + 1)
                block_map[y][x] = 1'b0;

        case (block_type)
            3'd1: // I-block
                case (rotation)
                    2'd0: for (x = 0; x < 4; x = x + 1) block_map[1][x] = 1;
                    2'd1: for (y = 0; y < 4; y = y + 1) block_map[y][2] = 1;
                    2'd2: for (x = 0; x < 4; x = x + 1) block_map[2][x] = 1;
                    2'd3: for (y = 0; y < 4; y = y + 1) block_map[y][1] = 1;
                endcase

            3'd2: // O-block (2x2 square)
            begin
                block_map[0][0] = 1; block_map[0][1] = 1;
                block_map[1][0] = 1; block_map[1][1] = 1;
            end

            3'd3: // T-block
                case (rotation)
                    2'd0: begin
                        block_map[1][0] = 1; block_map[1][1] = 1; block_map[1][2] = 1;
                        block_map[2][1] = 1;
                    end
                    2'd1: begin
                        block_map[0][1] = 1; block_map[1][1] = 1; block_map[2][1] = 1;
                        block_map[1][2] = 1;
                    end
                    2'd2: begin
                        block_map[1][1] = 1; block_map[2][0] = 1; block_map[2][1] = 1; block_map[2][2] = 1;
                    end
                    2'd3: begin
                        block_map[0][1] = 1; block_map[1][0] = 1; block_map[1][1] = 1; block_map[2][1] = 1;
                    end
                endcase

            3'd4: // S-block
                case (rotation)
                    2'd0, 2'd2: begin
                        block_map[1][1] = 1; block_map[1][2] = 1;
                        block_map[2][0] = 1; block_map[2][1] = 1;
                    end
                    2'd1, 2'd3: begin
                        block_map[0][1] = 1; block_map[1][1] = 1;
                        block_map[1][2] = 1; block_map[2][2] = 1;
                    end
                endcase

            3'd5: // Z-block
                case (rotation)
                    2'd0, 2'd2: begin
                        block_map[1][0] = 1; block_map[1][1] = 1;
                        block_map[2][1] = 1; block_map[2][2] = 1;
                    end
                    2'd1, 2'd3: begin
                        block_map[0][2] = 1; block_map[1][1] = 1;
                        block_map[1][2] = 1; block_map[2][1] = 1;
                    end
                endcase

            3'd6: // J-block
                case (rotation)
                    2'd0: begin
                        block_map[0][0] = 1;
                        block_map[1][0] = 1;
                        block_map[2][0] = 1; block_map[2][1] = 1;
                    end
                    2'd1: begin
                        block_map[0][0] = 1; block_map[0][1] = 1; block_map[0][2] = 1;
                        block_map[1][0] = 1;
                    end
                    2'd2: begin
                        block_map[0][0] = 1; block_map[0][1] = 1;
                        block_map[1][1] = 1;
                        block_map[2][1] = 1;
                    end
                    2'd3: begin
                        block_map[0][2] = 1;
                        block_map[1][0] = 1; block_map[1][1] = 1; block_map[1][2] = 1;
                    end
                endcase

            3'd7: // L-block
                case (rotation)
                    2'd0: begin
                        block_map[0][1] = 1;
                        block_map[1][1] = 1;
                        block_map[2][0] = 1; block_map[2][1] = 1;
                    end
                    2'd1: begin
                        block_map[0][0] = 1; block_map[0][1] = 1; block_map[0][2] = 1;
                        block_map[1][2] = 1;
                    end
                    2'd2: begin
                        block_map[0][0] = 1; block_map[0][1] = 1;
                        block_map[1][0] = 1;
                        block_map[2][0] = 1;
                    end
                    2'd3: begin
                        block_map[0][0] = 1;
                        block_map[1][0] = 1; block_map[1][1] = 1; block_map[1][2] = 1;
                    end
                endcase
        endcase
    end
endmodule