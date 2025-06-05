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

    // Horizontal timing
    always_ff @(posedge clk) begin
        if (rst) begin
            hcount <= 0;
            hblnk  <= 0;
            hsync  <= 1;
        end else begin
            if (hcount == HOR_TOTAL_TIME - 1)
                hcount <= 0;
            else
                hcount <= hcount + 1;

            hblnk <= (hcount >= HOR_BLANK_START);
            hsync <= ~((hcount >= HOR_SYNC_START) &&
                       (hcount < HOR_SYNC_END));
        end
    end

    // Vertical timing
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount <= 0;
            vblnk  <= 0;
            vsync  <= 1;
        end else begin
            if (hcount == HOR_TOTAL_TIME - 1) begin
                if (vcount == VER_TOTAL_TIME - 1)
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
            end

            vblnk <= (vcount >= VER_BLANK_START);
            vsync <= ~((vcount >= VER_SYNC_START) &&
                       (vcount < VER_SYNC_END));
        end
    end

endmodule


      

