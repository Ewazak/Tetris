module score_counter(
    input logic clk,
    input logic reset,
    input logic [2:0] lines_cleared,  // zmienione na 3 bity
    output logic [15:0] score
);

    logic [15:0] points_to_add;

    always_comb begin
        case (lines_cleared)
            3'd0: points_to_add = 0;
            3'd1: points_to_add = 100;
            3'd2: points_to_add = 200;
            3'd3: points_to_add = 300;
            3'd4: points_to_add = 400;
            default: points_to_add = 0;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            score <= 0;
            $display("Reset! Score = 0");
        end else if (lines_cleared != 0) begin
            score <= score + points_to_add;
            $display("Cleared %0d line(s)! Added %0d points. New score = %0d", lines_cleared, points_to_add, score + points_to_add);
        end
    end

endmodule