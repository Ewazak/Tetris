//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   points_top
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:  top module combining score counter and score display.
 */
//////////////////////////////////////////////////////////////////////////////
module points_top (
    input  logic clk,
    input  logic reset,
    input  logic [2:0] lines_cleared,
    input  logic add_block,
    input  vga_if vga_in,  
    output vga_if vga_out
);

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    logic [15:0] score;
    logic [11:0] points_rgb;

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
    // Counter
    points_counter u_points_counter (
        .clk(clk),
        .reset(reset),
        .lines_cleared(lines_cleared),
        .add_block(add_block),
        .score(score)
    );

    // Display
    points_display u_points_display (
        .clk    (clk),
        .rst    (reset),
        .score  (score),

        .hcount (vga_in.hcount),
        .vcount (vga_in.vcount),
        .hblnk  (vga_in.hblnk),
        .vblnk  (vga_in.vblnk),
        .rgb_in (vga_in.rgb),
        .rgb_out(points_rgb)
    );

    assign vga_out.hcount = vga_in.hcount;
    assign vga_out.vcount = vga_in.vcount;
    assign vga_out.hsync  = vga_in.hsync;
    assign vga_out.vsync  = vga_in.vsync;
    assign vga_out.hblnk  = vga_in.hblnk;
    assign vga_out.vblnk  = vga_in.vblnk;
    assign vga_out.rgb    = points_rgb;

endmodule