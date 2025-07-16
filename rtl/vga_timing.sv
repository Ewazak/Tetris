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
        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                hcount <= '0;
            end else if (hcount == HOR_TOTAL_TIME -1) begin
                hcount <= '0;
            end else begin
                hcount <= hcount + 1;
            end
        end
        //Vertical
        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                vcount <= '0;
            end else if (hcount == HOR_TOTAL_TIME -1) begin
                if (vcount == VER_TOTAL_TIME -1)
                    vcount <= '0;
                else
                    vcount <= vcount + 1;
            end
        end

    // Poziome
    assign hblnk = (hcount >= HOR_BLANK_START) && (hcount < HOR_BLANK_END);
    assign hsync = (hcount >= HOR_SYNC_START)  && (hcount < HOR_SYNC_END);

    // Pionowe
    assign vblnk = (vcount >= VER_BLANK_START) && (vcount < VER_BLANK_END);
    assign vsync = (vcount >= VER_SYNC_START)  && (vcount < VER_SYNC_END);

endmodule