/*
    Takes in index i and the secret_key
    Returns the secret_key_value

    SecretKeyController u_secret_key_ctrl (
    .input_i          (input_i),
    .secret_key       (secret_key),
    .secret_key_value (secret_key_value)
);

*/

module SecretKeyController (input_i, secret_key, secret_key_value);
    
	 input [23:0] secret_key;
    input wire [7:0] input_i;
    output [7:0] secret_key_value;

    parameter key_length = 8'd3;
    wire [7:0] secret_key_index;

    assign secret_key_index = input_i % key_length;  //modulus i with key_length 

    always_comb begin
        case (secret_key_index) 
            8'd0    : secret_key_value = secret_key [23:16]; 
            8'd1    : secret_key_value = secret_key [15:8];
            8'd2    : secret_key_value = secret_key [7:0];
            default : secret_key_value = 8'd0;
        endcase
    end

endmodule