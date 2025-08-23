/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: block_draw module - draws a 4x4 block at given position with color based on type.
*/
module block_draw (
    input  logic [10:0] hcount,       // current pixel X
    input  logic [10:0] vcount,       // current pixel Y
    input  logic [10:0] block_pos_x,  // block position X in pixels
    input  logic [10:0] block_pos_y,  // block position Y in pixels
    input  logic [3:0][3:0] block_map,// 4x4 block map (1 = occupied)
    input  logic [2:0] block_type,    // block type (for color selection)
    output logic [11:0] rgb_out,      // pixel color (12-bit RGB)
    output logic is_block_pixel_drawn // flag if block pixel is drawn
);

    localparam BLOCK_SIZE = 32; // size of a single block cell in pixels

    logic inside_block_area;
    logic [1:0] block_x, block_y;

    always_comb begin
        rgb_out = 12'h000; // black background by default
        is_block_pixel_drawn = 1'b0;
        
        // Check if pixel is inside the 4x4 block area (4 cells * BLOCK_SIZE)
        inside_block_area = (hcount >= block_pos_x) && (hcount < block_pos_x + 4*BLOCK_SIZE) &&
                            (vcount >= block_pos_y) && (vcount < block_pos_y + 4*BLOCK_SIZE);

        if (inside_block_area) begin
            // Compute matrix indices (0..3)
            block_x = (hcount - block_pos_x) / BLOCK_SIZE;
            block_y = (vcount - block_pos_y) / BLOCK_SIZE;

            // If the cell is occupied, set pixel color depending on block type
            if (block_map[block_y][block_x]) begin
                is_block_pixel_drawn = 1'b1;
                case (block_type)
                    3'd1: rgb_out = 12'hF00; // red (I-block)
                    3'd2: rgb_out = 12'hFF0; // yellow (O-block)
                    3'd3: rgb_out = 12'hF0F; // magenta (T-block)
                    3'd4: rgb_out = 12'h0F0; // green (S-block)
                    3'd5: rgb_out = 12'hF60; // orange (Z-block)
                    3'd6: rgb_out = 12'h00F; // blue (J-block)
                    3'd7: rgb_out = 12'h0FF; // cyan (L-block)
                    default: rgb_out = 12'h888; // gray for others
                endcase
        end
    end
end

endmodule

