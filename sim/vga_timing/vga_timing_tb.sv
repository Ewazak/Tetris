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

    localparam CLK_PERIOD = 25;     // 40 MHz


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
    assert property (@(posedge clk) disable iff (rst)  ((hcount >= 0) && (hcount < HOR_TOTAL_TIME)))
    else $error("Error: hcount is not in the range [0, %d]: %d", HOR_TOTAL_TIME-1, hcount);

    assert property (@(posedge clk) disable iff (rst) ((vcount >= 0) && (vcount < VER_TOTAL_TIME)))
    else $error("Error: vcount is not in the range [0, %d]: %d", VER_TOTAL_TIME-1, vcount);

    //Hblnk start and stop
    assert property (@(posedge hblnk)  (hcount == HOR_BLANK_START - 1))
    else $error("Error: hblnk should start when hcount = %d, hcount = %d", HOR_BLANK_START, hcount);

    assert property (@(negedge hblnk) (hcount == HOR_BLANK_END - 1))
    else $error("Error: hblnk should stop when hcount = %d, hcount = %d", HOR_BLANK_END, hcount);

    //Hsync start and stop
    assert property (@(posedge hsync) (hcount == HOR_SYNC_START - 1))
    else $error("Error: hsync should start when hcount = %d, hcount = %d", HOR_SYNC_START, hcount);

    assert property (@(negedge hsync) (hcount == HOR_SYNC_END - 1))
    else $error("Error: hsync should stop when hcount = %d, hcount = %d", HOR_SYNC_END, hcount);

    //Vblnk start and stop
    assert property (@(posedge vblnk)  (vcount == VER_BLANK_START))
    else $error("Error: vblnk should start when vcount = %d, vcount = %d", VER_BLANK_START, vcount);

    assert property (@(negedge vblnk) (vcount == VER_BLANK_END - 1))
    else $error("Error: vblnk should stop when vcount = %d, vcount = %d", VER_BLANK_END, vcount);

    //Vsync start and stop
    assert property (@(posedge vsync) (vcount == VER_SYNC_START - 1))
    else $error("Error: vsync should start when vcount = %d, vcount = %d", VER_SYNC_START, vcount);

    assert property (@(negedge vsync)  (vcount == VER_SYNC_END - 1))
    else $error("Error: vsync should stop when vcount = %d, vcount = %d", VER_SYNC_END, vcount);

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
