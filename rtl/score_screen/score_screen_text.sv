/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: score_screen_text module - displays the score screen text 
*              (players scores and match result).
*/
module score_screen_text #(
    parameter SCALE = 3,
    parameter LATENCY = 2
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
    input  logic is_player1,         // local player

    // font client ports
    input  logic [7:0]  font_data,
    input  logic        font_grant,
    output logic        font_req,
    output logic [10:0] font_addr,

    output logic [11:0] rgb_out
);
    import vga_pkg::*;

    localparam LEN_SCORE   = 15;
    localparam LEN_RESULT = 12;

    localparam logic [6:0] PLAYER1_LABEL [0:LEN_SCORE-1] = {
        "P","L","A","Y","E","R"," ","1",":"," ","0","0","0","0","0"
    };
    localparam logic [6:0] PLAYER2_LABEL [0:LEN_SCORE-1] = {
        "P","L","A","Y","E","R"," ","2",":"," ","0","0","0","0","0"
    };

    // Final result
    localparam logic [6:0] RESULT_WIN1 [0:LEN_RESULT-1] = {
        "P","L","A","Y","E","R"," ","1"," ","W","O","N"
    };
    localparam logic [6:0] RESULT_WIN2 [0:LEN_RESULT-1] = {
        "P","L","A","Y","E","R"," ","2"," ","W","O","N"
    };
    localparam logic [6:0] RESULT_DRAW [0:LEN_RESULT-1] = {
        " "," "," "," ","D","R","A","W"," "," "," "," "
    };

    // -------------------------------
    // Score conversion from binary to ASCII digits
    // -------------------------------
    logic [6:0] my_ascii [0:4];
    logic [6:0] enemy_ascii [0:4];

    bin_ascii_sync u_my_score_ascii (
        .clk(clk), .rst(rst),
        .bin_in(my_score),
        .ascii_0(my_ascii[0]),
        .ascii_1(my_ascii[1]),
        .ascii_2(my_ascii[2]),
        .ascii_3(my_ascii[3]),
        .ascii_4(my_ascii[4])
    );

    bin_ascii_sync u_enemy_score_ascii (
        .clk(clk), .rst(rst),
        .bin_in(enemy_score),
        .ascii_0(enemy_ascii[0]),
        .ascii_1(enemy_ascii[1]),
        .ascii_2(enemy_ascii[2]),
        .ascii_3(enemy_ascii[3]),
        .ascii_4(enemy_ascii[4])
    );

    logic [6:0] text_left  [0:LEN_SCORE-1];
    logic [6:0] text_right [0:LEN_SCORE-1];
    logic [6:0] text_result[0:LEN_RESULT-1];

    integer ii;
    always_comb begin
        if (is_player1) begin
            for (ii = 0; ii < LEN_SCORE; ii = ii + 1) begin
                text_left[ii]  = PLAYER1_LABEL[ii];
                text_right[ii] = PLAYER2_LABEL[ii];
            end
            for (ii = 0; ii < 5; ii = ii + 1) begin
                text_left[10+ii]  = (my_ascii[ii] == 0) ? "0" : my_ascii[ii];
                text_right[10+ii] = (enemy_ascii[ii] == 0) ? "0" : enemy_ascii[ii];
            end
            if (my_score > enemy_score)
                for (ii = 0; ii < LEN_RESULT; ii = ii + 1) text_result[ii] = RESULT_WIN1[ii];
            else if (my_score < enemy_score)
                for (ii = 0; ii < LEN_RESULT; ii = ii + 1) text_result[ii] = RESULT_WIN2[ii];
            else
                for (ii = 0; ii < LEN_RESULT; ii = ii + 1) text_result[ii] = RESULT_DRAW[ii];
        end else begin
            for (ii = 0; ii < LEN_SCORE; ii = ii + 1) begin
                text_left[ii]  = PLAYER2_LABEL[ii];
                text_right[ii] = PLAYER1_LABEL[ii];
            end
            for (ii = 0; ii < 5; ii = ii + 1) begin
                text_left[10+ii]  = (my_ascii[ii] == 0) ? "0" : my_ascii[ii];
                text_right[10+ii] = (enemy_ascii[ii] == 0) ? "0" : enemy_ascii[ii];
            end
            if (my_score > enemy_score)
                for (ii = 0; ii < LEN_RESULT; ii = ii + 1) text_result[ii] = RESULT_WIN2[ii];
            else if (my_score < enemy_score)
                for (ii = 0; ii < LEN_RESULT; ii = ii + 1) text_result[ii] = RESULT_WIN1[ii];
            else
                for (ii = 0; ii < LEN_RESULT; ii = ii + 1) text_result[ii] = RESULT_DRAW[ii];
        end
    end

    localparam CHAR_W = 8;
    localparam CHAR_H = 16;

    localparam int X_ORIGIN = (HOR_PIXELS - LEN_SCORE*CHAR_W*SCALE)/2;
    localparam int X_RESULT = (HOR_PIXELS - LEN_RESULT*CHAR_W*SCALE)/2;

    localparam int Y_SCORE1 = 220;
    localparam int Y_SCORE2 = Y_SCORE1 + CHAR_H*SCALE + 40;
    localparam int Y_RESULT = Y_SCORE2 + CHAR_H*SCALE + 60;

    logic [11:0] draw_rgb_left  [0:LEN_SCORE-1];
    logic [11:0] draw_rgb_right [0:LEN_SCORE-1];
    logic [11:0] draw_rgb_result[0:LEN_RESULT-1];

    logic [7:0] font_data_reg;
    always_ff @(posedge clk) begin
        if (rst) font_data_reg <= 8'h00;
        else if (font_grant) font_data_reg <= font_data;
    end

    function automatic void future_pos(input int add, input int cur_h, input int cur_v,
                                       output int out_h, output int out_v);
        int nh; int nv;
        nh = cur_h + add; nv = cur_v;
        if (nh >= HOR_PIXELS) begin nh -= HOR_PIXELS; nv += 1; end
        out_h = nh; out_v = nv;
    endfunction

    logic req_local;
    logic [10:0] addr_local;
    integer ph,pv,idx,line;
    always_comb begin
        req_local  = 0;
        addr_local = 0;
        future_pos(LATENCY, hcount, vcount, ph, pv);

        // First score line (local player)
        if (pv >= Y_SCORE1 && pv < Y_SCORE1 + CHAR_H*SCALE &&
            ph >= X_ORIGIN && ph < X_ORIGIN + LEN_SCORE*CHAR_W*SCALE) begin
            idx  = (ph - X_ORIGIN) / (CHAR_W*SCALE);
            line = ((pv - Y_SCORE1)/SCALE) % CHAR_H;
            req_local  = 1;
            addr_local = { text_left[idx], line[3:0] };
        end
        // Second score line (rival player)
        else if (pv >= Y_SCORE2 && pv < Y_SCORE2 + CHAR_H*SCALE &&
                 ph >= X_ORIGIN && ph < X_ORIGIN + LEN_SCORE*CHAR_W*SCALE) begin
            idx  = (ph - X_ORIGIN) / (CHAR_W*SCALE);
            line = ((pv - Y_SCORE2)/SCALE) % CHAR_H;
            req_local  = 1;
            addr_local = { text_right[idx], line[3:0] };
        end

        // RESULT
        else if (pv >= Y_RESULT && pv < Y_RESULT + CHAR_H*SCALE &&
                 ph >= X_RESULT && ph < X_RESULT + LEN_RESULT*CHAR_W*SCALE) begin
            idx  = (ph - X_RESULT) / (CHAR_W*SCALE);
            line = ((pv - Y_RESULT)/SCALE) % CHAR_H;
            req_local  = 1;
            addr_local = { text_result[idx], line[3:0] };
        end
    end

    assign font_req  = req_local;
    assign font_addr = addr_local;

    genvar gi;
    generate
        // Local player
        for (gi = 0; gi < LEN_SCORE; gi++) begin
            draw_rect_char #(
                .ORIGIN_X(X_ORIGIN + gi*CHAR_W*SCALE),
                .ORIGIN_Y(Y_SCORE1),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_line_pixels(font_data_reg),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb_left[gi])
            );
        end
        // Rival player
        for (gi = 0; gi < LEN_SCORE; gi++) begin
            draw_rect_char #(
                .ORIGIN_X(X_ORIGIN + gi*CHAR_W*SCALE),
                .ORIGIN_Y(Y_SCORE2),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_line_pixels(font_data_reg),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb_right[gi])
            );
        end
    // RESULT (centered)
        for (gi = 0; gi < LEN_RESULT; gi++) begin
            draw_rect_char #(
                .ORIGIN_X(X_RESULT + gi*CHAR_W*SCALE),
                .ORIGIN_Y(Y_RESULT),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_line_pixels(font_data_reg),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb_result[gi])
            );
        end
    endgenerate

    // -------------------------------
    // Merging RGB outputs
    // -------------------------------
    always_comb begin
        rgb_out = rgb_in;
        for (ii = 0; ii < LEN_SCORE; ii++) begin
            if (draw_rgb_left[ii]  != rgb_in) rgb_out = draw_rgb_left[ii];
            if (draw_rgb_right[ii] != rgb_in) rgb_out = draw_rgb_right[ii];
        end
        for (ii = 0; ii < LEN_RESULT; ii++) begin
            if (draw_rgb_result[ii] != rgb_in) rgb_out = draw_rgb_result[ii];
        end
    end

endmodule
