module char_ram (
    input  logic        clk,
    input  logic        load_text,         
    input  logic [69:0] text_in,           // 10 znaków ASCII po 7 bitów
    input  logic  [3:0] char_index,        // indeks znaku: 0–9
    output logic  [6:0] char_code          // wyjście: 7-bitowy kod ASCII
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
            char_code <= 7'h20; // spacja
    end
endmodule