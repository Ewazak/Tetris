   module draw_rect_ctl (
    input  logic         clk,
    input  logic         rst,
    input  logic         mouse_left,
    input  logic [11:0]  mouse_xpos,
    input  logic [11:0]  mouse_ypos,
    output logic [11:0]  xpos,
    output logic [11:0]  ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    // Parameters
    localparam int TICK_MAX         = 499_999; //Slow clock (from 0 is 500)
    localparam int Y_LIMIT          = 535; //600-64-1 (VER_PIXELS-RECT_HEIGHT-additional 1 so it stays on the screen)
    localparam int INIT_VEL         = 1; //Beggining vel
    localparam int BOUNCE_LOSS_NUM  = 8;   //80% (0.8)
    localparam int BOUNCE_LOSS_DEN  = 10; //80% (0.8)

    // Registers
    logic [31:0]         tick_cnt;
    logic signed [7:0]   vel;
    logic                falling;          // 1 = falling, 0 = going up
    logic signed [11:0]  pos_y;
    logic                animation_active;
    logic [11:0]         mouse_prev; // mouse staying position

    // Click
    logic mouse_left_prev;
    logic start_bounce;

    
    always_ff @(posedge clk) begin
        mouse_left_prev <= mouse_left;
        start_bounce <= (mouse_left_prev && !mouse_left);
    end

    // Main logic
    always_ff @(posedge clk) begin
        if (rst) begin
            xpos     <= 0;
            ypos     <= 0;
            pos_y    <= 0;
            vel      <= INIT_VEL;
            falling  <= 1;
            tick_cnt <= 0;
            mouse_prev <= 0;
            animation_active <= 0;
        end else begin
        //Making mouse stay in the same position when the rectangle is bouncing and move when the rectangle is not dropped yet
            if (animation_active == 0) begin
                xpos <= mouse_xpos;
            end else begin
                xpos <= mouse_prev;
            end
                

            if (start_bounce) begin
                ypos     <= mouse_ypos;
                pos_y    <= mouse_ypos;
                vel      <= INIT_VEL;
                falling  <= 1;
                tick_cnt <= 0;
                animation_active <= 1; // Activate after click
                mouse_prev <= mouse_xpos;
            end

            if (animation_active) begin
                if (tick_cnt == TICK_MAX) begin
                    tick_cnt <= 0;

                    if (falling) begin
                        // falling
                        if (Y_LIMIT - pos_y > vel) begin //Checking if the object hasn't exceeded bottom edge
                            ypos  <= pos_y + vel;
                            pos_y <= pos_y + vel;
                            vel   <= vel + 1; //Increasing velocity
                        end else begin
                            ypos  <= Y_LIMIT;
                            pos_y <= Y_LIMIT;
                            vel   <= (vel * BOUNCE_LOSS_NUM) / BOUNCE_LOSS_DEN; //Decreasing velocity after bounce
                            falling <= 0;
                        end
                    end else begin
                        // going up
                        if (vel > 0) begin
                            ypos  <= pos_y - vel;
                            pos_y <= pos_y - vel;
                            vel   <= vel - 1; //Reducing velocity
                        end else begin
                            vel     <= INIT_VEL; //Reset velocity
                            falling <= 1;
                        end
                    end
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
        end
    end

endmodule
