/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.385;     // 65 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk,
        .rst,
        .vcount,
        .vsync,
        .vblnk,
        .hcount,
        .hsync,
        .hblnk
    );

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).


    /**
     * Assertions
     */
    //Hcount and vcount range
     assert property (@(posedge clk) disable iff (rst) ##1 ((hcount>=0)&&(hcount<1344)))
     else $error("Error: hcount is not in the range [0,1055]: %d", hcount);
 
     assert property (@(posedge clk) disable iff (rst) ##1 ((vcount>=0)&&(vcount<806)))
     else $error("Error: vcount is not in the range [0,628]: %d", vcount);

     //Hblnk and vblnk range
     assert property (@(posedge hblnk) ##1 (hcount == HOR_BLANK_START-1))
     else $error("Error: hblnk dont start when hcount = 799: %d", hcount);
 
     assert property (@(negedge hblnk) ##1 (hcount == HOR_BLANK_END -1))
     else $error("Error: hblnk dont stop when hcount = 1055: %d", hcount);
 
     assert property (@(posedge vblnk) ##1 (vcount == VER_BLANK_START -1))
     else $error("Error: vblnk dont start when vcount = 599: %d", vcount);
 
     assert property (@(negedge vblnk) ##1 (vcount == VER_BLANK_END - 1))
     else $error("Error: vblnk dont stop when vcount = 627: %d", vcount);

     //Hsync and vsync range
     assert property (@(posedge hsync) ##1 (hcount == HOR_SYNC_START-1))
     else $error("Error: hsync dont start when hcount = 839: %d", hcount);
 
     assert property (@(negedge hsync) ##1 (hcount == HOR_SYNC_END -1))
     else $error("Error: hsync dont stop when hcount = 967: %d", hcount);
 
     assert property (@(posedge vsync) ##1 (vcount == VER_SYNC_START-1))
     else $error("Error: vsync dont start when vcount = 600: %d", vcount);
 
     assert property (@(negedge vsync) ##1 (vcount == VER_SYNC_END -1))
     else $error("Error: vsync dont stop when vcount = 604: %d", vcount);
    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule
