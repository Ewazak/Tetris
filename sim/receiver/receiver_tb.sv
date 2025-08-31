`timescale 1ns / 1ps

module receiver_tb;

    // Clock
    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // PS/2 signals
    logic ps2_clk = 1;
    logic ps2_data = 1;

    // Outputs
    logic [15:0] keycode;
    logic oflag;

    // Instantiate receiver
    receiver uut (
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .keycode(keycode),
        .oflag(oflag)
    );

    // Task: send one byte over PS/2
    task send_ps2_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            ps2_data = 0;
            @(negedge ps2_clk);
            // Data bits LSB first
            for (i=0; i<8; i=i+1) begin
                ps2_data = data[i];
                @(negedge ps2_clk);
            end
            // Stop bit
            ps2_data = 1;
            @(negedge ps2_clk);
        end
    endtask

    initial begin
        $display("=== Receiver TB Start ===");
        #20;

        // Generujemy ps2_clk zegar symulowany
        fork
            forever #40 ps2_clk = ~ps2_clk;
        join_none

        // Wyślij bajt 8'h1C (klawisz 'A')
        send_ps2_byte(8'h1C);
        #200;

        $display("Keycode: %h, oflag: %b", keycode, oflag);

        $display("=== Simulation End ===");
        $stop;
    end

endmodule