/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

 package vga_pkg;

    // Aktywna część obrazu
    localparam HOR_PIXELS = 1240;
    localparam VER_PIXELS = 768;

    // Czas całkowity (pixels per line / lines per frame)
    localparam HOR_TOTAL_TIME = 1056;
    localparam VER_TOTAL_TIME = 796;

    // Obszar wygaszania (blanking)
    localparam HOR_BLANK_START = 1240;
    localparam HOR_BLANK_END   = 1056; // 1240 + 256

    localparam VER_BLANK_START = 768;
    localparam VER_BLANK_END   = 796;  // 768 + 28

    // Synchronizacja
    localparam HOR_SYNC_START = 1280;
    localparam HOR_SYNC_END   = 1408; // 1280 + 128

    localparam VER_SYNC_START = 769;
    localparam VER_SYNC_END   = 773;  // 769 + 4

    // Pixel clock (kHz)
    localparam PIXEL_CLOCK = 40000;

endpackage
