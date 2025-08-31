//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   game_controller
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:   Implements the main FSM that controls the game.
 */
//////////////////////////////////////////////////////////////////////////////
 module game_controller (
    input  wire clk,
    input  wire rst,
    input  wire kb_reset_edge,
    input  wire me_ready,
    input  wire game_over_flag,
    input  wire block_placed,
    input  wire other_ready,
    output logic in_game,
    output logic in_start_screen,
    output logic in_game_over,
    output logic in_score,
    output logic load_new_block
);

    timeunit 1ns;
    timeprecision 1ps;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam STATE_BITS = 2; // number of bits used for state register

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic in_game_nxt, in_start_screen_nxt, in_game_over_nxt, in_score_nxt;
logic load_new_block_nxt;
(* keep = "true" *) logic prev_playing;

enum logic [STATE_BITS-1 :0] {
    START_SCREEN = 2'b00,
    PLAYING      = 2'b01,
    GAME_OVER    = 2'b10,
    SCORE        = 2'b11
} state, state_nxt;

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : state_seq_blk
    if (rst) begin : state_seq_rst_blk
        state <= START_SCREEN;
    end else begin : state_seq_run_blk
        state <= state_nxt;
    end
end

//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin : state_comb_blk
    state_nxt = state;
    unique case (state)
        START_SCREEN:
            if (me_ready && other_ready)
                state_nxt = PLAYING;

        PLAYING:
            if (game_over_flag)
                state_nxt = GAME_OVER;

        GAME_OVER:
            if (me_ready && other_ready)
                state_nxt = SCORE;

        SCORE:
            if (kb_reset_edge)
                state_nxt = START_SCREEN;
    endcase
end

//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if(rst) begin : out_reg_rst_blk
        in_game         <= 1'b0;
        in_start_screen <= 1'b0;
        in_game_over    <= 1'b0;
        in_score        <= 1'b0;
        load_new_block  <= 1'b0;
        prev_playing    <= 1'b0;
    end else begin : out_reg_run_blk
        in_game         <= in_game_nxt;
        in_start_screen <= in_start_screen_nxt;
        in_game_over    <= in_game_over_nxt;
        in_score        <= in_score_nxt;
        load_new_block  <= load_new_block_nxt;
        prev_playing    <= (state == PLAYING);
    end
end

//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : out_comb_blk
    in_start_screen_nxt = (state_nxt == START_SCREEN);
    in_game_nxt         = (state_nxt == PLAYING);
    in_game_over_nxt    = (state_nxt == GAME_OVER);
    in_score_nxt        = (state_nxt == SCORE);

    // load_new_block pulse generator logic
    load_new_block_nxt = 1'b0;
    if ((state == START_SCREEN) && (state_nxt == PLAYING)) begin // entering PLAYING
        load_new_block_nxt = 1'b1;
    end else if ((state == PLAYING) && block_placed) begin // block placed during game
        load_new_block_nxt = 1'b1;
    end
end

endmodule