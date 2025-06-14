module mem_reg (clk, data_in, en_si, en_sj, si, sj); 
    input clk;
    input [7:0] data_in; 
    input en_si;
    input en_sj;
    output reg [7:0] si, sj;

    //Load S[i] value from RAM 
    always_ff @ (posedge clk) begin
        if (en_si) begin
            si <= data_in;   
        end
    end

    //Load S[j] value from RAM 
    always_ff @ (posedge clk) begin
        if (en_sj) begin
            sj <= data_in;   
        end
    end

endmodule