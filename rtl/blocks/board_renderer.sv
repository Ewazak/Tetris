module board_renderer (
    input  logic clk,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic [2:0] board [0:199], // 1D tablica
    output logic [11:0] rgb_out
);

    localparam BLOCK_SIZE = 32;
    localparam BOARD_X = 100;
    localparam BOARD_Y = 50;

    logic in_board_area;
    logic [3:0] block_x, block_y;
    logic [7:0] board_idx;

    always_comb begin
        rgb_out = 12'h000;
        in_board_area = (hcount >= BOARD_X) && (hcount < BOARD_X + 10*BLOCK_SIZE) &&
                        (vcount >= BOARD_Y) && (vcount < BOARD_Y + 20*BLOCK_SIZE);

        if (in_board_area) begin
            block_x = (hcount - BOARD_X) / BLOCK_SIZE;
            block_y = (vcount - BOARD_Y) / BLOCK_SIZE;
            board_idx = block_y * 10 + block_x;

            if (board[board_idx] != 0) begin
                case(board[board_idx])
                    3'd0: rgb_out = 12'hF00; // czerwony
                    3'd1: rgb_out = 12'hFF0; // żółty (O-block)
                    3'd2: rgb_out = 12'hF0F; // magenta (T-block)
                    3'd3: rgb_out = 12'h0F0; // zielony (S-block)
                    3'd4: rgb_out = 12'hF60; // pomarańczowy (Z-block)
                    3'd5: rgb_out = 12'h00F; // niebieski (J-block)
                    3'd6: rgb_out = 12'h0FF; // cyjan (L-block)
                    default: rgb_out = 12'h888; // szary
                endcase
            end
        end
    end

endmodule