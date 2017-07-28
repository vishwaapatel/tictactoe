module project (SW, LEDR, KEY, LEDG, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, CLOCK_50);
	// Player 1 uses green LEDs
	// Player 2 uses red LEDs
	input CLOCK_50;
	input [17:0] SW;
	input [3:0] KEY;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output [6:0] HEX6;
	output [6:0] HEX7;
	output [8:0] LEDG;
	output [17:0] LEDR;
	wire [8:0] in1;
	wire [8:0] in2;
	wire [8:0] out1;
	wire [8:0] out2;
	wire [3:0]counter_out1;
	wire [3:0]counter_out2;
	wire [3:0]counter_out3;
	wire [3:0]counter_out4;
	wire winner1;
	wire winner2;
	wire player2_out;
	wire player1_out;
	wire tie;
// Instantiate the counter module to start the clock as soon as the game starts(the program runs)
	counter c1 (
					.enable(1'b1),
					.clock(CLOCK_50),
					.winner1(winner1),
					.winner2(winner2),
					.tie(tie),
					.out1(counter_out1),
					.out2(counter_out2),
					.out3(counter_out3),
					.out4(counter_out4));

				// Instantiate the hex_decoder module for HEX4, HEX5, HEX6, HEX7 which will display the counter
	hex_decoder h0 (.hex_digit(counter_out4),
						.segments(HEX7));
	hex_decoder h1(.hex_digit(counter_out3),
						.segments(HEX6));
	hex_decoder h2 (.hex_digit(counter_out2),
						.segments(HEX5));
	hex_decoder h3 (.hex_digit(counter_out1),
						.segments(HEX4));

	player1_input input_p1(
								.d(SW[8:0]),
								.in1(in1),
								.in2(in2),
								.q_out2(out2),
								.clk(KEY[0]),
								.LED1(LEDR[0]),
								.LED2(LEDG[8:0]),
								.winner1(winner1),
								.winner2(winner2),
								.tie(tie)
								);
	
	check_winner win1 (
							.in(out2),
							.out(winner1)
							);

	player2_input input_p2 (
									.d(SW[17:9]),
									.in1(in1),
									.in2(out2),
									.q_out1(out1),
									.clk(KEY[1]),
									.LED(LEDR[17:9]),
									.winner1(winner1),
									.winner2(winner2),
									.tie(tie)
									);
	
	check_winner win2 (
							.in(out1),
							.out(winner2)
							);

	display_winner(
					.HEX3(HEX3),
					.winner1(winner1),
					.winner2(winner2),
					.out1(out1),
					.out2(out2),
					.tie(tie)
					);

	display_tokens tokens(
								.in1(out2),
								.in2(out1),
								.player(1'b1),
								.HEX0(HEX0),
								.HEX1(HEX1),
								.HEX2(HEX2)
								);

 endmodule

 module display_winner(HEX3, winner1, winner2, out1, out2, tie);
	// declares the inputs, outputs and reg
	output [6:0]HEX3;
	input [8:0] out1;
	input [8:0] out2;
	input winner1;
	input winner2;
	reg [6:0] hex;
	assign HEX3 = hex;
	output tie;
	reg out_tie;
	assign tie = out_tie;

	always @(*)
	begin
		// If winner1 is 1'b1, then displays 1 on the hex
		if(winner1)
		begin
			hex[0] <= 1'b1;
			hex[1] <= 1'b0;
			hex[2] <= 1'b0;
			hex[3] <= 1'b1;
			hex[4] <= 1'b1;
			hex[5] <= 1'b1;
			hex[6] <= 1'b1;
			out_tie <= 1'b0;
		end

	// If winner2 is 1'b1, then displays 2 on the hex
		else if(winner2)
		begin
			hex[0] <= 1'b0;
			hex[1] <= 1'b0;
			hex[2] <= 1'b1;
			hex[3] <= 1'b0;
			hex[4] <= 1'b0;
			hex[5] <= 1'b1;
			hex[6] <= 1'b0;
			out_tie <= 1'b0;
		end
		// If winner1 and winner2 is 1'b0, then enters the else statement
		else
		begin
			// all of the boxes are filled, then outputs a -
			if ((out1[0] || out2[0]) && (out1[1] || out2[1]) && (out1[2] || out2[2]) && (out1[3] || out2[3]) && (out1[4] || out2[4]) && (out1[5] || out2[5]) && (out1[6] || out2[6]) && (out1[7] || out2[7]) &&(out1[8] || out2[8]))
			begin
				hex[0] <= 1'b1;
				hex[1] <= 1'b1;
				hex[2] <= 1'b1;
				hex[3] <= 1'b1;
				hex[4] <= 1'b1;
				hex[5] <= 1'b1;
				hex[6] <= 1'b0;
				out_tie <= 1'b1;
			end
		// else turns off all the segments of the hex
			else
			begin
				hex[0] <= 1'b1;
				hex[1] <= 1'b1;
				hex[2] <= 1'b1;
				hex[3] <= 1'b1;
				hex[4] <= 1'b1;
				hex[5] <= 1'b1;
				hex[6] <= 1'b1;
				out_tie <= 1'b0;
			end
		end
	end

endmodule
module counter(enable, clock, winner1, winner2, out1, out2, out3, out4, tie);
	input clock;
	input enable;
	input winner1;
	input winner2;
	input tie;
	output [3:0] out1;
	output [3:0] out2;
	output [3:0] out3;
	output [3:0] out4;
	wire [27:0] output1;
	wire [27:0]d = 28'b0010111110101111000001111111;
	// uses rate divider to create a puase for 1 second
	rate_divider f1(
						.enable(enable),
						.start(start),
						.d(d),
						.clock(clock),
						.q(output1)
						);
	// assigns input for the display_counter module
	assign display_counter_enable = (output1 == 28'b0000000000000000000000000000) ? 1 : 0;

	display_counter f2(
						  .enable(display_counter_enable),
						  .start(REGout),
						  .clock(clock),
						  .winner1(winner1),
						  .winner2(winner2),
						  .tie(tie),
						  .q1(out1),
						  .q2(out2),
						  .q3(out3),
						  .q4(out4)
						  );

endmodule

module rate_divider(enable, start, d, clock, q);
	input enable;
	input clock;
	input start;
	//input clear_b;
	input [27:0] d;
	output [27:0] q;
	reg [27:0] out;
	assign q = out;

	always @(posedge clock)
	begin
		if (start)
			out <= d;
		if (out == 28'b0000000000000000000000000000) // when q is the
			out <= d; // q reset to 0
		else if(enable == 1'b1) // decrement q only when enable is 1
			out <= out - 1'b1; // decrement q
		end

endmodule


module display_counter(enable, start, clock, winner1, winner2, tie, q1, q2, q3, q4);
	input enable;
	input tie;
	input clock;
	input start;
	input winner1;
	input winner2;
	assign d = 4'b0000;
	output [3:0] q1;
	reg [3:0] out1;
	assign q1 = out1;
	output [3:0] q2;
	reg [3:0] out2;
	assign q2 = out2;
	output [3:0] q3;
	reg [3:0] out3;
	assign q3 = out3;
	output [3:0] q4;
	reg [3:0] out4;
	assign q4 = out4;
	
	always @(posedge clock)
	begin
	
		if(winner1 | winner2 | tie)
		begin
			out1 <= out1;
			out2 <= out2;
			out3 <= out3;
			out4 <= out4;
		end
		
		else if (start)
		begin
			out1 <= d;
			out2 <= d;
			out3 <= d;
			out4 <= d;
		end
		
		else if (enable)
		begin
			if (out1 < 4'b1001)
				out1 <= out1 + 1'b1;
			
			if(out1 == 4'b1001)
			begin
				out1 <= 4'b0000;
				out2 <= out2 + 1'b1;
			end
			
			if(out2 == 4'b0101 && out1 == 4'b1001)
			begin
				out2 <= 4'b0000;
				out1 <= 4'b0000;
				out3 <= out3 + 1'b1;
			end
			
			if (out3 == 4'b1001)
			begin
				out3 <= 4'b0000;
				out4 <= out4 + 1'b1;
			end
		end
	end
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
    always @(*)
         // turns on the hex_digit based on the value of the segments passed
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule
module player1_input(d, in1, in2, clk, q_out2, LED1, LED2, winner1, winner2, tie);
	// Declare all inputs, outputs and reg
	input clk;
	output LED1;
	input tie;
	input [8:0] d;
	output [7:0]LED2;
	input [8:0] in1;
	input [8:0] in2;
	input winner1;
	input winner2;
	output [8:0] q_out2;
	reg [8:0] out2;
	assign q_out2 = out2;
	wire winner = ~winner1 & ~winner2;
	reg ledr;
	assign LED1 = ledr;
	reg [7:0] ledg;
	assign LED2 = ledg;

	always @(posedge clk) // Triggered every time clock rises
	begin

		// If there is no winner then the if statement is entered
		if(~winner1 && ~winner2 && ~tie)
		begin
		/*
		// if(number of move by player 1 == number of moves by player 2)

		*/

		// Each time the always block runs, the if and else statements determine which LED's to turns on and
		// changes the value in out2 appropriately.

		/* If the value at d[x] is 1'b1, it means that a token has already been placed at the (x+1)'th position on the TicTacToe board
		* Positions on the TicTacToe board:
		*             1       2               3
		*             4               5               6
		*             7               8               9
		*/

			// If the switch corresponding to d[0](SW[0]) is on and a token hasn't already been placed at the first position,
			// turn on the LED and change the value at out2[0] to 1'b1 indicating that a token has been placed at the first position.
			if (d[0] == 1'b1 && in1[0] == 1'b0 && in2[0] == 1'b0)
			begin
				out2[0] <= 1'b1;
				ledr <= 1'b1;
			end

			// Else, the values of out2[0] and ledr will remain 1'b0
			else
			begin
				out2[0] <= 1'b0;
				ledr <= 1'b0;
			end

			// If the switch corresponding to d[1](SW[1]) is on and a token hasn't already been placed at the second position,
			// turn on the LED and change the value at out2[1] to 1'b1 indicating that a token has been placed at the second position.
			if (d[1] == 1'b1 && in1[1] == 1'b0 && in2[1] == 1'b0)
			begin
				out2[1] <= 1'b1;
				ledg[7] <= 1'b1;
			end
			// Else, the values of out2[1] and ledg[7] will remain 1'b0
			else
			begin
				out2[1] <= 1'b0;
				ledg[7] <= 1'b0;
			end

			// If the switch corresponding to d[2](SW[2]) is on and a token hasn't already been placed at the third position,
			// turn on the LED and change the value at out2[2]) to 1'b1 indicating that a token has been placed at the third position.
			if (d[2] == 1'b1 && in1[2] == 1'b0 && in2[2] == 1'b0)
			begin
				out2[2] <= 1'b1;
				ledg[6] <= 1'b1;
			end
			// Else, the values of out2[2] and ledg[6] will remain 1'b0
			else
			begin
				out2[2] <= 1'b0;
				ledg[6] <= 1'b0;
			end


			// If the switch corresponding to d[3](SW[3]) is on and a token hasn't already been placed at the fourth position,
			// turn on the LED and change the value at out2[3] to 1'b1 indicating that a token has been placed at the fourth position.
			if (d[3] == 1'b1 && in1[3] == 1'b0 && in2[3] == 1'b0)
			begin
				out2[3] <= 1'b1;
				ledg[5] <= 1'b1;
			end

			// Else, the values of out2[3] and ledg[5] will remain 1'b0
			else
			begin
				out2[3] <= 1'b0;
				ledg[5] <= 1'b0;
			end


			// If the switch corresponding to d[4](SW[4]) is on and a token hasn't already been placed at the fifth position,
			// turn on the LED and change the value at out2[4] to 1'b1 indicating that a token has been placed at the fifth position.
			if (d[4] == 1'b1 && in1[4] == 1'b0 && in2[4] == 1'b0)
			begin
				out2[4] <= 1'b1;
				ledg[4] <= 1'b1;
			end
			// Else, the values of out2[4] and ledg[4] will remain 1'b0
			else
			begin
				out2[4] <= 1'b0;
				ledg[4] <= 1'b0;
			end


			// If the switch corresponding to d[5](SW[5]) is on and a token hasn't already been placed at the sixth position,
			// turn on the LED and change the value at out2[5] to 1'b1 indicating that a token has been placed at the sixth position.
			if (d[5] == 1'b1 && in1[5] == 1'b0 && in2[5] == 1'b0)
			begin
				out2[5] <= 1'b1;
				ledg[3] <= 1'b1;
			end
			// Else, the values of out2[5] and ledg[3] will remain 1'b0
			else
			begin
				out2[5] <= 1'b0;
				ledg[3] <= 1'b0;
			end

			// If the switch corresponding to d[6](SW[6])is on and a token hasn't already been placed at the seventh position,
			// turn on the LED and change the value at out2[6] to 1'b1 indicating that a token has been placed at the seventh position.
			if (d[6] == 1'b1 && in1[6] == 1'b0 && in2[6] == 1'b0)
			begin
				out2[6] <= 1'b1;
				ledg[2] <= 1'b1;
			end
			// Else, the values of out2[6] and ledg[2] will remain 1'b0
			else
			begin
				out2[6] <= 1'b0;
				ledg[2] <= 1'b0;
			end

			// If the switch corresponding to d[7](SW[7]) is on and a token hasn't already been placed at the eight position,
			// turn on the LED and change the value at out2[7] to 1'b1 indicating that a token has been placed at the eight position.
			if (d[7] == 1'b1 && in1[7] == 1'b0 && in2[7] == 1'b0)
			begin
				out2[7] <= 1'b1;
				ledg[1] <= 1'b1;
			end
			// Else, the values of out2[7] and ledg[1] will remain 1'b0
			else
			begin
				out2[7] <= 1'b0;
				ledg[1] <= 1'b0;
			end

			// If the switch corresponding to d[8](SW[8]) is on and a token hasn't already been placed at the ninth position,
			// turn on the LED and change the value at out2[8] to 1'b1 indicating that a token has been placed at the ninth position.
			if (d[8] == 1'b1 && in1[8] == 1'b0 && in2[8] == 1'b0)
			begin
				out2[8] <= 1'b1;
				ledg[0] <= 1'b1;
			end

			// Else, the values of out2[8] and ledg[0] will remain 1'b0
			else
			begin
				out2[8] <= 1'b0;
				ledg[0] <= 1'b0;
			end
		end

		// If there is a winner, then nothing will change ie. the values in out2 and ledg will remain the same.
		else
		begin
			out2 <= out2;
			ledg <= ledg;
		end
	end


endmodule

module player2_input(d, in1, in2, clk, q_out1, LED, winner1, winner2, tie);
	// declares the inputs, outputs and regs
	input clk;
	input winner1;
	input tie;
	input winner2;
	input [8:0] d;
	input [8:0] in1;
	input [8:0] in2;
	output [8:0]LED;
	output [8:0] q_out1;
	reg [8:0] out1;
	assign q_out1 = out1;
	reg [8:0]led;
	assign LED = led;

	always @(posedge clk) // Triggered every time clock rises
	begin
		// if there is no winner, then the if statement is entered
		if(~winner1 && ~winner2 && ~tie)
		begin

		// Check if the number of moves of player2 is one less than the number of moves of player1
			// if switch d[0] is on and if no player has place any token in the first box, then the bit at the 0th position in out1 changes to 1'b1 and led [0] turns on
			if (d[0] == 1'b1 && in1[0] == 1'b0 && in2[0] == 1'b0)
			begin
				out1[0] <= 1'b1;
				led[8] <= 1'b1;
			end
			// else  the bit at the 0th position in out1 is 1'b0 and led[0] remains off
			else
			begin
				out1[0] <= 1'b0;
				led[8] <= 1'b0;
			end

			// if switch d[1] is on and if no player has place any token in the first box, then the bit at the 1st position in out1 changes to 1'b1 and led [1] turns on
			if (d[1] == 1'b1 && in1[1] == 1'b0 && in2[1] == 1'b0)
			begin
				out1[1] <= 1'b1;
				led[7] <= 1'b1;
			end
			// else the bit at the 1st position in out1 is 1'b0 and led[1] remains off
			else
			begin
				out1[1] <= 1'b0;
				led[7] <= 1'b0;
			end

			// if switch d[2] is on and if no player has place any token in the first box, then the bit at the 2nd position in out1 changes to 1'b1 and led[2] turns on
			if (d[2] == 1'b1 && in1[2] == 1'b0 && in2[2] == 1'b0)
			begin
				out1[2] <= 1'b1;
				led[6] <= 1'b1;

			end
			// else the bit at the 2nd position in out1 is 1'b0 and led[2] remains off
			else
			begin
				out1[2] <= 1'b0;
				led[6] <= 1'b0;
			end

			// if switch d[3] is on and if no player has place any token in the first box, then the bit at the 3rd position in out1 changes to 1'b1 and led[3] turns on
			if (d[3] == 1'b1 && in1[3] == 1'b0 && in2[3] == 1'b0)
			begin
				out1[3] <= 1'b1;
				led[5] <= 1'b1;
			end
			//else the bit at 3rd position in out1 is 1'b0 and led[3] remains off
			else
			begin
				out1[3] <= 1'b0;
				led[5] <= 1'b0;
			end

			// if switch d[4] is on and if no player has place any token in the first box, then the bit at the 4th position in out1 changes to 1'b1 and led[4] turns on
			if (d[4] == 1'b1 && in1[4] == 1'b0 && in2[4] == 1'b0)
			begin
				out1[4] <= 1'b1;
				led[4] <= 1'b1;
			end
			// else the bit at 4th position in out1 is 1'b0 and led[4] remains off
			else
			begin
				out1[4] <= 1'b0;
				led[4] <= 1'b0;
			end

			// if switch d[5] is on and if no player has place any token in the first box, then the bit at the 5th position in out1 changes to 1'b1 and led[5] turns on
			if (d[5] == 1'b1 && in1[5] == 1'b0 && in2[5] == 1'b0)
			begin
				out1[5] <= 1'b1;
				led[3] <= 1'b1;
			end
			// else the bit at the 5th position in out1 is 1'b0 and led[5] remains off
			else
			begin
				out1[5] <= 1'b0;
				led[3] <= 1'b0;
			end

			// if switch d[6] is on and if no player has place any token in the first box, then the bit at the 6th position in out1 changes to 1'b1 and led[6] turns on
			if (d[6] == 1'b1 && in1[6] == 1'b0 && in2[6] == 1'b0)
			begin
				out1[6] <= 1'b1;
				led[2] <= 1'b1;
			end
			// else the bit at 6th position in out1 is 1'b0 and led[6] remains off
			else
			begin
				out1[6] <= 1'b0;
				led[2] <= 1'b0;
			end

			// if switch d[7] is on and if no player has place any token in the first box, then the bit at the 7th position in out1 changes to 1'b1 and led[7] turns on
			if (d[7] == 1'b1 && in1[7] == 1'b0 && in2[7] == 1'b0)
			begin
				out1[7] <= 1'b1;
				led[1] <= 1'b1;
			end
			// else the bit at 7th position in out1 is 1'b0 and led[7] remains off
			else
			begin
				out1[7] <= 1'b0;
				led[1] <= 1'b0;
			end

			// if switch d[8] is on and if no player has place any token in the first box, then the bit at the 8th position in out1 changes to 1'b1 and led[8] turns on
			if (d[8] == 1'b1 && in1[8] == 1'b0 && in2[8] == 1'b0)
			begin
				out1[8] <= 1'b1;
				led[0] <= 1'b1;
			end
			// else the bit at 8th position in out1 is 1'b0 and led[8] remains off
			else
			begin
				out1[8] <= 1'b0;
				led[0] <= 1'b0;
			end
		end
		// If there is a winner, then the values in out1 will remain the same and the led's will remain the same
		else
		begin
			out1 <= out1;
			led <= led;
		end
	end

endmodule


module check_winner (in, out);
	//declares the input, output and reg
	input [8:0] in;
	output out;
	reg out1;
	// out is 1'b0 if there are no winning moves else it is 1'b1
	assign out = (in[0] & in[1] & in[2]) || (in[3] & in[4] & in[5]) || (in[6] & in[7] & in[8]) || (in[0] & in[3] & in[6]) || (in[1] & in[4] & in[7]) || (in[2] & in[5] & in[8]) || (in[0] & in[4] & in[8]) || (in[2] & in[4] & in[6]);

endmodule


module display_tokens (in1, in2, player, HEX0, HEX1, HEX2);
	// declares the inputs, outputs and the regs

	input [8:0] in2;
	input [8:0] in1;
	input player;
	output [6:0]HEX0;
	output [6:0]HEX1;
	output [6:0]HEX2;
	reg [6:0]hex2;
	reg [6:0]hex1;
	reg [6:0]hex0;
	assign HEX2 = hex2;
	assign HEX1 = hex1;
	assign HEX0 = hex0;


	always @(*)
	begin
		// Turns off the segments 1, 2, 4 and 5 of hex0, hex1, and hex2
		hex2[1] <= 1'b1;
		hex1[1] <= 1'b1;
		hex0[1] <= 1'b1;
		hex2[2] <= 1'b1;
		hex1[2] <= 1'b1;
		hex0[2] <= 1'b1;
		hex2[4] <= 1'b1;
		hex1[4] <= 1'b1;
		hex0[4] <= 1'b1;
		hex2[5] <= 1'b1;
		hex1[5] <= 1'b1;
		hex0[5] <= 1'b1;

		// If the 0th bit of in1 or in2 is on, then turns on segment 0 of hex2 otherwise turns it off
		if (in1[0] == 1'b1 || in2[0])
		begin
			hex2[0] <= 1'b0;
		end
		else
		begin
			hex2[0] <= 1'b1;
		end
		// If the 1th bit of in1 or in2 is on, then turns on segment 0 of hex1 otherwise turns it off
		if (in1[1] == 1'b1|| in2[1])
			begin
		hex1[0] <= 1'b0;
		end
		else
		begin
			hex1[0] <= 1'b1;
		end

		// If the 2th bit of in1 or in2 is on, then turns on segment 0 of hex0 otherwise turns it off
		if (in1[2] == 1'b1|| in2[2])
		begin
			hex0[0] <= 1'b0;
		end
		else
		begin
			hex0[0] <= 1'b1;
		end

		// If the 3th bit of in1 or in2 is on, then turns on segment 6 of hex2 otherwise turns it off
		if (in1[3] == 1'b1|| in2[3])
		begin
			hex2[6] <= 1'b0;
		end
		else
		begin
			hex2[6] <= 1'b1;
		end

		// If the 4th bit of in1 or in2 is on, then turns on segment 6 of hex1 otherwise turns it off
		if (in1[4] == 1'b1|| in2[4])
		begin
			hex1[6] <= 1'b0;
		end
		else
		begin
			hex1[6] <= 1'b1;
		end

		// If the 5th bit of in1 or in2 is on, then turns on segment 6 of hex0 otherwise turns it off

		if (in1[5] == 1'b1|| in2[5])
		begin
			hex0[6] <= 1'b0;
		end
		else
		begin
			hex0[6] <= 1'b1;
		end

		// If the 6th bit of in1 or in2 is on, then turns on segment 3 of hex2 otherwise turns it off
		if (in1[6] == 1'b1|| in2[6])
		begin
			hex2[3] <= 1'b0;
		end
		else
		begin
			hex2[3] <= 1'b1;
		end

		// If the 7th bit of in1 or in2 is on, then turns on segment 3 of hex1 otherwise turns it off
		if (in1[7] == 1'b1|| in2[7])
		begin
			hex1[3] <= 1'b0;
		end
		else
		begin
			hex1[3] <= 1'b1;
		end

		// If the 8th bit of in1 or in2 is on, then turns on segment 3 of hex0 otherwise turns it off
		if (in1[8] == 1'b1|| in2[8])
		begin
			hex0[3] <= 1'b0;
		end
		else
		begin
			hex0[3] <= 1'b1;
		end
	end
endmodule
