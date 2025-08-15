module board_renderer #(
    parameter BLOCK_SIZE = 32,
    parameter BOARD_X = 100,
    parameter BOARD_Y = 50
) (
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic [3*200-1:0] board_flat,
    output logic [11:0] rgb_out,
    output logic is_board_pixel_drawn
);

    logic in_board_area;
    logic [3:0] block_x, block_y;
    logic [7:0] board_idx;
    logic [2:0] cells;

    always_comb begin
        rgb_out = 12'h000;
        is_board_pixel_drawn = 1'b0;
        in_board_area = (hcount >= BOARD_X) && (hcount < BOARD_X + 10*BLOCK_SIZE) &&
                        (vcount >= BOARD_Y) && (vcount < BOARD_Y + 20*BLOCK_SIZE);
    
        if (in_board_area) begin
            block_x = (hcount - BOARD_X) / BLOCK_SIZE;
            block_y = (vcount - BOARD_Y) / BLOCK_SIZE;
            board_idx = block_y * 10 + block_x;
    
            cells = board_flat[board_idx*3 +: 3];
    
            if (cells != 3'd0) begin // Rysujemy tylko, jeśli pole planszy nie jest puste
                is_board_pixel_drawn = 1'b1;
                case(cells)
                    3'd1: rgb_out = 12'hF00; // czerwony
                    3'd2: rgb_out = 12'hFF0; // żółty (O-block)
                    3'd3: rgb_out = 12'hF0F; // magenta (T-block)
                    3'd4: rgb_out = 12'h0F0; // zielony (S-block)
                    3'd5: rgb_out = 12'hF60; // pomarańczowy (Z-block)
                    3'd6: rgb_out = 12'h00F; // niebieski (J-block)
                    3'd7: rgb_out = 12'h0FF; // cyjan (L-block)
                    default: rgb_out = 12'h888; // szary
                endcase
            end
        end
    end 

endmodule