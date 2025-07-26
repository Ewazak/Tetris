// Każda płytka steruje własnym graczem, używając tych samych klawiszy

module keyboard_ctl (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  ps2_data,
    input  logic        ps2_data_ready,

    output logic        left,
    output logic        right,
    output logic        down,
    output logic        rotate,
    output logic        start
);

    // PS/2 make codes
    localparam [7:0]
        KEY_A     = 8'h1C,
        KEY_D     = 8'h23,
        KEY_S     = 8'h1B,
        KEY_W     = 8'h1D,
        KEY_ENTER = 8'h5A;

    logic is_break;
    logic [7:0] last_code;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            is_break <= 0;
            last_code <= 8'd0;
            left <= 0;
            right <= 0;
            down <= 0;
            rotate <= 0;
            start <= 0;
        end else if (ps2_data_ready) begin
            if (ps2_data == 8'hF0) begin
                is_break <= 1; // następny kod to break code
            end else begin
                last_code <= ps2_data;
                if (!is_break) begin
                    case (ps2_data)
                        KEY_A:     left    <= 1;
                        KEY_D:     right   <= 1;
                        KEY_S:     down    <= 1;
                        KEY_W:     rotate  <= 1;
                        KEY_ENTER: start   <= 1;
                    endcase
                end else begin
                    case (ps2_data)
                        KEY_A:     left    <= 0;
                        KEY_D:     right   <= 0;
                        KEY_S:     down    <= 0;
                        KEY_W:     rotate  <= 0;
                        KEY_ENTER: start   <= 0;
                    endcase
                    is_break <= 0;
                end
            end
        end
    end

endmodule