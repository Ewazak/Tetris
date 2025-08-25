/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: bin_ascii_sync module - converts a 16-bit binary number into its ASCII decimal representation.
*/
module bin_ascii_sync (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] bin_in,       // 16-bit input number 0-65535
    output logic [6:0] ascii_0,       // ten-thousands
    output logic [6:0] ascii_1,       // thousands
    output logic [6:0] ascii_2,       // hundreds
    output logic [6:0] ascii_3,       // tens
    output logic [6:0] ascii_4        // ones
);

    logic [3:0] digit [0:4];

    always_comb begin
        digit[4] = bin_in % 10;
        digit[3] = (bin_in / 10) % 10;
        digit[2] = (bin_in / 100) % 10;
        digit[1] = (bin_in / 1000) % 10;
        digit[0] = (bin_in / 10000) % 10;
    end

    // ASCII registers
    always_ff @(posedge clk) begin
        if (rst) begin
            ascii_0 <= "0";
            ascii_1 <= "0";
            ascii_2 <= "0";
            ascii_3 <= "0";
            ascii_4 <= "0";
        end else begin
            ascii_0 <= "0" + digit[0];
            ascii_1 <= "0" + digit[1];
            ascii_2 <= "0" + digit[2];
            ascii_3 <= "0" + digit[3];
            ascii_4 <= "0" + digit[4];
        end
    end

endmodule