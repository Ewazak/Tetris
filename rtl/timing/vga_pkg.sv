//////////////////////////////////////////////////////////////////////////////
/*
 Copyright (C) 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   vga_pkg
 Author:        Piotr Kaczmarczyk
 Modified:      Ewa Żakowska, Adrianna Solińska
 Description:  Package with vga related constants.
 */
//////////////////////////////////////////////////////////////////////////////

 package vga_pkg;

    // Active image area
    localparam HOR_PIXELS = 1024;
    localparam VER_PIXELS = 768;

    // Total time (pixels per line / lines per frame)
    localparam HOR_TOTAL_TIME = 1344;
    localparam VER_TOTAL_TIME = 806;

    // Blanking area
    localparam HOR_BLANK_START = 1024;
    localparam HOR_BLANK_END   = 1344; 

    localparam VER_BLANK_START = 768;
    localparam VER_BLANK_END   = 806;  

    // Synchronization
    localparam HOR_SYNC_START = 1048;
    localparam HOR_SYNC_END   = 1184; 

    localparam VER_SYNC_START = 771;
    localparam VER_SYNC_END   = 777;  

    // Pixel clock (kHz)
    localparam PIXEL_CLOCK = 65000;

endpackage
