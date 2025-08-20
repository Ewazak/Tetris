module score_screen_rom (
    input  logic        clk,
    input  logic [13:0] addr,        
    output logic [11:0] pixel_data   // kolor RGB z ROM
);

    timeunit 1ns;
    timeprecision 1ps;

    logic [11:0] rom [0:3071];

    initial $readmemh("../../rtl/score_screen/score_screen.dat", rom);

    always_ff @(posedge clk) begin
        pixel_data <= rom[addr];
    end

endmodule