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
//Horizontal
        always_ff @(posedge clk) begin
            if (rst == 1'b1) begin
                hcount <= '0;
                hblnk  <= '0;
                hsync  <= '0;
            end else begin
                if (hcount == HOR_TOTAL_TIME -1) begin
                    hcount <= '0;
                end else begin
                    hcount <= hcount + 1;
                end
                hblnk <= (hcount >= HOR_BLANK_START-1) && (hcount < HOR_BLANK_END-1);
                hsync <= (hcount >= HOR_SYNC_START-1) && (hcount < HOR_SYNC_END-1);
            end
        end
        //Vertical
        always_ff @(posedge clk) begin
            if (rst == 1'b1) begin
                vcount <= '0;
                vblnk  <= '0;
                vsync  <= '0;
            end else begin
                if (hcount == HOR_TOTAL_TIME -1) begin
                    if (vcount == VER_TOTAL_TIME -1) begin
                        vcount <= '0;
                    end else begin
                        vcount <= vcount + 1;
                    end
                end
                vblnk <= (vcount >= VER_BLANK_START) && (vcount < VER_BLANK_END);
                vsync <= (vcount >= VER_SYNC_START) && (vcount < VER_SYNC_END);
            end
        end
        endmodule