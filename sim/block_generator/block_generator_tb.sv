`timescale 1ns/1ps

module block_generator_tb;

    // Inputs
    logic [2:0] block_type;
    logic [1:0] rotation;

    // Outputs
    logic [3:0][3:0] block_map;

    // Clock
    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Instantiate the DUT
    block_generator dut (
        .block_type(block_type),
        .rotation(rotation),
        .block_map(block_map)
    );

    // Task to display a 4x4 block
    task display_block(input [3:0][3:0] blk);
        integer i, j;
        begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    $write("%0d ", blk[i][j]);
                end
                $write("\n");
            end
            $write("\n");
        end
    endtask

    initial begin
        $display("=== Starting block_generator Testbench ===");
        for (int t = 1; t <= 7; t = t + 1) begin
            block_type = t;
            for (int r = 0; r < 4; r = r + 1) begin
                rotation = r;
                @(posedge clk); // daj czas na przeliczenie
                $display("Block type = %0d, rotation = %0d", block_type, rotation);
                display_block(block_map);
            end
        end

        $display("=== Testbench finished ===");
        $stop;
    end

endmodule


