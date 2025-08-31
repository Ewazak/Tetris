//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:   font_arbiter
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:   Arbitrates multiple font clients requesting character lines from a single font ROM.
 */
//////////////////////////////////////////////////////////////////////////////
 module font_arbiter #(
    parameter NCLIENTS = 8
)(
    input  logic  clk,          // posedge active clock
    input  logic  rst,          // high-level active synchronous reset
    input  logic  [NCLIENTS-1:0] req,
    input  logic  [10:0]         addr [NCLIENTS],
    output logic [10:0]         rom_addr,
    output logic                rom_req,
    (* keep = "true" *) input logic [7:0] rom_data,
    output logic [NCLIENTS-1:0] grant_onehot,
    output logic                data_valid
);

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    logic [NCLIENTS-1:0] sel_onehot;
    logic [NCLIENTS-1:0] sel_onehot_reg;
    logic [10:0] chosen_addr;
    logic any_req;

//------------------------------------------------------------------------------
// output registers with sync reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : out_reg_blk
    if (rst) begin : out_reg_rst_blk
        sel_onehot_reg <= '0;
        grant_onehot   <= '0;
        data_valid     <= 1'b0;
    end
    else begin : out_reg_run_blk
        // Choice latch
        sel_onehot_reg <= sel_onehot;
        grant_onehot   <= sel_onehot_reg;
        data_valid     <= |sel_onehot_reg;
    end
end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
// Lowest index wins
function automatic integer priority_select(input logic [NCLIENTS-1:0] r);
    integer k;
    for (k = 0; k < NCLIENTS; k = k + 1)
        if (r[k]) return k;
    return -1;
endfunction

always_comb begin : arbiter_comb_blk
    any_req = |req;
    sel_onehot = '0;
    chosen_addr = '0;
    if (any_req) begin
        integer idx;
        idx = priority_select(req);
        if (idx >= 0) begin
            sel_onehot[idx] = 1'b1;
            chosen_addr = addr[idx];
        end
    end
end

assign rom_addr = chosen_addr;
assign rom_req  = any_req;

endmodule