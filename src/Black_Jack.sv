`timescale 1ns/1ns

module Black_Jack (stay, hit, rst, clk, win, tie, lose, player_hand_disp_dig1, player_hand_disp_dig2, machine_hand_disp_dig1, machine_hand_disp_dig2);
    input logic stay, hit, rst, clk; 
    output logic win, tie, lose;
    output logic [6:0] player_hand_disp_dig1, player_hand_disp_dig2, machine_hand_disp_dig1, machine_hand_disp_dig2;
	 
	 logic clk_1HZ, flag_AS_player, flag_AS_machine, card_controller;
	 logic [4:0] card;
	 logic [5:0] player_hand, machine_hand;
    logic [2:0]counter;
    logic [4:0] machine_secret_card, card_buffer;
	 
    enum {START, DISTRI_CARD, PLAYER_HIT, MACHINE_HIT, DECISION}estate;
    enum {WIN, TIE, LOSE, UNKNOWN}result;
	 
	clk_HZ_BJ #(49999999, 26) clk_1HZ_BJ(.rst(rst), .clk(clk), .clk_HZ(clk_1HZ));
	double_display_7_segments dp_player (.value(player_hand), .clk(clk), .disp7_dig1(player_hand_disp_dig1), .disp7_dig2(player_hand_disp_dig2));
	double_display_7_segments dp_machine (.value(machine_hand), .clk(clk), .disp7_dig1(machine_hand_disp_dig1), .disp7_dig2(machine_hand_disp_dig2));
	cheap cp(.clk(clk_1HZ), .card(card), .card_controller(card_controller));

	
    always_ff @(posedge clk_1HZ or negedge rst)
        begin
            if(rst == 1'b0) begin
                estate = START;
            end else begin
                unique case(estate)
                    START : begin
                        estate = DISTRI_CARD;
						result = UNKNOWN;
						counter = 1'b0;
                    end
                    DISTRI_CARD : begin
                        if(counter > 2'b11) begin
                            estate = PLAYER_HIT;
                        end else begin
									counter++;
								end
                    end	
                    PLAYER_HIT : begin
                        if(stay == 1'b0) begin
                           estate <= MACHINE_HIT;
                        end else if(player_hand > 5'b10101 && flag_AS_player == 1'b0) begin
							result = LOSE;
							estate = DECISION;
						end
                    end
                    MACHINE_HIT : begin
                        if(machine_hand > 5'b10101 && flag_AS_machine == 1'b0) begin
                            result = WIN;
                            estate = DECISION;
                        end else if((machine_hand >= 5'b10001 && machine_hand <= 5'b10101) || machine_hand >= player_hand) begin
                            result = UNKNOWN;
                            estate = DECISION;
                        end
                    end
                    DECISION : begin
                        if(win != 1'b0 || tie != 1'b0 || lose != 1'b0) begin
									estate = DECISION;
                        end
                    end
                endcase
            end 
        end
    
    always_latch
        begin
            unique case(estate)
                START : begin
                    win = 1'b0;
                    lose = 1'b0;
                    tie = 1'b0;
                    player_hand = 1'b0;
                    machine_hand = 1'b0;
                    machine_secret_card = 1'b0;
                    card_buffer = 1'b0;
                    flag_AS_player = 1'b0;
                    flag_AS_machine = 1'b0;
                end
                DISTRI_CARD : begin
						if(card_controller && counter <= 2'b11) begin
                        unique case(counter)
                            1'b0 : begin 
											player_hand = card == 1'b1 ? 4'b1011 : card;
											
											if(player_hand == 4'b1011) begin
												 flag_AS_player = 1'b1;
											end
                            end
                            1'b1 : begin 
											machine_hand = card == 1'b1 ? 4'b1011 : card;

											if(machine_hand == 4'b1011) begin
												 flag_AS_machine = 1'b1;
											end   
                            end
                            2'b10 : begin 
                                if(card == 1'b1 && player_hand != 4'b1011) begin 
                                    player_hand = player_hand + 4'b1011;
												flag_AS_player = 1'b1;
                                end else begin
                                    player_hand = player_hand + card;
                                 end
                            end
                            2'b11 : begin 
                                if(card == 1'b1 && machine_hand != 4'b1011) begin
                                    machine_secret_card = 4'b1011;
												flag_AS_machine = 1'b1;
                                end else begin
                                    machine_secret_card = card;
                                end
                            end
                        endcase
                    end
                end
                PLAYER_HIT : begin
                    if(card_controller) begin
                        if(stay == 1'b0) begin
                            machine_hand = machine_hand + machine_secret_card;
                            if(machine_hand < 5'b10001 && card_buffer != card) begin
                                if(card == 1'b1 && (machine_hand < 4'b1011)) begin
                                    machine_hand = machine_hand + 4'b1011;
                                    flag_AS_machine = 1'b1;
                                end else begin
                                    machine_hand = machine_hand + card;
                                end
                            end
                        end else if(hit == 1'b0 && stay == 1'b1) begin
                            if(card == 1'b1 && (player_hand < 4'b1011)) begin
                                player_hand = player_hand + 4'b1011;
                                flag_AS_player = 1'b1;
                            end else begin
                                player_hand = player_hand + card;
                            end

                            card_buffer = card; 
                        end
                    end

                    if(player_hand > 5'b10101) begin
                        if(flag_AS_player) begin
                            player_hand = player_hand - 4'b1010;
                            flag_AS_player = 1'b0;
                        end
                    end 
                end
                MACHINE_HIT : begin
                    if(card_controller) begin
                        if(machine_hand < 5'b10001 && machine_hand < player_hand) begin
                            if(card == 1'b1 && (machine_hand < 4'b1011)) begin
                                machine_hand = machine_hand + 4'b1011;
                                flag_AS_machine = 1'b1;
                            end else begin
                                machine_hand = machine_hand + card;
                            end
                        end
                    end

                    if(machine_hand > 5'b10101) begin
                        if(flag_AS_machine) begin
                            machine_hand = machine_hand - 4'b1010;
                            flag_AS_machine = 1'b0;
                        end
					end
                end
                DECISION : begin			
						  if(card_controller) begin
								unique case(result)
									WIN : win = 1'b1;
									LOSE : lose = 1'b1;
									UNKNOWN : begin
										 if(player_hand > machine_hand) begin
											  win = 1'b1;
										 end else if(machine_hand > player_hand) begin
											  lose = 1'b1;
										 end else if(player_hand == machine_hand) begin
											  tie = 1'b1;
										 end
									end
								endcase
							end
					end
            endcase
        end

endmodule : Black_Jack