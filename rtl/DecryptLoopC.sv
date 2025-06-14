`default_nettype none
module DecryptLoopC (clk, start, data_in_S, data_in_E, wren_d, wren_s, finished, address_E, address_D, address_S, data_D, data_S);
    input   wire clk, start; 
    input   wire [7:0] data_in_S, data_in_E;
    output  wire wren_d,wren_s; 
    output  wire finished; 
    output  wire [7:0] address_E, address_D, address_S;
    output  wire [7:0] data_D, data_S; 

    wire en_i,en_j, en_f, en_k;
    wire en_sj, en_si;
    wire sel_data;
    wire [1:0]sel_addr; 
    wire check_k;
    wire [4:0] k_val;
    wire [7:0] i_val; 
    wire [7:0] j_val; 
    wire [7:0] f_val; 
    wire [7:0] si, sj; 
    wire [7:0] new_j; 

    mem_reg u_mem_reg (
        .clk        (clk),
        .data_in    (data_in_S),
        .en_sj      (en_sj),
        .en_si      (en_si),
        .si         (si),
        .sj         (sj)
    );

    //j = s[i] + j
    assign new_j = si + j_val;

    //ff for loading j value 
    always_ff @ (posedge clk) begin
        if (en_j) begin
            j_val <= new_j ; 
        end        
    end

    //Load daata from s into f 
    always_ff @ (posedge clk) begin
        if (en_f)
            f_val <= data_in_S;
    end

     //MUX to select which data to write to in s_memory 
    assign data_S = (sel_data) ? si : sj ;

    //Flag to signal end of k have been reached 
    assign check_k = (k_val == 5'd31);

    assign data_D = f_val ^ data_in_E; //f xor encrypted_input[k]
	

    //MUX to select which address to send to s_memory 
    always_comb begin
        case (sel_addr) 
            2'b00   :   address_S = si + sj; 
            2'b01   :   address_S = i_val;
            2'b10   :   address_S = j_val;
            default :   address_S = i_val;
        endcase
    end
	 
	 assign address_E = k_val; 
	 assign address_D = k_val; 

   
    counter u_increment_i (
        .clk    (clk),
        .en     (en_i),
        .reset  (1'b0),
        //outputs
        .count (i_val)
    ); 

    counter #(.N(5)) u_increment_k ( //Turn k to be 5 bits 
        .clk    (clk),
        .en     (en_k),
        .reset  (1'b0),
        //outputs
        .count (k_val)
    ); 

    comp_mem_fsm u_comp_mem_fsm (
        .clk        (clk),
        .start      (start),
        .check_k    (check_k),
        //outputs
        .en_k       (en_k),
        .en_i       (en_i),
        .en_j       (en_j),
        //en_enc_in,
        .en_f       (en_f),
        .en_si      (en_si),
        .en_sj      (en_sj),
        .sel_addr   (sel_addr),
        .sel_data   (sel_data), 
        .wren_d     (wren_d),
        .wren_s     (wren_s),
        .finished   (finished)
    ); 


endmodule