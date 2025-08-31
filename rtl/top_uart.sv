//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   top_uart
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:   Top-level UART interface module for sending and receiving 8-bit data.
 */
//////////////////////////////////////////////////////////////////////////////
 module top_uart
    (
        input  wire clk,
        input  wire rst,
        input  wire rx,
        input  wire [7:0] uart_data_send,
    
        output logic [7:0] uart_data_received,
        output logic tx
    );
    
    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    
    
    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic tx_uart, rd_uart, tx_full, rx_empty, wr_uart;
    logic [7:0] w_data, r_data;
    logic wr_uart_d;
    
    //------------------------------------------------------------------------------
    // output register with sync reset
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : write_data_reg
        if (rst) begin : write_data_rst_blk
            wr_uart_d <= 1'b0;
            w_data <= 8'd0;
        end else begin : write_data_run_blk
            w_data <= uart_data_send;
            wr_uart_d <= (uart_data_send != w_data) && !tx_full;
        end
    end
    
    //------------------------------------------------------------------------------
    // logic
    //------------------------------------------------------------------------------
    
    assign wr_uart = wr_uart_d;
    assign rd_uart = !rx_empty;
    assign uart_data_received = r_data;
    
    //-----------------------------------------------------------------------
    // Module instantiations
    //-----------------------------------------------------------------------
    
    uart
    #(.DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1))
    u_uart (
        .clk(clk),
        .reset(rst),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(rx),
        .tx(tx_uart),
        .w_data(w_data),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .r_data(r_data)
    );
    
    assign tx = tx_uart;
    
    endmodule