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

    logic [3:0] d0, d1, d2, d3, d4;
    logic [15:0] tmp0, tmp1, tmp2, tmp3;

    always_ff @(posedge clk) begin
        if (rst) begin
            d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0; d4 <= 0;
        end else begin
            tmp0 <= bin_in;
            d0 <= tmp0 / 10000;
            tmp1 <= tmp0 % 10000;

            d1 <= tmp1 / 1000;
            tmp2 <= tmp1 % 1000;

            d2 <= tmp2 / 100;
            tmp3 <= tmp2 % 100;

            d3 <= tmp3 / 10;
            d4 <= tmp3 % 10;
        end
    end

// ASCII registers
    always_ff @(posedge clk) begin
        if (rst) begin
            ascii_0 <= 7'h30;
            ascii_1 <= 7'h30;
            ascii_2 <= 7'h30;
            ascii_3 <= 7'h30;
            ascii_4 <= 7'h30;
        end else begin
            ascii_0 <= 7'h30 + d0;
            ascii_1 <= 7'h30 + d1;
            ascii_2 <= 7'h30 + d2;
            ascii_3 <= 7'h30 + d3;
            ascii_4 <= 7'h30 + d4;
        end
    end

endmodule