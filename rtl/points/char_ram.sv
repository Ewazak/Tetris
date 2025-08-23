/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: char_ram module - synchronous RAM used to store up to 10 ASCII characters
*/
module char_ram (
    input  logic        clk,
    input  logic        load_text,         
    input  logic [69:0] text_in,           // 10 ASCII characters, 7 bits each
    input  logic  [3:0] char_index,        // index of character: 0–9
    output logic  [6:0] char_code          // 7-bit ASCII code output
);

    logic [6:0] ram [0:9];

    always_ff @(posedge clk) begin
        if (load_text) begin
            for (int i=0; i<10; i++)
                ram[i] <= text_in[69 - i*7 -: 7];
        end
    end

    always_ff @(posedge clk) begin
        if (char_index < 10)
            char_code <= ram[char_index];
        else
            char_code <= 7'h20; // space
    end
endmodule