module counter #(
    parameter N = 8 
)(
    input  logic clk,
    input  logic reset,   // synchronous active-high reset
    input  logic en,      // enable count
    output reg [N-1:0] count = '0
);
   
    always_ff @(posedge clk) begin
        if (reset)
            count <= '0;
        else if (en)
            count <= count + 1;
    end

endmodule
