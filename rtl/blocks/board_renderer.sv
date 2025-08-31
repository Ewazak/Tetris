//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:  board_renderer
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:  Renders the game board by mapping pixel coordinates to board cells and coloring non-empty ones.
 */
//////////////////////////////////////////////////////////////////////////////
module board_renderer #(
    parameter BLOCK_SIZE = 32,
    parameter BOARD_X = 100, // X position of the board
    parameter BOARD_Y = 50   // Y position of the board
) (
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic [3*200-1:0] board_flat, // flattened board data (200 cells x 3 bits each)
    output logic [11:0] rgb_out,
    output logic is_board_pixel_drawn    // flag indicating if a board cell pixel is drawn
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
    localparam BOARD_WIDTH_BLOCKS  = 10;
    localparam BOARD_HEIGHT_BLOCKS = 20;
    localparam BOARD_W_PIXELS = BOARD_WIDTH_BLOCKS * BLOCK_SIZE;
    localparam BOARD_H_PIXELS = BOARD_HEIGHT_BLOCKS * BLOCK_SIZE;
    localparam BORDER = 3;   // width

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    logic in_board_area;
    logic on_border;
    logic [3:0] block_x;
    logic [4:0] block_y;
    integer board_idx;
    logic [2:0] cells;

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
    always_comb begin : board_renderer_comb
        // Is pixel in board area
        in_board_area = (hcount >= BOARD_X) && (hcount < BOARD_X + BOARD_W_PIXELS) &&
                        (vcount >= BOARD_Y) && (vcount < BOARD_Y + BOARD_H_PIXELS);

        // Is pixel on border (not in board area)
        on_border =
            //Left edge
            ((hcount >= BOARD_X - BORDER && hcount < BOARD_X) &&
             (vcount >= BOARD_Y && vcount < BOARD_Y + BOARD_H_PIXELS)) ||

            // Right edge
            ((hcount >= BOARD_X + BOARD_W_PIXELS && hcount < BOARD_X + BOARD_W_PIXELS + BORDER) &&
             (vcount >= BOARD_Y && vcount < BOARD_Y + BOARD_H_PIXELS)) ||

            // Top edge
            ((vcount >= BOARD_Y - BORDER && vcount < BOARD_Y) &&
             (hcount >= BOARD_X - BORDER && hcount < BOARD_X + BOARD_W_PIXELS + BORDER)) ||

            // Bottom edge
            ((vcount >= BOARD_Y + BOARD_H_PIXELS && vcount < BOARD_Y + BOARD_H_PIXELS + BORDER) &&
             (hcount >= BOARD_X - BORDER && hcount < BOARD_X + BOARD_W_PIXELS + BORDER));

        if (on_border) begin
            rgb_out = 12'hFFF; // white frame
            is_board_pixel_drawn = 1;
        end
        else if (in_board_area) begin
            block_x = (hcount - BOARD_X) / BLOCK_SIZE;
            block_y = (vcount - BOARD_Y) / BLOCK_SIZE;

            // protection against going outside the board
            if (block_x >= BOARD_WIDTH_BLOCKS)  block_x = BOARD_WIDTH_BLOCKS - 1;
            if (block_y >= BOARD_HEIGHT_BLOCKS) block_y = BOARD_HEIGHT_BLOCKS - 1;

            board_idx = block_y * BOARD_WIDTH_BLOCKS + block_x;
            cells = board_flat[board_idx*3 +: 3];
    
            if (cells != 3'd0) begin
                case(cells)
                    3'd1: rgb_out = 12'hF00; // red (I-block)
                    3'd2: rgb_out = 12'hFF0; // yellow (O-block)
                    3'd3: rgb_out = 12'hF0F; // magenta (T-block)
                    3'd4: rgb_out = 12'h0F0; // green (S-block)
                    3'd5: rgb_out = 12'hF60; // orange (Z-block)
                    3'd6: rgb_out = 12'h00F; // blue (J-block)
                    3'd7: rgb_out = 12'h0FF; // cyan (L-block)
                    default: rgb_out = 12'h888; // gray 
                endcase
                is_board_pixel_drawn = 1;
            end else begin
                rgb_out = 12'h000; // board background
                is_board_pixel_drawn = 0;
            end
        end else begin
            rgb_out = 12'h000;
            is_board_pixel_drawn = 0;
        end
    end
endmodule