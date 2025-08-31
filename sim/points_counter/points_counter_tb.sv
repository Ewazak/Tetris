`timescale 1ns / 1ps

module points_counter_tb;

    // Clock and reset
    logic clk = 0;
    logic reset = 1;

    // Inputs
    logic [2:0] lines_cleared;
    logic add_block;

    // Output
    logic [15:0] score;

    // Instantiate DUT
    points_counter dut (
        .clk(clk),
        .reset(reset),
        .lines_cleared(lines_cleared),
        .add_block(add_block),
        .score(score)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("=== Starting points_counter Testbench ===");

        // Reset
        reset = 1;
        lines_cleared = 0;
        add_block = 0;
        #20 reset = 0;

        // Test different line clears
        lines_cleared = 1; add_block = 1; #10; add_block = 0; #10;
        $display("[%0t] lines=1, add_block=1, score=%0d", $time, score);

        lines_cleared = 2; add_block = 0; #10; #10;
        $display("[%0t] lines=2, add_block=0, score=%0d", $time, score);

        lines_cleared = 3; add_block = 1; #10; add_block=0; #10;
        $display("[%0t] lines=3, add_block=1, score=%0d", $time, score);

        lines_cleared = 4; add_block = 0; #10; #10;
        $display("[%0t] lines=4, add_block=0, score=%0d", $time, score);

        lines_cleared = 0; add_block = 1; #10; add_block=0; #10;
        $display("[%0t] lines=0, add_block=1, score=%0d", $time, score);

        $display("=== Testbench finished ===");
        $stop;
    end

endmodule