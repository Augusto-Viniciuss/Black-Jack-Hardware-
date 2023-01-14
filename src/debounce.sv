module debounce (clk, signal, signal_established);
	input logic clk, signal;
	output logic signal_established;
	
	localparam DELAY_BOTTON = 74999999, NBITS = 26;
	
	logic [NBITS - 1:0]counter;
	
	always_ff @(posedge clk)
		begin
			if(counter == DELAY_BOTTON) begin
				signal_established <= 1'b0;
			end else if(signal && signal_established != 1'b1) begin
				signal_established <= 1'b1;
				counter <= 1'b0;
			end else begin
				counter++;
			end
		end

endmodule : debounce