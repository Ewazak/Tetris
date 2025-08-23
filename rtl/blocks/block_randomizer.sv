/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: block_randomizer module - generates pseudo-random block types using an XOR-shift counter, 
*              updated on load_new signal.
*/
module block_randomizer (
    input  logic clk,
    input  logic rst,
    input  logic load_new,        // signal to randomize a new block
    output logic [2:0] block_type // 0..6 (7 block types)
);



    logic [2:0] counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 3'd1; // arbitraty non-zero initial value
        else
            counter <= {counter[1:0], counter[2] ^ counter[1]}; // XOR-shift
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            block_type <= 3'd1;
        else if (load_new) begin
            // choose block_type based on counter value (mod 7)
            block_type <= (counter % 7) + 1;
        end
    end

endmodule