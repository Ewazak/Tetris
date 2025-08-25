/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: player_indicator_text module - displays "PLAYER 1" or "PLAYER 2" label depending on the signal.
*/
module player_indicator_text #(
    parameter SCALE = 2,
    parameter LATENCY = 2
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,

    input  logic        is_player1, // 1 → player1, 0 → player2

    // font bus
    output logic        font_req,
    output logic [10:0] font_addr,
    input  logic [7:0]  font_data,
    input  logic        font_grant,

    output logic [11:0] rgb_out
);

    import vga_pkg::*;

    // -----------------------------
    // Player text definitions
    // -----------------------------
    localparam LEN = 8;
    localparam logic [6:0] TEXT_PLAYER1 [0:LEN-1] = {
        "P","L","A","Y","E","R"," ","1"
    };
    localparam logic [6:0] TEXT_PLAYER2 [0:LEN-1] = {
        "P","L","A","Y","E","R"," ","2"
    };

    logic [6:0] text_mem [0:LEN-1];
    integer i;
    always_comb for (i = 0; i < LEN; i = i + 1) text_mem[i] = is_player1 ? TEXT_PLAYER1[i] : TEXT_PLAYER2[i];

    logic [11:0] draw_rgb [0:LEN-1];

    logic [7:0] font_data_reg;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) font_data_reg <= 8'h00;
        else if (font_grant) font_data_reg <= font_data;
    end

    function automatic void future_pos(input integer add, input integer cur_h, input integer cur_v,
                                       output integer out_h, output integer out_v);
        integer nh; integer nv;
        nh = cur_h + add; nv = cur_v;
        if (nh >= HOR_PIXELS) begin nh = nh - HOR_PIXELS; nv = nv + 1; end
        out_h = nh; out_v = nv;
    endfunction

    // Compute address
    logic req_local;
    logic [10:0] addr_local;
    localparam CHAR_W = 8;
    localparam CHAR_H = 16;
    localparam ORIGIN_Y = 20;
    localparam ORIGIN_X = (HOR_PIXELS - LEN*CHAR_W*SCALE)/2;
    integer ph; integer pv; integer idx; integer line;
    always_comb begin
        req_local = 1'b0;
        addr_local = 11'd0;
        ph = 0; pv = 0; idx = 0; line = 0;
        future_pos(LATENCY, hcount, vcount, ph, pv);

        if (pv >= ORIGIN_Y && pv < ORIGIN_Y + CHAR_H*SCALE) begin
            if (ph >= ORIGIN_X && ph < ORIGIN_X + LEN*CHAR_W*SCALE) begin
                idx = (ph - ORIGIN_X) / (CHAR_W*SCALE);
                line = ((pv - ORIGIN_Y)/SCALE) % CHAR_H;
                req_local = 1'b1;
                addr_local = { text_mem[idx], line[3:0] };
            end
        end
    end

    assign font_req  = req_local;
    assign font_addr = addr_local;

    genvar gi;
    generate
        for (gi = 0; gi < LEN; gi = gi + 1) begin : gen_text
            draw_rect_char #(
                .ORIGIN_X(ORIGIN_X + gi*CHAR_W*SCALE),
                .ORIGIN_Y(ORIGIN_Y),
                .SCALE(SCALE)
            ) u_draw_inst (
                .clk(clk),
                .rst(rst),
                .char_line_pixels(font_data_reg),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb[gi])
            );
        end
    endgenerate

    // -----------------------------
    // Merge character RGB into final output
    // -----------------------------
    always_comb begin
        rgb_out = rgb_in;
        for (i = 0; i < LEN; i++)
            if (draw_rgb[i] != rgb_in)
                rgb_out = draw_rgb[i];
    end

endmodule