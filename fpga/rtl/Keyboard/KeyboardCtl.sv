module KeyboardCtl (
    input  logic [15:0] keycode,
    output logic kb_rotate,
    output logic kb_down,
    output logic kb_left,
    output logic kb_right,
    output logic kb_start,
    output logic kb_falling
);

timeunit 1ns;
timeprecision 1ps;

// Kody klawiszy
localparam KEY_ROTATE = 8'h75; // Strzalka w gore
localparam KEY_LEFT   = 8'h6B; // Strzalka w lewo
localparam KEY_DOWN   = 8'h72; // Strzalka w dol
localparam KEY_RIGHT  = 8'h74; // Strzalka w prawo
localparam KEY_FALLING = 8'h29; //Spacja
localparam KEY_START  = 8'h5A; // ENTER
localparam KEY_BREAK  = 8'hF0;

always_comb begin
    if (keycode[15:8] == KEY_BREAK) begin
        // Klawisz został puszczony
        kb_rotate = 1'b0;
        kb_down   = 1'b0;
        kb_left   = 1'b0;
        kb_right  = 1'b0;
        kb_falling = 1'b0;
        kb_start  = 1'b0;
    end else begin
        // Klawisz wciśnięty
        kb_rotate = (keycode[7:0] == KEY_ROTATE);
        kb_down   = (keycode[7:0] == KEY_DOWN);
        kb_left   = (keycode[7:0] == KEY_LEFT);
        kb_right  = (keycode[7:0] == KEY_RIGHT);
        kb_falling = (keycode[7:0] == KEY_FALLING);
        kb_start  = (keycode[7:0] == KEY_START);
    end
end

endmodule