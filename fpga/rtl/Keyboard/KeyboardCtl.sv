module KeyboardCtl (
    input  logic [15:0] keycode,
    output logic kb_rotate,
    output logic kb_down,
    output logic kb_left,
    output logic kb_right,
    output logic kb_start
);

timeunit 1ns;
timeprecision 1ps;

// Kody klawiszy
localparam KEY_ROTATE = 8'h1D; // W
localparam KEY_LEFT   = 8'h1C; // A
localparam KEY_DOWN   = 8'h1B; // S
localparam KEY_RIGHT  = 8'h23; // D
localparam KEY_START  = 8'h5A; // ENTER
localparam KEY_BREAK  = 8'hF0;

always_comb begin
    if (keycode[15:8] == KEY_BREAK) begin
        // Klawisz został puszczony
        kb_rotate = 1'b0;
        kb_down   = 1'b0;
        kb_left   = 1'b0;
        kb_right  = 1'b0;
        kb_start  = 1'b0;
    end else begin
        // Klawisz wciśnięty
        kb_rotate = (keycode[7:0] == KEY_ROTATE);
        kb_down   = (keycode[7:0] == KEY_DOWN);
        kb_left   = (keycode[7:0] == KEY_LEFT);
        kb_right  = (keycode[7:0] == KEY_RIGHT);
        kb_start  = (keycode[7:0] == KEY_START);
    end
end

endmodule