/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: score_screen_text module - displays the score screen text 
*              (players scores and match result).
*/
module score_screen_text #(
    parameter int SCALE = 4
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic hblnk,
    input  logic vblnk,
    input  logic [11:0] rgb_in,
    input  logic [15:0] my_score,
    input  logic [15:0] enemy_score,
    output logic [11:0] rgb_out
);
    import vga_pkg::*;

    localparam int LEN_SCORE = 15;
    localparam logic [6:0] BASE_PLAYER1 [0:LEN_SCORE-1] = {
        "P","L","A","Y","E","R"," ","1",":"," ","0","0","0","0","0"
    };
    localparam logic [6:0] BASE_PLAYER2 [0:LEN_SCORE-1] = {
        "P","L","A","Y","E","R"," ","2",":"," ","0","0","0","0","0"
    };

    // Final result
    localparam int LEN_RESULT_MAX = 12;
    localparam logic [6:0] TEXT_WON1 [0:LEN_RESULT_MAX-1] = {
        "P","L","A","Y","E","R"," ","1"," ","W","O","N"
    };
    localparam logic [6:0] TEXT_WON2 [0:LEN_RESULT_MAX-1] = {
        "P","L","A","Y","E","R"," ","2"," ","W","O","N"
    };
    localparam logic [6:0] TEXT_DRAW [0:LEN_RESULT_MAX-1] = {
        "D","R","A","W"," "," "," "," "," "," "," "," "
    };

    // -------------------------------
    // Score conversion from binary to ASCII digits
    // -------------------------------
    logic [6:0] my_score_ascii [0:4];
    logic [6:0] enemy_score_ascii [0:4];

    function logic [6:0] digit_to_ascii(input logic [3:0] d);
        return 7'd48 + d; // '0' + d
    endfunction

    always_comb begin
        logic [15:0] temp;

        // PLAYER 1 score
        temp = my_score;
        for (int i = 4; i >= 0; i--) begin
            my_score_ascii[i] = digit_to_ascii(temp % 10);
            temp = temp / 10;
        end

        // PLAYER 2 score
        temp = enemy_score;
        for (int i = 4; i >= 0; i--) begin
            enemy_score_ascii[i] = digit_to_ascii(temp % 10);
            temp = temp / 10;
        end
    end

    // -------------------------------
    // Final text
    // -------------------------------
    logic [6:0] text_left [0:LEN_SCORE-1];
    logic [6:0] text_right[0:LEN_SCORE-1];
    logic [6:0] text_result[0:LEN_RESULT_MAX-1];

    always_comb begin
        // PLAYER 1 (with score)
        for (int i = 0; i < LEN_SCORE; i++) begin
            if (i >= 10 && i <= 14)
                text_left[i] = my_score_ascii[i-10];
            else
                text_left[i] = BASE_PLAYER1[i];
        end

        // PLAYER 2 (with score)
        for (int i = 0; i < LEN_SCORE; i++) begin
            if (i >= 10 && i <= 14)
                text_right[i] = enemy_score_ascii[i-10];
            else
                text_right[i] = BASE_PLAYER2[i];
        end

        // RESULT
        if (my_score > enemy_score) begin
            for (int i = 0; i < LEN_RESULT_MAX; i++)
                text_result[i] = TEXT_WON1[i];
        end else if (my_score < enemy_score) begin
            for (int i = 0; i < LEN_RESULT_MAX; i++)
                text_result[i] = TEXT_WON2[i];
        end else begin
            for (int i = 0; i < LEN_RESULT_MAX; i++)
                text_result[i] = TEXT_DRAW[i];
        end
    end

    // -------------------------------
    // Text drawing positions
    // -------------------------------
    localparam int ORIGIN_Y_SCORE  = 100;
    localparam int ORIGIN_Y_RESULT = 250;

    logic [11:0] draw_rgb_left [0:LEN_SCORE-1];
    logic [11:0] draw_rgb_right[0:LEN_SCORE-1];
    logic [11:0] draw_rgb_result[0:LEN_RESULT_MAX-1];

    // LEFT
    generate
        for (genvar i = 0; i < LEN_SCORE; i++) begin : draw_left
            draw_rect_char #(
                .ORIGIN_X(50 + i*8*SCALE),
                .ORIGIN_Y(ORIGIN_Y_SCORE),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(text_left[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb_left[i])
            );
        end
    endgenerate

    // RIGHT
    generate
        for (genvar i = 0; i < LEN_SCORE; i++) begin : draw_right
            draw_rect_char #(
                .ORIGIN_X(HOR_PIXELS - (LEN_SCORE*8*SCALE) + i*8*SCALE),
                .ORIGIN_Y(ORIGIN_Y_SCORE),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(text_right[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb_right[i])
            );
        end
    endgenerate

    // RESULT (centered)
    generate
        for (genvar i = 0; i < LEN_RESULT_MAX; i++) begin : draw_result
            draw_rect_char #(
                .ORIGIN_X((HOR_PIXELS - LEN_RESULT_MAX*8*SCALE)/2 + i*8*SCALE),
                .ORIGIN_Y(ORIGIN_Y_RESULT),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(text_result[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb_result[i])
            );
        end
    endgenerate

    // -------------------------------
    // Merging RGB outputs
    // -------------------------------
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        // LEFT
        for (int i = 0; i < LEN_SCORE; i++)
            if (draw_rgb_left[i] != rgb_in) rgb_nxt = draw_rgb_left[i];
        // RIGHT
        for (int i = 0; i < LEN_SCORE; i++)
            if (draw_rgb_right[i] != rgb_in) rgb_nxt = draw_rgb_right[i];
        // RESULT
        for (int i = 0; i < LEN_RESULT_MAX; i++)
            if (draw_rgb_result[i] != rgb_in) rgb_nxt = draw_rgb_result[i];
    end

    always_ff @(posedge clk) begin
        if (rst)
            rgb_out <= 12'h000;
        else
            rgb_out <= rgb_nxt;
    end

endmodule
