`timescale 1 ns / 1 ps

module draw_rect_ctl_tb;

/**
 * Local variables and signals
 */

logic clk, rst;
logic mouse_left;
logic [11:0]xpos, ypos;
logic [11:0]mouse_xpos, mouse_ypos;

/**
 * Submodules instances
 */

draw_rect_ctl u_draw_rect_ctl(
    .clk(clk),
    .rst(rst),
    .xpos(xpos),
    .ypos(ypos),
    .mouse_left(mouse_left),
    .mouse_xpos(mouse_xpos),
    .mouse_ypos(mouse_ypos)

);


/**
 * Main test
 */

initial begin
    $dumpfile ("draw_rect_ctl.vcd");
    $dumpvars (0, draw_rect_ctl_tb);
    $fmonitor("bouncing_gravity.csv", "%t, %d", $time, ypos);  
// End the simulation.
    $display("Simulation is over, check the waveforms.");
    $finish;
end

endmodule