module score (
    input  logic [6:0] my_score,
    input  logic [6:0] enemy_score,
    output logic [1:0] game_result  
);

    always_comb begin
        game_result = (my_score > enemy_score) ? 2'b01 : (my_score < enemy_score) ? 2'b10 : 2'b00;
    end

endmodule