module board_renderer (
    input  logic clk,
    input  logic [10:0] hcount,  // aktualna pozycja pozioma piksela
    input  logic [10:0] vcount,  // aktualna pozycja pionowa piksela
    input  logic [2:0] board [0:9][0:19], // plansza 10x20 z typami klocków
    output logic [11:0] rgb_out   // 12-bitowy kolor (4b R, 4b G, 4b B)
);
    localparam BLOCK_SIZE = 32;  // rozmiar bloku w pikselach
    localparam BOARD_X = 100;    // lewy górny róg planszy na ekranie (x)
    localparam BOARD_Y = 50;     // lewy górny róg planszy na ekranie (y)

    logic in_board_area;
    logic [3:0] block_x, block_y; // indeksy bloku w planszy
    logic [4:0] pixel_x_in_block, pixel_y_in_block;

    always_comb begin
        rgb_out = 12'h000;  // tło czarne
        in_board_area = (hcount >= BOARD_X) && (hcount < BOARD_X + 10*BLOCK_SIZE) &&
                        (vcount >= BOARD_Y) && (vcount < BOARD_Y + 20*BLOCK_SIZE);

        if (in_board_area) begin
            block_x = (hcount - BOARD_X) / BLOCK_SIZE;
            block_y = (vcount - BOARD_Y) / BLOCK_SIZE;
            pixel_x_in_block = (hcount - BOARD_X) % BLOCK_SIZE;
            pixel_y_in_block = (vcount - BOARD_Y) % BLOCK_SIZE;

            if (board[block_x][block_y] != 0) begin
                // Kolor w zależności od typu klocka (przykład)
                case(board[block_x][block_y])
                    3'd0: rgb_out = 12'hF00; // czerwony
                    3'd1: rgb_out = 12'hFF0; // żółty (O-block)
                    3'd2: rgb_out = 12'hF0F; // magenta (T-block)
                    3'd3: rgb_out = 12'h0F0; // zielony (S-block)
                    3'd4: rgb_out = 12'hF60; // pomarańczowy (Z-block)
                    3'd5: rgb_out = 12'h00F; // niebieski (J-block)
                    3'd6: rgb_out = 12'h0FF; // cyjan (L-block)
                    default: rgb_out = 12'h888; // szary dla innych
                endcase
            end
            else begin
                rgb_out = 12'h000; // tło planszy (czarne)
            end
        end
    end

endmodule