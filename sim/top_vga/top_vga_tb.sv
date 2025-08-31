/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for top_vga.
 * Thanks to the tiff_writer module, an expected image
 * produced by the project is exported to a tif file.
 * Since the vs signal is connected to the go input of
 * the tiff_writer, the first (top-left) pixel of the tif
 * will not correspond to the vga project (0,0) pixel.
 * The active image (not blanked space) in the tif file
 * will be shifted down by the number of lines equal to
 * the difference between VER_SYNC_START and VER_TOTAL_TIME.
 */

 `timescale 1ns / 1ps

 module top_vga_tb;
 
     // Clock and reset
     logic clk = 0;
     logic rst = 1;
 
     // Inputs
     logic rx = 0;
     logic ps2_clk = 0;
     logic ps2_data = 0;
 
     // Outputs
     logic tx;
     logic vs;
     logic hs;
     logic [3:0] r;
     logic [3:0] g;
     logic [3:0] b;
     logic game_over_flag;
 
     // Instantiate DUT
     top_vga dut (
         .clk(clk),
         .rst(rst),
         .rx(rx),
         .tx(tx),
         .vs(vs),
         .hs(hs),
         .r(r),
         .g(g),
         .b(b),
         .ps2_clk(ps2_clk),
         .ps2_data(ps2_data),
         .game_over_flag(game_over_flag)
     );
 
     // Clock generation (50 MHz)
     always #10 clk = ~clk;
 
     // PS/2 clock simulation
     always #50 ps2_clk = ~ps2_clk;
 
     initial begin
         $display("=== Starting top_vga Testbench ===");
 
         // Apply reset
         rst = 1;
         #100;
         rst = 0;
 
         // Simulate a few cycles of RX and PS/2 input
         #200;
         rx = 1;
         #40 rx = 0;
         #60 rx = 1;
 
         // Observe VGA signals for some time
         repeat (1000) @(posedge clk);
 
         $display("VGA HS=%b VS=%b RGB=%h%h%h GameOver=%b", hs, vs, r, g, b, game_over_flag);
 
         $display("=== Testbench finished ===");
         $stop;
     end
 
 endmodule