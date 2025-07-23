module block_draw (
    input  logic [10:0] hcount,       // aktualny pixel X
    input  logic [10:0] vcount,       // aktualny pixel Y
    input  logic [10:0] block_pos_x,  // pozycja klocka X w pikselach
    input  logic [10:0] block_pos_y,  // pozycja klocka Y w pikselach
    input  logic [3:0][3:0] block_map,// 4x4 mapa klocka (1 = zajęty pixel)
    input  logic [2:0] block_type,    // typ klocka (do koloru)
    output logic [11:0] rgb_out       // kolor piksela (12-bit RGB)
);

    localparam BLOCK_SIZE = 32; // wielkość pola klocka w pikselach

    logic inside_block_area;
    logic [1:0] block_x, block_y;

    always_comb begin
        rgb_out = 12'h000; // tło czarne na start

        // Sprawdzamy czy pixel mieści się w obszarze klocka (4 pola * BLOCK_SIZE)
        inside_block_area = (hcount >= block_pos_x) && (hcount < block_pos_x + 4*BLOCK_SIZE) &&
                            (vcount >= block_pos_y) && (vcount < block_pos_y + 4*BLOCK_SIZE);

        if (inside_block_area) begin
            // Obliczamy indeks w macierzy (0..3)
            block_x = (hcount - block_pos_x) / BLOCK_SIZE;
            block_y = (vcount - block_pos_y) / BLOCK_SIZE;

            // Jeśli pole jest zajęte, ustaw kolor według typu klocka
            if (block_map[block_y][block_x]) begin
                case (block_type)
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
            else
                rgb_out = 12'h000; // tło
        end
    end

endmodule