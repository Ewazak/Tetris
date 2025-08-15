module block_randomizer (
    input  logic clk,
    input  logic rst,
    input  logic load_new,       // sygnał do "wylosowania" nowego klocka
    output logic [2:0] block_type // 0..6 (7 typów klocków)
);

    logic [2:0] counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 3'd1; // dowolna niezerowa wartość początkowa
        else
            counter <= {counter[1:0], counter[2] ^ counter[1]}; // XOR-shift
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            block_type <= 3'd1;
        else if (load_new) begin
            // wybierz block_type na podstawie licznika (mod 7)
            block_type <= (counter % 7) + 1;
        end
    end

endmodule