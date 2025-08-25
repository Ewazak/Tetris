/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: draw_text module - renders text string on the screen by using multiple "draw_rect_char" module.
*/
module draw_text #(
    parameter SCALE       = 4,
    parameter LEN         = 5,
    parameter string LINE = "ERROR",   
    parameter FROM_MIDDLE = 35,
    parameter LATENCY     = 2
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,

    // Font client ports
    output logic        font_req,
    output logic [10:0] font_addr,
    input  logic [7:0]  font_data,
    input  logic        font_grant,

    output logic [11:0] rgb_out
);

    import vga_pkg::*;

    // Array of ASCII codes 
    logic [7:0] TEXT [0:LEN-1];
    integer i;
    always_comb begin
        for (i = 0; i < LEN; i = i + 1) begin
            if (i < LINE.len()) TEXT[i] = LINE[i];
            else                TEXT[i] = " "; // spacja
        end
    end

    localparam CHAR_W = 8;
    localparam CHAR_H = 16;
    localparam TEXT_PIXEL_WIDTH  = LEN * CHAR_W * SCALE;
    localparam TEXT_ORIGIN_X     = (HOR_PIXELS - TEXT_PIXEL_WIDTH)/2;
    localparam TEXT_ORIGIN_Y     = VER_PIXELS/2 + FROM_MIDDLE;

    // Register with font data
    logic [7:0] font_data_reg;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) font_data_reg <= 8'h00;
        else if (font_grant) font_data_reg <= font_data;
    end

    function automatic void future_pos(input integer add, input integer cur_h, input integer cur_v,
                                       output integer out_h, output integer out_v);
        integer nh; integer nv;
        nh = cur_h + add; nv = cur_v;
        if (nh >= HOR_PIXELS) begin
            nh = nh - HOR_PIXELS;
            nv = nv + 1;
        end
        out_h = nh; out_v = nv;
    endfunction

    // Compute request for font
    logic req_local;
    logic [10:0] addr_local;
    integer ph; integer pv; integer idx; integer line_num;
    always_comb begin
        req_local = 1'b0;
        addr_local = 11'd0;
        ph = 0; pv = 0; idx = 0; line_num = 0;
        future_pos(LATENCY, hcount, vcount, ph, pv);

        if (pv >= TEXT_ORIGIN_Y && pv < TEXT_ORIGIN_Y + CHAR_H*SCALE) begin
            if (ph >= TEXT_ORIGIN_X && ph < TEXT_ORIGIN_X + LEN*CHAR_W*SCALE) begin
                idx = (ph - TEXT_ORIGIN_X) / (CHAR_W*SCALE);
                line_num = ((pv - TEXT_ORIGIN_Y)/SCALE) % CHAR_H;
                req_local = 1'b1;
                addr_local = { TEXT[idx], line_num[3:0] };
            end
        end
    end

    assign font_req  = req_local;
    assign font_addr = addr_local;


    logic [11:0] draw_rgb [0:LEN-1];

    // Generate characters using draw_rect_char
    generate
        for (genvar gi = 0; gi < LEN; gi++) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(TEXT_ORIGIN_X + gi*CHAR_W*SCALE),
                .ORIGIN_Y(TEXT_ORIGIN_Y),
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
                .rgb_out(draw_rgb[gi])
            );
        end
    endgenerate

    // Merge character outputs into a single RGB signal
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        for (i = 0; i < LEN; i++) begin
            if (draw_rgb[i] != rgb_in) begin
                rgb_nxt = draw_rgb[i];
                break;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst)
            rgb_out <= 12'h000;
        else
            rgb_out <= rgb_nxt;
    end

endmodule