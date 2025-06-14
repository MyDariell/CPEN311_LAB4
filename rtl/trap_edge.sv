
module trap_edge (async_sig, clk, reset, trapped_edge); 
	input logic async_sig,clk,reset; 
	output logic trapped_edge;

	reg q1, q2, q3,q4;
	
	wire edge_pulse;
	
	assign edge_pulse = q3 && ~q4; 
	
	always_ff@(posedge async_sig or posedge reset) begin
		if (reset) q1 <= 0;
			else q1 <= 1'b1; 	
	end
		
	always_ff@(posedge clk) begin
		q2 <= q1; 	
		q3 <= q2;
		q4 <= q3;
	end
	
	always_ff@(posedge edge_pulse or posedge reset) begin
			if (reset) trapped_edge <= 0; 
			else trapped_edge <= 1'b1; 
	end
endmodule

//module trap_edge (async_sig, clk, reset, trapped_edge); 
//	input logic async_sig,clk,reset; 
//	output logic trapped_edge;
//
//	reg q1, q2, q3;
//	
//	always_ff@(posedge async_sig or posedge reset) begin
//		if (reset) q1 <= 0;
//		else q1 <= 1'b1; 
//	end
//	
//	always_ff@(posedge clk) begin
//		q2 <= q1; 	
//		q3 <= q2; 
//		trapped_edge <= q3; 
//	end
//
//endmodule