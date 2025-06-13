module edge_detector (async_sig, outclk, out_sync_sig);
    input logic async_sig, outclk; 
    output logic out_sync_sig; 
    logic q1,q2,q3,q4; 
    
    //This helps to clear the async-set flip-flop (fdc_2) safely
    mydff #(1) fdc_1  (.clk(~outclk), .d(q4),.q(q1), .clr(1'b0)); 

    // fdc_2 is set by the async signal and cleared by q1 which helps to capture the async event and hold it until it is safely synchronized
    mydff #(1) fdc_2  (.clk(async_sig), .d(1'b1), .q(q2), .clr(q1));

    // fdc_3 and fdc_4 help to safely transfer the signal from the async domain to the outclk domain,
    // to reduce the probability of metastability
    mydff #(1) fdc_3  (.clk(outclk), .d(q2), .q(q3),.clr(1'b0)); 
    mydff #(1) fdc_4  (.clk(outclk), .d(q3), .q(q4), .clr(1'b0)); 

    // Output is the synchronized signal in the outclk domain
    assign out_sync_sig = q4; 
 
endmodule

// Parameterized D flip-flop with asynchronous clear
module mydff #(parameter N = 8) 
        (input logic clk,clr,
        input logic [N-1 :0] d,
        output logic [N-1 : 0] q
     );
        
        always_ff @(posedge clk or posedge clr) begin
                if (clr) q <= '0; 
                else q <= d;
        end
endmodule