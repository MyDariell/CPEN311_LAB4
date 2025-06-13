module main_controller (
	 input clk,
    input start,reset,
    input [7:0] mem_in,
    input [7:0] input_data_a, 
    input [7:0] input_data_b,
    input [7:0] input_data_c,
    input [7:0] input_address_a, 
    input [7:0] input_address_b,
    input [7:0] input_address_c,
    input finished_a, 
    input finished_b, 
    input finished_c, 
    input wren_a,
    input wren_b,
    input wren_c,

    output [7:0] address_out,
    output [7:0] data_out,
    output wren_out,
    output [7:0] received_data_b,
    output start_a,
    output start_b,
    output start_c 
);


    wire [1:0] loop_sel; 
    reg [7:0] state = IDLE; 

    // {count, starta,startb,startc, loop_sel}
    parameter   IDLE	= 8'b00000000;
    parameter   LOOP_A	= 8'b00110000;
    parameter   LOOP_B	= 8'b01001001;
    parameter   FINISH	= 8'b01100000;

    assign start_a      = state [4];
    assign start_b      = state [3];
    assign start_c      = state [2];
    assign loop_sel     = state [1:0];
	 assign received_data_b = mem_in; 
	

    always_ff @ (posedge clk) begin
        if (reset) state <= IDLE;
        else begin
            case (state) 
                IDLE    :   if (start) state <= LOOP_A; 
                LOOP_A  :   if (finished_a) state <= LOOP_B; 
                LOOP_B  :   if (finished_b) state <= FINISH;
                FINISH  :   state <= FINISH; 
            endcase
        end
    end

    always_comb begin
        case (loop_sel)
            2'b00   :   begin
                            data_out    = input_data_a;
                            address_out = input_address_a;
                            wren_out    = wren_a;		 
                        end
            2'b01   :   begin
                            data_out    		= input_data_b;
                            address_out 		= input_address_b;
                            wren_out    		= wren_b;
                        end
            2'b10   :   begin
                            data_out    = input_data_c;
                            address_out = input_address_c;
                            wren_out    = wren_c;   
                        end
            default :	begin
                            data_out    = input_data_a;
                            address_out = input_address_a;
                            wren_out    = wren_a;   
                        end
        endcase
    end



endmodule