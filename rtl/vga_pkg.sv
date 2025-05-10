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
    localparam HOR_PIXELS = 1024;           // Szerokość obrazu w pikselach
    localparam VER_PIXELS = 768;            // Wysokość obrazu w pikselach

    localparam HOR_TOTAL_TIME = 1344;       // Całkowity czas poziomy (w pikselach, z blankingiem)
    localparam VER_TOTAL_TIME = 806;        // Całkowity czas pionowy (w liniach, z blankingiem)

    localparam HOR_BLANK_START = 1024;      // Początek poziomego blankingu
    localparam HOR_BLANK_END = 1343;        // Koniec poziomego blankingu

    localparam HOR_SYNC_START = 1048;       // Początek poziomego sygnału synchronizacji
    localparam HOR_SYNC_END = 1183;         // Koniec poziomego sygnału synchronizacji

    localparam VER_BLANK_START = 768;       // Początek pionowego blankingu
    localparam VER_BLANK_END = 805;         // Koniec pionowego blankingu

    localparam VER_SYNC_START = 771;        // Początek pionowego sygnału synchronizacji
    localparam VER_SYNC_END = 775;          // Koniec pionowego sygnału synchronizacji

    // Pixel clock (dla 1024x768, przy 60Hz)
    localparam PIXEL_CLOCK = 65000;      // Częstotliwość zegara piksela

endpackage