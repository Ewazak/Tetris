/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: game_over_screen_rom module - stores the "Game Over" image as 12-bit RGB pixel data,
*              initialized from .dat file.
*/
module game_over_screen_rom (
    input  logic        clk,
    input  logic [13:0] addr,        
    output logic [11:0] pixel_data   // RGB color from ROM
);

    timeunit 1ns;
    timeprecision 1ps;

    logic [11:0] rom [0:12287];

    initial $readmemh("../../rtl/game_over_screen/game_over_screen.dat", rom);

    always_ff @(posedge clk) begin
        pixel_data <= rom[addr];
    end

endmodule