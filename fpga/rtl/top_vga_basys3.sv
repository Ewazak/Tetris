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
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */
module top_vga_basys3 (
    input  wire clk,
    input  wire btnC,
    input  wire rx,
    output wire tx,
    output wire Vsync,
    output wire Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output logic JA1,
    input logic ps2_clk,
    input logic ps2_data
);

timeunit 1ns;
timeprecision 1ps;

/**
 * Local variables and signals
 */

logic clk100MHz;
// logic clk40MHz;
logic clk65MHz;
logic locked;
logic pclk_mirror;

(* KEEP = "TRUE" *)
(* ASYNC_REG = "TRUE" *)
// For details on synthesis attributes used above, see AMD Xilinx UG 901:
// https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


/**
 * Signals assignments
 */

assign JA1 = pclk_mirror;


/**
 * FPGA submodules placement
 */


//  clk_wiz_0 u_clk_wiz_0(
//     .clk(clk),
//     .clk100MHz(clk100MHz),
//     // .clk40MHz(clk40MHz),
//     .locked(locked)
//  );

 clk_wiz65 u_clk_wiz65(
    .clk(clk),
    .clk100MHz(clk100MHz),
    .clk65MHz(clk65MHz),
    .locked(locked)
 );


// Mirror pclk on a pin for use by the testbench;
// not functionally required for this design to work.

ODDR pclk_oddr (
    .Q(pclk_mirror),
    .C(clk65MHz),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
);


/**
 *  Project functional top module
 */

top_vga u_top_vga (
    .clk(clk65MHz),
    .rst(btnC),
    .rx(rx),
    .tx(tx),
    .r(vgaRed),
    .g(vgaGreen),
    .b(vgaBlue),
    .hs(Hsync),
    .vs(Vsync),
    .game_over_flag(game_over_flag),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data)
);

endmodule
