/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: points_display module - renders the current game score on the screen.
* It dynamically draws "SCORE:" and the 0–99999 score using draw_rect_char instances.
*/
module points_display #(
    parameter SCALE = 2,
    parameter POS_X = 0,
    parameter POS_Y = 0
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] score,     
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,    
    output logic [11:0] rgb_out    
);

    // -----------------------------
    // Parameters
    // -----------------------------
    localparam LEN = 11; // "SCORE:" (6) + 5 digits

    logic [6:0] score_line [0:LEN-1]; 
    logic [11:0] char_rgb [0:LEN-1];
    logic [15:0] tmp;
    integer i;

    // -----------------------------
    // Generate ASCII for "SCORE:" + digits    
    // -----------------------------
    always_comb begin
        // Space
        for (i = 0; i < LEN; i = i + 1)
            score_line[i] = 7'h20;

        // Text "SCORE:"
        score_line[0] = "S";
        score_line[1] = "C";
        score_line[2] = "O";
        score_line[3] = "R";
        score_line[4] = "E";
        score_line[5] = ":";

        // Score into numbers
        tmp = score;
        for (i = 0; i < 5; i = i + 1) begin
            score_line[LEN-1-i] = 7'h30 + (tmp % 10);
            tmp = tmp / 10;
        end
    end

    genvar gi;
    generate
        for (gi = 0; gi < LEN; gi = gi + 1) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(POS_X + gi*8*SCALE),
                .ORIGIN_Y(POS_Y),
                .SCALE(SCALE)
            ) char_inst (
                .clk(clk),
                .rst(rst),
                .char_code(score_line[gi]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(char_rgb[gi])
            );
        end
    endgenerate

    // -----------------------------
    // Combining characters into one RGB signal
    // -----------------------------
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        for (i = 0; i < LEN; i = i + 1) begin
            if (char_rgb[i] != rgb_in)
                rgb_nxt = char_rgb[i];
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            rgb_out <= 12'h000;
        else
            rgb_out <= rgb_nxt;
    end

endmodule