module draw_bg (
    input  logic clk,
    input  logic rst,

    input  logic [10:0] vcount_in,
    input  logic        vsync_in,
    input  logic        vblnk_in,
    input  logic [10:0] hcount_in,
    input  logic        hsync_in,
    input  logic        hblnk_in,

    output logic [10:0] vcount_out,
    output logic        vsync_out,
    output logic        vblnk_out,
    output logic [10:0] hcount_out,
    output logic        hsync_out,
    output logic        hblnk_out,

    output logic [11:0] rgb_out
);

    import vga_pkg::*;

    logic [11:0] rgb_nxt;

    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_out <= 0;
            vsync_out  <= 0;
            vblnk_out  <= 0;
            hcount_out <= 0;
            hsync_out  <= 0;
            hblnk_out  <= 0;
            rgb_out    <= 0;
        end else begin
            vcount_out <= vcount_in;
            vsync_out  <= vsync_in;
            vblnk_out  <= vblnk_in;
            hcount_out <= hcount_in;
            hsync_out  <= hsync_in;
            hblnk_out  <= hblnk_in;
            rgb_out    <= rgb_nxt;
        end
    end

    always_comb begin
        if (vblnk_in || hblnk_in) begin
            rgb_nxt = 12'h000;
        end else begin
            // Ramka
            if (vcount_in == 0)
                rgb_nxt = 12'hff0; // żółta góra
            else if (vcount_in == VER_PIXELS - 1)
                rgb_nxt = 12'hf00; // czerwona dół
            else if (hcount_in == 0)
                rgb_nxt = 12'h0f0; // zielona lewa
            else if (hcount_in == HOR_PIXELS - 1)
                rgb_nxt = 12'h00f; // niebieska prawa

            // Napis: PRESS START – uproszczony biały blok (środek ekranu)
            else if ((vcount_in >= 350 && vcount_in <= 370) && (hcount_in >= 412 && hcount_in <= 612))
                rgb_nxt = 12'hfff;
            else if ((vcount_in >= 370 && vcount_in <= 390) && ((hcount_in >= 412 && hcount_in <= 432) || (hcount_in >= 592 && hcount_in <= 612)))
                rgb_nxt = 12'hfff;
            else
                rgb_nxt = 12'h444; // ciemnoszare tło
        end
    end

endmodule





