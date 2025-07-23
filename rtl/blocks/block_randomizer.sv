module block_randomizer (
    input  logic clk,
    input  logic rst,
    input  logic load_new,       // sygnał do "wylosowania" nowego klocka
    output logic [2:0] block_type // 0..6 (7 typów klocków)
);

    logic [2:0] counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 3'd0;
        else
            counter <= counter + 3'd1; // prosty licznik modulo 8
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            block_type <= 3'd0;
        else if (load_new) begin
            // wybierz block_type na podstawie licznika (mod 7)
            block_type <= (counter % 7);
        end
    end

endmodule