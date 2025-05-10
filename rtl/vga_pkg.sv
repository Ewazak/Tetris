/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

package vga_pkg;

    // Horizontal and vertical parameters
    localparam HOR_PIXELS = 800;
    localparam VER_PIXELS = 600;

    localparam HOR_TOTAL_TIME = 1056;
    localparam VER_TOTAL_TIME = 628;

    localparam HOR_BLANK_START = 800;
    localparam HOR_BLANK_END = 1055;

    localparam HOR_SYNC_START = 840;
    localparam HOR_SYNC_END = 967;

    localparam VER_BLANK_START = 600;
    localparam VER_BLANK_END = 627;

    localparam VER_SYNC_START = 601;
    localparam VER_SYNC_END = 604;

    // Pixel clock
    localparam PIXEL_CLOCK = 40000;

endpackage
