module shuffle_mem_fsm (
    clk, 
    start, 
    check_new_val,  
    
    wren, 
    en_new_i_val,
    en_sj,
    en_si,
    en_j,
    sel_addr,
    sel_data,
    finished
    );

    input   clk,            //clock signal
            start,          //start-finish protocol
            check_new_val;  //check if i=255 reached
   
    output  wren,           //write enable to memory
            en_new_i_val,   //increment i
            en_sj,           //update s[j] reg
            en_si,          //update s[i] reg
            en_j,           //calc new value of j
            sel_addr,       //select address: 1=j, 0=i
            sel_data,       //selec data: 1 = s[i], 0 = s[j] 
            finished;       //start-finish protocol

    //state bits = x0__wren__en_new_i_val__en_sj__en_si__en_j__sel_addr__sel_data__finished
    typedef enum logic [8:0] {
        IDLE        =   9'b000_000_000,
        READ_Si     =   9'b100_000_000,
        LOAD_Si     =   9'b000_010_000,
        LOAD_j      =   9'b000_001_000,
        READ_Sj     =   9'b000_000_100,
        LOAD_Sj     =   9'b000_100_100,
        WRITE_TO_Si =   9'b010_000_000,
        WRITE_TO_Sj =   9'b011_000_110,
        FINISHED    =   9'b000_000_001
    } state_type;

    //state reg
    state_type state = IDLE;

    //assign outputs
    assign finished     =   state[0];
    assign sel_data     =   state[1];
    assign sel_addr     =   state[2];
    assign en_j         =   state[3];
    assign en_si        =   state[4];
    assign en_sj        =   state[5];
    assign en_new_i_val =   state[6];
    assign wren         =   state[7];

    //state logic
    always_ff @(posedge clk)
    begin
        case (state)
            IDLE:           if (!check_new_val & start)   state <= READ_Si;
            READ_Si:        state <= LOAD_Si;
            LOAD_Si:        state <= LOAD_j;
            LOAD_j:         state <= READ_Sj;
            READ_Sj:        state <= LOAD_Sj;
            LOAD_Sj:        state <= WRITE_TO_Si;
            WRITE_TO_Si:    state <= WRITE_TO_Sj;
            WRITE_TO_Sj:    begin
                            if (check_new_val)  state <= FINISHED;
                            else state <= READ_Si;
                            end
            FINISHED:       state <= IDLE;
        endcase
    end
endmodule