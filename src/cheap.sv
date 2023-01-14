`timescale 1ns/1ns

module cheap(clk, card, card_controller);
    input logic clk;
	 output logic card_controller;
	 output logic [4:0] card;
	 
	logic [6:0] counter;
	logic [4:0] baralho [51:0] = '{{1'b1}, {1'b1}, {4'b1010}, {3'b101}, {3'b100}, {4'b1010}, {1'b1}, {2'b10}, {3'b110}, {4'b1010}, {4'b1000}, {1'b1}, {4'b1010}, {4'b1001}, {3'b100}, {4'b1010}, {4'b1010}, {4'b1010}, {4'b1010}, {3'b111}, {4'b1001}, {4'b1010}, {3'b110}, {4'b1010}, {3'b101}, {4'b1010}, {4'b1010}, {4'b1000}, {3'b100}, {4'b1010}, {4'b1010}, {3'b111}, {3'b100}, {4'b1010}, {3'b110}, {4'b1010}, {2'b10}, {3'b110}, {4'b1001}, {4'b1000}, {4'b1001}, {2'b11}, {4'b1000}, {2'b10}, {3'b101}, {1'b1}, {3'b101}, {3'b111}, {2'b11}, {3'b111}, {2'b11}, {2'b11}};
	
	always_ff @(posedge clk)
		begin
			if(counter == 6'b110011) begin
				counter = 1'b0;
				card <= baralho[counter];
			end else begin
				card <= baralho[counter];
				counter++;
				
			end
		end
		
	always_ff @(posedge clk or posedge card_controller)
		begin
			if(card_controller) begin
				card_controller = 1'b0;
			end else begin
				card_controller = 1'b1;
			end
		end
	
endmodule : cheap