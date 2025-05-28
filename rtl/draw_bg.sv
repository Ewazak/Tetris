/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

 module draw_bg (
    input  logic clk,
    input  logic rst,
    input logic [10:0] vcount_in,
    input logic        vsync_in,
    input logic        vblnk_in,
    input logic [10:0] hcount_in,
    input logic        hsync_in,
    input logic        hblnk_in, 
    vga_if.out out 
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local variables and signals
     */
    logic [11:0] rgb_nxt;

    /**
     * Internal logic
     */
    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync  <= '0;
            out.hblnk  <= '0;
            out.rgb   <= '0;
        end else begin
            out.vcount <= vcount_in;
            out.vsync  <= vsync_in;
            out.vblnk  <= vblnk_in;
            out.hcount <= hcount_in;
            out.hsync  <= hsync_in;
            out.hblnk  <= hblnk_in;
            out.rgb   <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (vblnk_in || hblnk_in) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it black.
        end else begin                              // Active region:
            if (vcount_in == 0)                     // - top edge:
                rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            else if (vcount_in == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'hf_0_0;                // - - make a red line.
            else if (hcount_in == 1)               // - left edge:
                rgb_nxt = 12'h0_f_0;               // - - make a green line.
            else if (hcount_in == HOR_PIXELS - 1)   // - right edge:
                rgb_nxt = 12'h0_0_f;                // - - make a blue line.
            //Letter E
            else if (
                // Górna pozioma kreska
                (vcount_in >= 200 && vcount_in <= 220 && hcount_in >= 300 && hcount_in <= 380) ||
                // Środkowa pozioma kreska
                (vcount_in >= 245 && vcount_in <= 255 && hcount_in >= 300 && hcount_in <= 370) ||
                // Dolna pozioma kreska
                (vcount_in >= 280 && vcount_in <= 300 && hcount_in >= 300 && hcount_in <= 380) ||
                // Pionowa kreska po lewej
                (vcount_in >= 200 && vcount_in <= 300 && hcount_in >= 300 && hcount_in <= 320)
            )
                rgb_nxt = 12'hFFF;  // Biały kolor
                    
            //Letter Ż   
            else if (
                // Górna pozioma kreska
                (vcount_in >= 200 && vcount_in <= 220 && hcount_in >= 400 && hcount_in <= 480) ||
                // Dolna pozioma kreska
                (vcount_in >= 280 && vcount_in <= 300 && hcount_in >= 400 && hcount_in <= 480) ||
                // Przekątna kreska
                (((hcount_in)==(VER_TOTAL_TIME - vcount_in )*8/10+140) && (hcount_in<=480) && (vcount_in<=300)) || 
                (((hcount_in)==(VER_TOTAL_TIME - vcount_in )*8/10+138) && (hcount_in<=480) && (vcount_in<=300)) ||
                (((hcount_in)==(VER_TOTAL_TIME - vcount_in )*8/10+139) && (hcount_in<=480) && (vcount_in<=300)) ||
                (((hcount_in)==(VER_TOTAL_TIME - vcount_in )*8/10+141) && (hcount_in<=480) && (vcount_in<=300)) ||
                (((hcount_in)==(VER_TOTAL_TIME - vcount_in )*8/10+142) && (hcount_in<=480) && (vcount_in<=300)) ||
                
                // Kropka nad literą
                (vcount_in >= 170 && vcount_in <= 190 && hcount_in >= 430 && hcount_in <= 450)
            )
                rgb_nxt = 12'hFFF;  // Biały kolor
                
            else                                    // The rest of active display pixels:
                rgb_nxt = 12'h8_8_8;                // - fill with gray.
                
            
    end
end

endmodule






