module comp_mem_fsm (
    clk,
    start,
    check_k,

    en_k,
    en_i,
    en_j,
    //en_enc_in,
    en_f,
    en_si,
    en_sj,
    sel_addr,
    sel_data, 
    wren_d,
    wren_s,
    finished
    );

    input   clk,
            start,
            check_k;

    output  en_k,
            en_i,
            en_j,
            //en_enc_in,
            en_f,
            en_si,
            en_sj,
            sel_data, 
            wren_d,
            wren_s,
            finished;

    output [1:0] sel_addr;
    
    //state bits = x0__en_k__en_i__en_j__en_enc_in__en_f__en_si__en_sj__sel_addr__sel_data__wren_d__wren_s__finished

    typedef enum logic [13:0] {
        IDLE            =   14'b0_000_000_000_0000,
        INCREMENT_i     =   14'b0_010_000_000_0000,
        READ_Si         =   14'b0_000_000_001_0000,
        LOAD_Si         =   14'b0_000_001_001_0000,
        LOAD_j          =   14'b0_001_000_001_0000,
        READ_Sj         =   14'b1_000_000_000_0000,
        LOAD_Sj         =   14'b0_000_000_100_0000,
        WRITE_TO_Sj     =   14'b0_000_000_000_1010,
        WRITE_TO_Si     =   14'b0_000_000_001_0010,
        READ_f          =   14'b0_000_000_010_0000,
        LOAD_f          =   14'b0_000_010_010_0000,
        //LOAD_qm       =   14'b00001000100000,
        WRITE_d         =   14'b0_000_000_010_0100,
        INCREMENT_k     =   14'b0_100_000_010_0000,
        FINISHED        =   14'b0_000_000_000_0001
    } state_type;

    //state reg
    state_type state = IDLE;

    //assign outputs
    assign finished     =   state[0];
    assign wren_s       =   state[1];
    assign wren_d       =   state[2];
    assign sel_data     =   state[3];
    assign sel_addr     =   state[5:4];
    assign en_sj        =   state[6];
    assign en_si        =   state[7];
    assign en_f         =   state[8];
    //assign en_enc_in  =   state[9];
    assign en_j         =   state[10];
    assign en_i         =   state[11];
    assign en_k         =   state[12];

    //state logic
    always_ff @(posedge clk)
    begin
        case(state)
            IDLE:           if (start) state <= INCREMENT_i;
            INCREMENT_i:    state <= READ_Si;
            READ_Si:        state <= LOAD_Si;
            LOAD_Si:        state <= LOAD_j;
            LOAD_j:         state <= READ_Sj;
            READ_Sj:        state <= LOAD_Sj;
            LOAD_Sj:        state <= WRITE_TO_Sj;
            WRITE_TO_Sj:    state <= WRITE_TO_Si;
            WRITE_TO_Si:    state <= READ_f;
            READ_f:         state <= LOAD_f;
            LOAD_f:         state <= WRITE_d;
            //LOAD_qm:      state <= WRITE_d;
            WRITE_d:        state <= INCREMENT_k;
            INCREMENT_k:    begin
                            if (check_k) state <= FINISHED;
                            else state <= INCREMENT_i;
                            end
            FINISHED:       state <= IDLE;
        endcase
    end
endmodule