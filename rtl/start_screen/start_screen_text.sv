module start_screen_text #(
    parameter int SCALE = 4,
    parameter int ORIGIN_X = 50,
    parameter int ORIGIN_Y = 100
)(
    input  logic clk,
    input  logic rst,
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic        hblnk,
    input  logic        vblnk,
    input  logic [11:0] rgb_in,
    output logic [11:0] rgb_out
);
    
    import vga_pkg::*;

    // Tekst do wyświetlenia jako tablica ASCII
    localparam int LEN = 20;
    localparam logic [6:0] TEXT [0:LEN-1] = {
        "P","r","e","s","s"," ","E","N","T","E","R"," ","t","o"," ","s","t","a","r","t"
    };

    localparam int TEXT_PIXEL_WIDTH  = LEN * 8 * SCALE;
    localparam int TEXT_ORIGIN_X     = (HOR_PIXELS - TEXT_PIXEL_WIDTH)/2;
    localparam int TEXT_ORIGIN_Y     = VER_PIXELS/2 + 35;

    logic [11:0] draw_rgb [0:LEN-1];

    // Generacja instancji draw_rect_char dla każdego znaku
    generate
        for (genvar i = 0; i < LEN; i++) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(TEXT_ORIGIN_X + i*8*SCALE),
                .ORIGIN_Y(TEXT_ORIGIN_Y),
                .SCALE(SCALE)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(TEXT[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb[i])
            );
        end
    endgenerate

    // Scalanie RGB z wszystkich znaków
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        for (int i = 0; i < LEN; i++) begin
            if (draw_rgb[i] != rgb_in) begin
                rgb_nxt = draw_rgb[i];
                break;
            end
        end
    end

    assign rgb_out = rgb_nxt;

endmodule