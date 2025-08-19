module score_counter(
    input  logic clk,
    input  logic reset,
    input  logic [2:0] lines_cleared,
    input  logic add_block,
    output logic [15:0] score
);

    logic [15:0] points_to_add;

// Obliczanie punktów do dodania
    always_comb begin
        points_to_add = 0;
        case (lines_cleared)
            3'd1: points_to_add = 10;
            3'd2: points_to_add = 20;
            3'd3: points_to_add = 30;
            3'd4: points_to_add = 40;
        endcase

        if (add_block)
            points_to_add = points_to_add + 4;
    end

// Aktualizacja wyniku
    always_ff @(posedge clk) begin
        if (reset) begin
            score <= 16'd0;
        end
        else if (points_to_add != 0) begin
            score <= score + points_to_add;
        end
    end

endmodule