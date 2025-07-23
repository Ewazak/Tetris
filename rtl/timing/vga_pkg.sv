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
    localparam HOR_PIXELS = 1024;
    localparam VER_PIXELS = 768;

    // Czas całkowity (pixels per line / lines per frame)
    localparam HOR_TOTAL_TIME = 1344;
    localparam VER_TOTAL_TIME = 806;

    // Obszar wygaszania (blanking)
    localparam HOR_BLANK_START = 1024;
    localparam HOR_BLANK_END   = 1344; // 1240 + 256

    localparam VER_BLANK_START = 768;
    localparam VER_BLANK_END   = 806;  // 768 + 28

    // Synchronizacja
    localparam HOR_SYNC_START = 1048;
    localparam HOR_SYNC_END   = 1184; // 1280 + 128

    localparam VER_SYNC_START = 771;
    localparam VER_SYNC_END   = 777;  // 769 + 4

    // Pixel clock (kHz)
    localparam PIXEL_CLOCK = 65000;

endpackage
