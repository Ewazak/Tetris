/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: player_indicator_text module - displays "PLAYER 1" or "PLAYER 2" label depending on the signal.
*/
module player_indicator_text #(
    parameter int SCALE = 2
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,

    input  logic        is_player1, // 1 → player1, 0 → player2

    output logic [11:0] rgb_out
);

    import vga_pkg::*;

    // -----------------------------
    // Player text definitions
    // -----------------------------
    localparam int LEN = 8;
    localparam logic [6:0] TEXT_PLAYER1 [0:LEN-1] = {
        "P","L","A","Y","E","R"," ","1"
    };
    localparam logic [6:0] TEXT_PLAYER2 [0:LEN-1] = {
        "P","L","A","Y","E","R"," ","2"
    };

    logic [6:0] text_mem [0:LEN-1];

    always_comb begin
        for (int i = 0; i < LEN; i++)
            text_mem[i] = is_player1 ? TEXT_PLAYER1[i] : TEXT_PLAYER2[i];
    end

    // -----------------------------
    // RGB output for each character
    // -----------------------------
    logic [11:0] draw_rgb [0:LEN-1];

    generate
        for (genvar i = 0; i < LEN; i++) begin : gen_text
            draw_rect_char #(
                .ORIGIN_X((HOR_PIXELS - LEN*8*SCALE)/2 + i*8*SCALE),
                .ORIGIN_Y(20),
                .SCALE(SCALE)
            ) u_draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(text_mem[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb[i])
            );
        end
    endgenerate

    // -----------------------------
    // Merge character RGB into final output
    // -----------------------------
    always_comb begin
        rgb_out = rgb_in;
        for (int i = 0; i < LEN; i++) begin
            if (draw_rgb[i] != rgb_in)
                rgb_out = draw_rgb[i];
        end
    end

endmodule