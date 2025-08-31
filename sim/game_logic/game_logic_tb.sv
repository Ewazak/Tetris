`timescale 1ns / 1ps

module game_logic_tb;

    // Clock and reset
    logic clk = 0;
    logic rst = 1;

    // Inputs
    logic load_new_block;
    logic move_left;
    logic move_right;
    logic move_down;
    logic [2:0] block_type;
    logic [3:0][3:0] block_map;

    // Outputs
    logic block_placed;
    logic [3:0] active_x;
    logic [4:0] active_y;
    logic [10:0] block_pos_x;
    logic [10:0] block_pos_y;
    logic [2:0] board [0:199];
    logic [2:0] lines_removed;
    logic game_over_flag;

    // Instantiate DUT
    game_logic dut (
        .clk(clk),
        .rst(rst),
        .load_new_block(load_new_block),
        .move_left(move_left),
        .move_right(move_right),
        .move_down(move_down),
        .block_type(block_type),
        .block_map(block_map),
        .block_placed(block_placed),
        .active_x(active_x),
        .active_y(active_y),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .board(board),
        .lines_removed(lines_removed),
        .game_over_flag(game_over_flag)
    );

    // Clock generation (100 MHz equivalent)
    always #5 clk = ~clk;

    // Task to print current state
    task print_state(string label);
        $display("[%0t] %s | pos=(%0d,%0d) | block=%0d | placed=%0b | lines=%0d | game_over=%0b",
                 $time, label, active_x, active_y, block_type, block_placed, lines_removed, game_over_flag);
    endtask

    initial begin
        $display("=== Starting game_logic Testbench ===");

        // Initialize inputs
        load_new_block = 0;
        move_left = 0;
        move_right = 0;
        move_down = 0;
        block_type = 3'd1;
        block_map = '{ '{1,0,0,0}, '{1,0,0,0}, '{1,0,0,0}, '{1,0,0,0} }; // "I" shaped block

        // Reset
        #20 rst = 0;
        #20 load_new_block = 1; #10 load_new_block = 0;
        print_state("New block loaded");

        // Wait some cycles -> block falls automatically
        repeat (200) @(posedge clk);
        print_state("After falling");

        // Move block left
        move_left = 1; #10 move_left = 0;
        repeat (20) @(posedge clk);
        print_state("Moved left");

        // Move block right
        move_right = 1; #10 move_right = 0;
        repeat (20) @(posedge clk);
        print_state("Moved right");

        // Drop block down
        move_down = 1; repeat (30) @(posedge clk); move_down = 0;
        print_state("Manually dropped");

        // Load new block
        load_new_block = 1; #10 load_new_block = 0;
        block_type = 3'd2;
        block_map = '{ '{0,1,0,0}, '{0,1,0,0}, '{0,1,0,0}, '{0,1,0,0} }; // "I" rotated
        repeat (100) @(posedge clk);
        print_state("Second block placed");

        $display("=== Testbench finished ===");
        $stop;
    end

endmodule