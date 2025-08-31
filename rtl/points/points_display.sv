//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   points_display
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:  renders the current game score on the screen.
 It dynamically draws "SCORE:" and the 0–99999 score using draw_rect_char instances.
 */
//////////////////////////////////////////////////////////////////////////////
module points_display #(
    parameter SCALE = 2,
    parameter POS_X = 0,
    parameter POS_Y = 0,
    parameter LATENCY = 2
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] score,     
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,

    // font bus
    output logic        font_req,
    output logic [10:0] font_addr,
    input  logic [7:0]  font_data,
    input  logic        font_grant,

    output logic [11:0] rgb_out
);

    import vga_pkg::*;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
    localparam LEN = 11; // "SCORE:" (6) + 5 digits
    localparam CHAR_W = 8;
    localparam CHAR_H = 16;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    logic [6:0] score_line [0:LEN-1]; 
    logic [11:0] char_rgb [0:LEN-1];
    logic [15:0] tmp;
    integer i;
    logic [7:0] font_data_reg;
    logic req_local;
    logic [10:0] addr_local;
    integer ph;
    integer pv;
    integer idx;
    integer line;
    logic [11:0] rgb_nxt;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : rgb_out_reg_blk
        if (rst) begin : rgb_out_reg_rst_blk
            rgb_out <= 12'h000;
        end else begin : rgb_out_reg_run_blk
            rgb_out <= rgb_nxt;
        end
    end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
    // Generate ASCII for "SCORE:" + digits
    always_comb begin : score_to_ascii_comb
        integer i;
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

    // Pipeline stages
    always_ff @(posedge clk) begin : font_data_reg_blk
        if (rst) begin : font_data_reg_rst_blk
            font_data_reg <= 8'h00;
        end else begin : font_data_reg_run_blk
            if (font_grant) font_data_reg <= font_data;
        end
    end

    function automatic void future_pos(input integer add, input integer cur_h, input integer cur_v,
                                       output integer out_h, output integer out_v);
        integer nh; integer nv;
        nh = cur_h + add; nv = cur_v;
        if (nh >= HOR_PIXELS) begin nh = nh - HOR_PIXELS; nv = nv + 1; end
        out_h = nh; out_v = nv;
    endfunction

    // Compute addresses
    always_comb begin : font_addr_comb
        req_local = 1'b0;
        addr_local = 11'd0;
        ph = 0; pv = 0; idx = 0; line = 0;
        future_pos(LATENCY, hcount, vcount, ph, pv);

        if (pv >= POS_Y && pv < POS_Y + CHAR_H*SCALE) begin
            if (ph >= POS_X && ph < POS_X + LEN*CHAR_W*SCALE) begin
                idx = (ph - POS_X) / (CHAR_W*SCALE);
                line = ((pv - POS_Y)/SCALE) % CHAR_H;
                req_local = 1'b1;
                addr_local = { score_line[idx], line[3:0] };
            end
        end
    end

    assign font_req  = req_local;
    assign font_addr = addr_local;

    genvar gi;
    generate
        for (gi = 0; gi < LEN; gi = gi + 1) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(POS_X + gi*CHAR_W*SCALE),
                .ORIGIN_Y(POS_Y),
                .SCALE(SCALE)
            ) char_inst (
                .clk(clk),
                .rst(rst),
                .char_line_pixels(font_data_reg),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(char_rgb[gi])
            );
        end
    endgenerate

    // Combining characters into one RGB signal
    always_comb begin : merge_rgb_comb
        rgb_nxt = rgb_in;
        for (i = 0; i < LEN; i = i + 1) begin
            if (char_rgb[i] != rgb_in)
                rgb_nxt = char_rgb[i];
        end
    end
endmodule