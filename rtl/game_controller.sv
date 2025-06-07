module game_controller (
    input  logic clk,
    input  logic rst,
    input  logic enter_pressed,
    input  logic game_over_flag,
    output logic in_game,
    output logic in_start_screen,
    output logic in_game_over
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Type declarations
     */
    typedef enum logic [1:0] {
        START_SCREEN = 2'b00,
        PLAYING      = 2'b01,
        GAME_OVER    = 2'b10
    } state_t;

    state_t current_state, next_state;

    /**
     * State register
     */
    always_ff @(posedge clk or posedge rst) begin : fsm_ff_blk
        if (rst)
            current_state <= START_SCREEN;
        else
            current_state <= next_state;
    end

    /**
     * Next-state logic
     */
    always_comb begin : fsm_comb_blk
        next_state = current_state;

        case (current_state)
            START_SCREEN:
                if (enter_pressed)
                    next_state = PLAYING;

            PLAYING:
                if (game_over_flag)
                    next_state = GAME_OVER;

            GAME_OVER:
                if (enter_pressed)
                    next_state = START_SCREEN;
        endcase
    end

    /**
     * Output logic
     */
    assign in_start_screen = (current_state == START_SCREEN);
    assign in_game         = (current_state == PLAYING);
    assign in_game_over    = (current_state == GAME_OVER);

endmodule



