//////////////////////////////////////////////////////////////////////////////
/*
 2025  AGH University of Science and Technology
 MTM UEC2
 Module name:  block_randomizer
 Author:        Ewa Żakowska, Adrianna Solińska
 Description:  Generates pseudo-random block types using an XOR-shift counter, updated on load_new signal.
 */
//////////////////////////////////////////////////////////////////////////////
module block_randomizer (
    input  logic clk,
    input  logic rst,
    input  logic load_new,        // signal to randomize a new block
    output logic [2:0] block_type // 0..6 (7 block types)
);

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    logic [2:0] counter;
    logic [2:0] block_type_nxt;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
    always_ff @(posedge clk) begin : block_type_reg_blk
        if(rst) begin : block_type_reg_rst_blk
            block_type <= 3'd1;
        end
        else begin : block_type_reg_run_blk
            block_type <= block_type_nxt;
        end
    end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin : counter_reg_blk
        if (rst) begin : counter_reg_rst_blk
            counter <= 3'd1; // arbitraty non-zero initial value
        end
        else begin : counter_reg_run_blk
            counter <= {counter[1:0], counter[2] ^ counter[1]}; // XOR-shift
        end
    end

    always_comb begin : block_type_comb_blk
        if (load_new) begin
            // choose block_type based on counter value (mod 7)
            block_type_nxt = (counter % 7) + 1;
        end
        else begin
            block_type_nxt = block_type;
        end
    end
endmodule