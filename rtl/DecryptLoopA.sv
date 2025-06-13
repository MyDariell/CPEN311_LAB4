module DecryptLoopA (clock, address, wren, data, finished, reset,start);

    input clock, reset,start;
    output reg wren = 1'b0; 
    output reg [7:0] address = 1'b0; 
    output reg [7:0] data    = 1'b0; 
    output reg finished      = 1'b0;
    
    reg [7:0] next_address = 1'b0; 

    always_ff @( posedge clock ) begin 
        if (reset || finished) begin
            wren <= 0; 
            data <= 0; 
            address <= 0; 
            finished <= 0;
        end
        else begin
            if (!finished && start) begin
                wren <= 1'b1;
                address <= next_address;
                data <= next_address;
                next_address <= address + 8'b1;

                if (address == 8'd255) 
                    finished <= 1'b1; 
            end
            else
                wren <= 1'b0; 
        end
    end


endmodule