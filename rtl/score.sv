/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: score module - compares two 16-bit scores and produces 2-bit result indicating outcome of the game.
*/
module score (
    input  logic [15:0] my_score,
    input  logic [15:0] enemy_score,
    output logic [1:0] game_result  
);

    always_comb begin
        game_result = (my_score > enemy_score) ? 2'b01 : (my_score < enemy_score) ? 2'b10 : 2'b00;
    end

endmodule