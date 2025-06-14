module main_controller (
	input clk,
    input start,
    input reset,
    input [7:0] mem_in_s,               //data from sram 
    input [7:0] mem_in_e,               //data from erom
    input [7:0] mem_in_d,               //data from dram
    input [7:0] input_data_a,           //data from loopA
    input [7:0] input_data_b,           //data from loopB
    input [7:0] input_data_c_d,         //data sent from loop c into dram
    input [7:0] input_data_c_s,         //data sent from loop c into sram 
    input [7:0] input_address_a,        //address from loop a into sram 
    input [7:0] input_address_b,        //address from loop b into sram 
    input [7:0] input_address_c_e,      //address from loop c into erom
    input [7:0] input_address_c_d,      //address from loopc into dram 
    input [7:0] input_address_c_s,      //address from loopc into sram 
    input finished_a,                   //finished signal for a
    input finished_b,                   //finished signal for b
    input finished_c,                   //finished signal for c
    input wren_a,                       //wren from loop a for sram wren 
    input wren_b,                       //wren from loop b for sram wren
    input wren_c_d,                     //wren from loop c for dram wren 
    input wren_c_s,                     //wren from loop c for sram wren
    output reg [7:0] address_out_d,         //output address to dram 
    output reg [7:0] address_out_e,         //output address to erom
    output reg [7:0] address_out_s,         //output address to sram 
    output reg [7:0] data_out_s,            //output data to sram
    output reg [7:0] data_out_d,            //output data to dram 
    output reg wren_s,                      //output wren for sram
    output reg wren_d,                      //output wren for dram
    output reg [7:0] received_data_b,       //output received data from sram for loop b
    output reg [7:0] received_data_c_e,     //output received data from erom for loop c
    output reg [7:0] received_data_c_s,     //output received data from sram for loop c
    output reg start_a,                     //ouput start signal for loop a
    output reg start_b,                     //ouput start signal for loop b
    output reg start_c                      //ouput start signal for loop c
);

    wire [1:0] loop_sel; 
    reg [7:0] state = IDLE; 

    // {count, starta,startb,startc, loop_sel}
    parameter   IDLE	= 8'b00000000;
    parameter   LOOP_A	= 8'b00110000;
    parameter   LOOP_B	= 8'b01001001;
    parameter   LOOP_C	= 8'b01100110;
    parameter   FINISH	= 8'b01100000;

    assign start_a      = state [4];
    assign start_b      = state [3];
    assign start_c      = state [2];
    assign loop_sel     = state [1:0];
	//assign received_data_b = mem_in; 
	

    always_ff @ (posedge clk) begin
        if (reset) state <= IDLE;
        else begin
            case (state) 
                IDLE    :   if (start) state <= LOOP_A; 
                LOOP_A  :   if (finished_a) state <= LOOP_B; 
                LOOP_B  :   if (finished_b) state <= LOOP_C;
                LOOP_C  :   if (finished_c) state <= FINISH;
                FINISH  :   state <= FINISH; 
            endcase
        end
    end

    always_comb begin
        case (loop_sel)
            2'b00   :   begin
                            //sram 
                            data_out_s      = input_data_a;     //used
                            address_out_s   = input_address_a;  //used
                            wren_s          = wren_a;           //used

                            //dram
                            data_out_d          = 0;           
                            address_out_d       = 0;        
                            wren_d              = 0;                 

                            //erom
                            address_out_e       = 0;        

                            received_data_b     = 0;          
                            received_data_c_e   = 0;
                            received_data_c_s   = 0;
                        end
            2'b01   :   begin
                             //sram 
                            data_out_s    		= input_data_b;         //used
                            address_out_s 		= input_address_b;      //used
                            wren_s    		    = wren_b;               //used
                            
                            //dram
                            data_out_d          =  0;
                            address_out_d       = 0;
                            wren_d              = 0;
                            
                            //erom
                            address_out_e       = 0;
                            
                            received_data_b     = mem_in_s;             //used
                            received_data_c_e   = 0;
                            received_data_c_s   = 0;
                            
                        end
            2'b10   :   begin
                            //sram
                            data_out_s      = input_data_c_s;           //used
                            address_out_s   = input_address_c_s;        //used
                            wren_s          = wren_c_s;                 //used

                            //dram
                            data_out_d      = input_data_c_d;           //used
                            address_out_d   = input_address_c_d;        //used
                            wren_d          = wren_c_d;                 //used

                            //erom
                            address_out_e   = input_address_c_e;        //used
                            
                            received_data_b     = 0 ;  
                            received_data_c_e   = mem_in_e;               //used
                            received_data_c_s   = mem_in_s;               //used
                            
                        end
            default :	begin
                            //sram
                            data_out_s          = 0;           
                            address_out_s       = 0;        
                            wren_s              = 0;                 

                            //dram
                            data_out_d          = 0;          
                            address_out_d       = 0;        
                            wren_d              = 0;                 

                            //erom
                            address_out_e       = 0;        

                            received_data_b     = 0 ;         
                            received_data_c_e   = 0;
                            received_data_c_s   = 0;
                        end
        endcase
    end



endmodule