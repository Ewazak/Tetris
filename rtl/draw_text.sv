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
    parameter FROM_MIDDLE = 35
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

    // Font bufor
    logic [7:0] font_data_buf [0:LEN-1][0:CHAR_H-1];
    logic [$clog2(LEN)-1:0] idx;
    logic [3:0] line_num;
    logic loading;

    typedef enum logic [1:0] {IDLE, LOAD} state_t;
    state_t state;
    integer char_i;
    integer line_i;

    always_ff @(posedge clk) begin
        if (rst) begin state <= LOAD;
            char_i <= 0;
            line_i <= 0;
        end else begin
            case (state)
                LOAD: begin
                    if (font_grant) begin
                        font_data_buf[char_i][line_i] <= font_data;
                        if (line_i == CHAR_H-1) begin
                            line_i <= 0;
                            if (char_i == LEN-1) begin
                                char_i <= 0;
                                state <= IDLE;
                            end else begin
                                char_i <= char_i + 1;
                            end
                        end else begin
                            line_i <= line_i + 1;
                        end
                    end
                end
                default: ; // IDLE
            endcase
        end
    end

    assign font_req = (state == LOAD);
    assign font_addr = { TEXT[char_i], line_i[3:0] };

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
                .char_line_pixels(font_data_buf[gi][(vcount - TEXT_ORIGIN_Y)/SCALE % CHAR_H]),
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