module char_rom (
    input  logic       clk,
    input  logic [7:0] char_xy,     // Indeks znaku (0–255)
    output logic [6:0] char_code    // 7-bitowy kod ASCII
);
    localparam string TEXT = {
        "Otters hold hands while floating",   
        "to stay together while they rest",   
        "They avoid drifting apart at sea",   
        "Floating helps them sleep calmly",   
        "Together they drift without fear",  
        "Safe from tides in tight embrace",   
        "A bond that keeps them from harm",   
        "Nature guards the calmness."   

    }; 

    // Out register
    always_ff @(posedge clk) begin
        char_code <= TEXT[char_xy];
    end

endmodule
