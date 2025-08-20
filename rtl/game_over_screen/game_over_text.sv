module game_over_text #(
    parameter int ORIGIN_X = 100,
    parameter int ORIGIN_Y = 300
)(
    input  logic clk,
    input  logic rst,
    input  logic enter_pressed,      // enter od gracza lokalnego
    input  logic [10:0] hcount,
    input  logic [10:0] vcount,
    input  logic hblnk,
    input  logic vblnk,
    input  logic [11:0] rgb_in,
    output logic [11:0] rgb_out,
    output logic ready_to_score
);

    // STANY FSM
    typedef enum logic [1:0] {
        STATE_WAIT,   // wyświetla "Wait for other player to finish"
        STATE_CLICK   // wyświetla "Click enter to see score"
    } state_t;

    state_t state, state_next;

    // Teksty
    localparam int TEXT_WAIT_LEN  = 29;
    localparam int TEXT_CLICK_LEN = 25;

    localparam logic [8*TEXT_WAIT_LEN-1:0]  TEXT_WAIT  = "Wait for other player to finish";
    localparam logic [8*TEXT_CLICK_LEN-1:0] TEXT_CLICK = "Click enter to see score";

    logic [6:0] char_code [0:31];
    logic [11:0] draw_rgb [0:31];

    // Rejestr stanu
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= STATE_WAIT;
        else
            state <= state_next;
    end

    // Przejścia stanów
    always_comb begin
        state_next = state;
        case (state)
            STATE_WAIT:  if (enter_pressed) state_next = STATE_CLICK;
            STATE_CLICK: if (enter_pressed) state_next = STATE_CLICK; // zostaje
        endcase
    end

    // Wybór tekstu w zależności od stanu
    always_comb begin
        for (int i = 0; i < 32; i++) begin
            if (state == STATE_WAIT)
                char_code[i] = (i < TEXT_WAIT_LEN)  ? TEXT_WAIT[8*i +: 7]  : 7'h20;
            else
                char_code[i] = (i < TEXT_CLICK_LEN) ? TEXT_CLICK[8*i +: 7] : 7'h20;
        end
    end

    // Rysowanie znaków
    generate
        for (genvar i = 0; i < 32; i++) begin : draw_loop
            draw_rect_char #(
                .ORIGIN_X(ORIGIN_X + i*8),
                .ORIGIN_Y(ORIGIN_Y)
            ) draw_inst (
                .clk(clk),
                .rst(rst),
                .char_code(char_code[i]),
                .hcount(hcount),
                .vcount(vcount),
                .hblnk(hblnk),
                .vblnk(vblnk),
                .rgb_in(rgb_in),
                .rgb_out(draw_rgb[i])
            );
        end
    endgenerate

    // Łączenie warstw
    logic [11:0] rgb_nxt;
    always_comb begin
        rgb_nxt = rgb_in;
        for (int i = 0; i < 32; i++) begin
            if (draw_rgb[i] != rgb_in) begin
                rgb_nxt = draw_rgb[i];
                break;
            end
        end
    end

    assign rgb_out = rgb_nxt;

    // Wyjście do score_screen
    assign ready_to_score = (state == STATE_CLICK) && enter_pressed;

endmodule
