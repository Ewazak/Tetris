module draw_mouse (
    input wire clk,
    input wire rst,
    input wire [11:0] xpos, 
    input wire [11:0] ypos, 
    vga_if.in in,   // VGA interface input
    vga_if.out out  // VGA interface output
);

    timeunit 1ns;
    timeprecision 1ps;

always_ff @(posedge clk) begin: bg_mouse_blk
    if (rst) begin
        out.hcount <= '0;
        out.hsync <= '0;
        out.hblnk <= '0;
        out.vcount <= '0;
        out.vsync <= '0;
        out.vblnk <= '0;
    end else begin
        // Copying signals
        out.hcount <= in.hcount;
        out.hsync <= in.hsync;
        out.hblnk <= in.hblnk;
        out.vcount <= in.vcount;
        out.vsync <= in.vsync;
        out.vblnk <= in.vblnk;
    end
end

    MouseDisplay u_mouse_display(
        .pixel_clk(clk),
        .xpos(xpos),
        .ypos(ypos),
        .hcount(in.hcount),
        .vcount(in.vcount),
        .blank(in.vblnk|in.hblnk),
        .rgb_in(in.rgb),
        .enable_mouse_display_out(),
        .rgb_out(out.rgb)
    
    
    );
    
endmodule

       