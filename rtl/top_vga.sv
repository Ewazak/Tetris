/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

 module top_vga (
    input  logic clk,
    input  logic clk100MHz,
    input  logic rst,
    input  logic rx,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    output logic tx,

    input  ps2_clk,
    input  ps2_data,
    input  logic enter_pressed,
    input  logic game_over_flag
);

    timeunit 1ns;
    timeprecision 1ps;

    // VGA sygnały pośrednie
    vga_if vga_start_screen_rom();
    vga_if vga_game();
    vga_if vga_final();

    // Pozycje i przyciski myszy
    logic [11:0] xpos, ypos;
    logic left, right, middle;

    // Parametry klocka
    logic [3:0][3:0] current_block_map;
    logic [2:0] current_block_type;
    logic [1:0] rotation;
    logic [1:0] x_in, y_in;
    logic occupied_pixel;

    // Pozycja klocka w pikselach
    logic [10:0] block_pos_x = 100;  // np. środek planszy
    logic [10:0] block_pos_y = 50;

    // FSM sygnały stanu
    logic in_game, in_start_screen, in_game_over;

    // VGA sygnały
    wire [10:0] hcount_tim, vcount_tim;
    wire hsync_tim, vsync_tim, hblnk_tim, vblnk_tim;

    // Plansza 10x20: tablica z typami klocków
    logic [2:0] board [0:9][0:19];

    // Blok koloru z planszy
    logic [11:0] board_rgb;
    logic [11:0] block_rgb;

    // Wybrany kolor końcowy
    logic [11:0] final_rgb;

    logic [7:0] uart_data_send, uart_data_recieved;

    // ---------------------------------------
    // VGA timing
    // ---------------------------------------
    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .hcount(hcount_tim),
        .hsync(hsync_tim),
        .hblnk(hblnk_tim),
        .vcount(vcount_tim),
        .vsync(vsync_tim),
        .vblnk(vblnk_tim)
    );

    // ---------------------------------------
    // Start screen
    // ---------------------------------------
    draw_start_screen #(
    .SCALE(8)
    )u_draw_start_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .out(vga_start_screen_rom)
    );
    // ---------------------------------------
    // FSM kontroler gry
    // ---------------------------------------
    
    // Wykrywanie impulsu ENTER (zbocze narastające)
    logic kb_left, kb_right, kb_down, kb_rotate, kb_start;
    logic kb_start_prev, kb_start_edge;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            kb_start_prev <= 0;
            kb_start_edge <= 0;
        end else begin
            kb_start_edge <= kb_start & ~kb_start_prev;  // tylko zbocze narastające
            kb_start_prev <= kb_start;
        end
    end

    logic block_placed;
    logic load_new_block;
    
    game_controller u_game_controller (
        .clk(clk),
        .rst(rst),
        .enter_pressed(kb_start_edge),
        .game_over_flag(game_over_flag),
        .block_placed(block_placed),
        .in_game(in_game),
        .in_start_screen(in_start_screen),
        .in_game_over(in_game_over),
        .load_new_block(load_new_block)
    );

    // ---------------------------------------
    // Obsługa klawiatury
    // ---------------------------------------
    
        // Sygnały wejściowe z ps2_keyboard
        logic        ps2_code_new;
        logic [7:0]  ps2_code;
        
        ps2_keyboard #(
        .clk_freq(65_000_000),
        .debounce_counter_size(8)
    ) ps2_keyboard_inst (
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .ps2_code_new(ps2_code_new),
        .ps2_code(ps2_code)
    );

        // Flaga break code
        logic is_break;
        
        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                kb_left   <= 0;
                kb_right  <= 0;
                kb_down   <= 0;
                kb_rotate <= 0;
                kb_start  <= 0;
                is_break  <= 0;
            end else if (ps2_code_new) begin
                if (ps2_code == 8'hF0) begin
                    is_break <= 1;  // następny kod to break
                end else begin
                    case (ps2_code)
                        8'h1C: kb_left   <= ~is_break;  // A
                        8'h23: kb_right  <= ~is_break;  // D
                        8'h1B: kb_down   <= ~is_break;  // S
                        8'h1D: kb_rotate <= ~is_break;  // W
                        8'h5A: kb_start  <= ~is_break;  // ENTER
                        default: ; // brak działania
                    endcase
                    is_break <= 0; // reset break
                end
            end
        end

    // ---------------------------------------
    // Game screen
    // ---------------------------------------
    draw_game_screen #(
        .SCALE(16)
    ) u_draw_game_screen (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .out(vga_game)
    );

    // ---------------------------------------
    // Generator i mapa klocka
    // ---------------------------------------
    block_randomizer u_block_randomizer (
        .clk(clk),
        .rst(rst),
        .load_new(load_new_block),
        .block_type(current_block_type)
    );

    block_generator u_block_generator (
        .block_type(current_block_type),
        .rotation(rotation),
        .block_map(current_block_map)
    );

    assign occupied_pixel = current_block_map[y_in][x_in];

    // ---------------------------------------
    // Rysowanie aktualnego klocka
    // ---------------------------------------
    block_draw u_block_draw (
        .hcount(hcount_tim),
        .vcount(vcount_tim),
        .block_pos_x(block_pos_x),
        .block_pos_y(block_pos_y),
        .block_map(current_block_map),
        .block_type(current_block_type),
        .rgb_out(block_rgb)
    );

    // ---------------------------------------
    // Renderowanie planszy (w tle)
    // ---------------------------------------
    board_renderer u_board_renderer (
        .clk(clk),
        .hcount(hcount_tim),
        .vcount(vcount_tim),
        .board(board),
        .rgb_out(board_rgb)
    );

    game_logic u_game_logic (
        .clk(clk),
        .rst(rst),
        .load_new_block(load_new_block),
        .block_type(current_block_type),
        .block_map(current_block_map),
        .block_placed(block_placed),
        .board(board)
    );

    top_uart u_top_uart (
        .clk(clk65),
        .rst(rst),
        .rx,
        .uart_data_send(uart_data_send),
        .uart_data_recieved(uart_data_recieved),
        .tx
     );

    // ---------------------------------------
    // MUX: co pokazywać
    // ---------------------------------------
    always_comb begin
        if (in_start_screen) begin
            final_rgb = vga_start_screen_rom.rgb;
        end else if (in_game) begin
            // Kolejność: klocek > plansza > tło z ROM-u
            if (block_rgb != 12'h000)
                final_rgb = block_rgb;
            else if (board_rgb != 12'h000)
                final_rgb = board_rgb;
            else
                final_rgb = vga_game.rgb;  // tło z ROM-u
        end else begin
            final_rgb = 12'h000; // fallback na czarne
        end
    end

    // ---------------------------------------
    // Przypisanie sygnałów końcowych
    // ---------------------------------------
    assign vs = vsync_tim;
    assign hs = hsync_tim;
    assign {r, g, b} = final_rgb;

endmodule