module bufor_tim(
    input logic clk,      
    input logic rst,    
    input logic [11:0] xpos,
    input logic [11:0] ypos,
    output logic [11:0] xpos_bufor,
    output logic [11:0] ypos_bufor  
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        xpos_bufor <= '0;
        ypos_bufor <= '0;       
    end else begin
        xpos_bufor <= xpos;
        ypos_bufor <= ypos;        
    end
end

endmodule
