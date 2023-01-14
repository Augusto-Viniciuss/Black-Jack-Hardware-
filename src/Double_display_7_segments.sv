`timescale 1ns/1ns

module double_display_7_segments (value, clk, disp7_dig1, disp7_dig2);
	input logic clk;
	input logic [5:0] value;
	output logic [6:0] disp7_dig1, disp7_dig2;
	
	logic [6:0] aux_buffer;

	always_ff @(posedge clk)
		begin
			if(value >= 4'b1010 && value < 5'b10100) begin
				disp7_dig1 = 7'b1111001;
				aux_buffer = value - 4'b1010;
			end else if(value >= 5'b10100 && value < 5'b11110) begin
				disp7_dig1 = 7'b0100100;
				aux_buffer = value - 5'b10100;
			end else if(value >= 5'b11110) begin
				disp7_dig1 = 7'b0110000;
				aux_buffer = value - 5'b11110;
			end else begin
				disp7_dig1 = 7'b1000000;
				aux_buffer = value;
			end
		
			case (aux_buffer)
				4'd0: disp7_dig2 = 7'b1000000;
				4'd1: disp7_dig2 = 7'b1111001;
				4'd2: disp7_dig2 = 7'b0100100;
				4'd3: disp7_dig2 = 7'b0110000;
				4'd4: disp7_dig2 = 7'b0011001;
				4'd5: disp7_dig2 = 7'b0010010;
				4'd6: disp7_dig2 = 7'b0000010;
				4'd7: disp7_dig2 = 7'b1111000;
				4'd8: disp7_dig2 = 7'b0000000;
				4'd9: disp7_dig2 = 7'b0010000;
			endcase
		end
endmodule : double_display_7_segments