//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   points_counter
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:  implementation of scoring logic for the game,
               calculate points based on the number of cleared lines 
               and whether a block was placed.
 */
//////////////////////////////////////////////////////////////////////////////
module points_counter (
    input  logic clk,
    input  logic reset,
    input  logic [2:0] lines_cleared,
    input  logic add_block,
    output logic [15:0] score
);

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    logic [15:0] points_to_add;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : score_reg_blk
        if (reset) begin : score_reg_rst_blk
            score <= 16'd0;
        end
        else if (points_to_add != 0) begin : score_reg_run_blk
            score <= score + points_to_add;
        end
    end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
    always_comb begin : points_calc_comb
        points_to_add = 0;
        case (lines_cleared)
            3'd1: points_to_add = 5;
            3'd2: points_to_add = 10;
            3'd3: points_to_add = 15;
            3'd4: points_to_add = 20;
        endcase

        if (add_block) begin
            points_to_add = points_to_add + 2;
        end
    end
endmodule