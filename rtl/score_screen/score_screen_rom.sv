//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   score_screen_rom
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:  stores the score screen image as 12-bit RGB pixel data,
               initialized from .dat file.
 */
//////////////////////////////////////////////////////////////////////////////
module score_screen_rom (
    input  logic clk,         // posedge active clock
    input  logic [13:0] addr, // pixel address
    output logic [11:0] pixel_data   // RGB color from ROM
);

    timeunit 1ns;
    timeprecision 1ps;

    logic [11:0] rom [0:3071];

    initial
        $readmemh("../../rtl/score_screen/score_screen.dat", rom);

    always_ff @(posedge clk) begin : rom_read_blk
        pixel_data <= rom[addr];
    end

endmodule