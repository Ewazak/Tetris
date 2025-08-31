`timescale 1ns / 1ps

module block_randomizer_tb;

    // Clock and reset
    logic clk = 0;
    logic rst = 1;

    // Inputs
    logic load_new;

    // Outputs
    logic [2:0] block_type;

    // Instantiate DUT
    block_randomizer dut (
        .clk(clk),
        .rst(rst),
        .load_new(load_new),
        .block_type(block_type)
    );

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("=== Starting block_randomizer Testbench ===");

        // Apply reset
        rst = 1;
        load_new = 0;
        #20 rst = 0;

        // Generate multiple new blocks
        repeat (20) begin
            load_new = 1;
            #10 load_new = 0;
            #10;
            $display("[%0t] New block type = %0d", $time, block_type);
            #20;
        end

        $display("=== Testbench finished ===");
        $stop;
    end

endmodule