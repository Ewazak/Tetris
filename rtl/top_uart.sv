module top_uart
    (
        input logic clk,
        input logic rst,
        input logic rx,
        input logic [7:0] uart_data_send,

        output logic [7:0] uart_data_recieved,
        output logic tx
    );

    //Variables and signals
    logic tx_nxt;
    logic tx_uart, rd_uart, tx_full, rx_empty, wr_uart, wr_uart_nxt;
    logic [7:0] w_data, r_data, w_data_nxt;

    //Logic


     always_ff @(posedge clk) begin
        if(rst) begin
            tx <= '0;
            {w_data, wr_uart} <= '0;
        end else begin
            tx <= tx_nxt;
            {w_data, wr_uart} <= {w_data_nxt, wr_uart_nxt};
        end
    end

    always_comb begin
        tx_nxt = tx_uart;
        rd_uart = !rx_empty;
        uart_data_recieved = r_data;
        if(!tx_full) begin
            w_data_nxt = uart_data_send;
            wr_uart_nxt = 1'b1;
        end else begin
            w_data_nxt = 0;
            wr_uart_nxt = 1'b0;
        end
    end

    //-----------------------------------------------------------------------
    // UART modules
    //-----------------------------------------------------------------------

    uart
    #(.DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1))
    u_uart (
        .clk(clk),
        .reset(rst),
        .rd_uart,
        .wr_uart,
        .rx,
        .tx(tx_uart),
        .w_data,
        .tx_full,
        .rx_empty,
        .r_data
    );
    endmodule