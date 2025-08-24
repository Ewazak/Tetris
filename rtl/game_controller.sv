/**
* 2025  AGH University of Science and Technology
* MTM UEC2
* Author: Ewa Żakowska, Adrianna Solińska
*
* Description: game_controller module - implements the main FSM that controls the game.
*/
module game_controller (
    input  logic clk,
    input  logic rst,
    input  logic me_ready,
    input  logic game_over_flag,
    input  logic block_placed,
    input  logic other_ready,     // flag from second board
    output logic in_game,
    output logic in_start_screen,
    output logic in_game_over,
    output logic in_score,
    output logic load_new_block  // pulse to block generator
);

    timeunit 1ns;
    timeprecision 1ps;

    typedef enum logic [2:0] {
        START_SCREEN = 3'b000,
        PLAYING      = 3'b001,
        GAME_OVER    = 3'b010,
        SCORE        = 3'b011
    } state_t;

    state_t current_state, next_state;

    // State register
    always_ff @(posedge clk or posedge rst) begin : fsm_ff_blk
        if (rst)
            current_state <= START_SCREEN;
        else
            current_state <= next_state;
    end

    // Next-state logic
    always_comb begin : fsm_comb_blk
        next_state = current_state;

        unique case (current_state)
            START_SCREEN:
                if (me_ready && other_ready)
                    next_state = PLAYING;

            PLAYING:
                if (game_over_flag)
                    next_state = GAME_OVER;

            GAME_OVER:
                if (me_ready && other_ready)
                    next_state = SCORE;
    
            SCORE:
                if (me_ready)
                    next_state = START_SCREEN;
        endcase
    end

    // Output signals
    assign in_start_screen = (current_state == START_SCREEN);
    assign in_game         = (current_state == PLAYING);
    assign in_game_over    = (current_state == GAME_OVER);
    assign in_score        = (current_state == SCORE);

    // load_new_block pulse generator (1 for state change lub block_placed)
    logic prev_playing;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            load_new_block <= 1'b0;
            prev_playing <= 1'b0;
        end else begin
            // Track previous state (to detect PLAYING entry)
            prev_playing <= (current_state == PLAYING);

            if ((current_state == PLAYING && !prev_playing) ||  // entering PLAYING
                (current_state == PLAYING && block_placed))      // block placed during game
                load_new_block <= 1'b1;
            else
                load_new_block <= 1'b0;
        end
    end

endmodule