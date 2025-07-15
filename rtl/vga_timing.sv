/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */

 module vga_timing (
    input  logic clk,
    input  logic rst,

    output logic [10:0] vcount,
    output logic vsync,
    output logic vblnk,
    output logic [10:0] hcount,
    output logic hsync,
    output logic hblnk
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [10:0] vcount_nxt, hcount_nxt;
logic vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;

//------------------------------------------------------------------------------
// output registers with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        vcount <= 0;
        hcount <= 0;
        vsync  <= 1;
        vblnk  <= 0;
        hsync  <= 1;
        hblnk  <= 0;
    end else begin
        vcount <= vcount_nxt;
        hcount <= hcount_nxt;
        vsync  <= vsync_nxt;
        vblnk  <= vblnk_nxt;
        hsync  <= hsync_nxt;
        hblnk  <= hblnk_nxt;
    end
end

//------------------------------------------------------------------------------
// combinational logic
//------------------------------------------------------------------------------
always_comb begin
    if (hcount == HOR_TOTAL_TIME - 1) begin
        hcount_nxt = 0;
        if (vcount == VER_TOTAL_TIME - 1) begin
            vcount_nxt = 0;
            vblnk_nxt = 0;
        end else begin
            vcount_nxt = vcount + 1;
            vblnk_nxt = (vcount + 1 >= VER_BLANK_START) && (vcount + 1 < VER_TOTAL_TIME);
        end
        vsync_nxt = ((vcount + 1 >= VER_SYNC_START) && (vcount + 1 < VER_SYNC_END));
    end else begin
        hcount_nxt = hcount + 1;
        vcount_nxt = vcount;
        vblnk_nxt = vblnk;
        vsync_nxt = vsync;
    end

    hblnk_nxt = (hcount >= HOR_BLANK_START) && (hcount < HOR_BLANK_END);
    hsync_nxt = (hcount >= HOR_SYNC_START) && (hcount < HOR_SYNC_END);
    hsync_nxt = ~hsync_nxt;
    vsync_nxt = ~vsync_nxt;
end

endmodule


      

