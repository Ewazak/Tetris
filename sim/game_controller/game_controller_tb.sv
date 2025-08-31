`timescale 1ns / 1ps

module game_controller_tb;

    // Clock and reset
    logic clk = 0;
    logic rst = 1;

    // Inputs
    logic kb_reset_edge;
    logic me_ready;
    logic game_over_flag;
    logic block_placed;
    logic other_ready;

    // Outputs
    logic in_game;
    logic in_start_screen;
    logic in_game_over;
    logic in_score;
    logic load_new_block;

    // Instantiate DUT
    game_controller dut (
        .clk(clk),
        .rst(rst),
        .kb_reset_edge(kb_reset_edge),
        .me_ready(me_ready),
        .game_over_flag(game_over_flag),
        .block_placed(block_placed),
        .other_ready(other_ready),
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over),
        .in_score(in_score),
        .load_new_block(load_new_block)
    );

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("=== Starting game_controller Testbench ===");

        // Initialize inputs
        kb_reset_edge = 0;
        me_ready = 0;
        game_over_flag = 0;
        block_placed = 0;
        other_ready = 0;

        // Apply reset
        #20 rst = 0;

        // Start screen -> PLAYING
        me_ready = 1; other_ready = 1;
        #10;
        $display("After entering PLAYING: in_game=%b, load_new_block=%b", in_game, load_new_block);

        // Simulate block placed
        block_placed = 1; #10 block_placed = 0;
        $display("After block placed: load_new_block=%b", load_new_block);

        // Trigger GAME_OVER
        game_over_flag = 1; #10 game_over_flag = 0;
        $display("After GAME_OVER: in_game_over=%b", in_game_over);

        // Go to SCORE screen
        me_ready = 1; other_ready = 1; #10;
        $display("After entering SCORE: in_score=%b", in_score);

        // Reset back to START_SCREEN
        kb_reset_edge = 1; #10 kb_reset_edge = 0;
        $display("After reset: in_start_screen=%b", in_start_screen);

        $display("=== Testbench finished ===");
        $stop;
    end

endmodule