`timescale 1ns / 1ps

/*
		_a
	|f		|b
		_g
	|e		|c
		_d		.D 1 is off, 0 is on

		=> 7'b[Dgfedcba]
*/

//Define Block with digit bit off
`define ZERO IO_SSEG[7:0] <= 8'b11000000; //0 T
`define ONE IO_SSEG[7:0] <= 8'b11111001; //1 T
`define TWO IO_SSEG[7:0] <= 8'b10100100; //2 T
`define THREE IO_SSEG[7:0] <= 8'b10110000; //3 T
`define FOUR IO_SSEG[7:0] <= 8'b10011001; //4 T
`define FIVE IO_SSEG[7:0] <= 8'b10010010; //5 T
`define SIX IO_SSEG[7:0] <= 8'b10000010; //6 T
`define SEVEN IO_SSEG[7:0] <= 8'b11011000; //7 T
`define EIGHT IO_SSEG[7:0] <= 8'b10000000; //8
`define NINE IO_SSEG[7:0] <= 8'b10010000; //9 T
`define OFF IO_SSEG[7:0] <= 8'b11111111; //OFF

//Define Block with digit bit on
`define ZERO_ON IO_SSEG[7:0] <= 8'b01000000; //0 T
`define ONE_ON IO_SSEG[7:0] <= 8'b01111001; //1 T
`define TWO_ON IO_SSEG[7:0] <= 8'b00100100; //2 T
`define THREE_ON IO_SSEG[7:0] <= 8'b00110000; //3 T
`define FOUR_ON IO_SSEG[7:0] <= 8'b00011001; //4 T
`define FIVE_ON IO_SSEG[7:0] <= 8'b00010010; //5 T
`define SIX_ON IO_SSEG[7:0] <= 8'b00000010; //6 T
`define SEVEN_ON IO_SSEG[7:0] <= 8'b01011000; //7 T
`define EIGHT_ON IO_SSEG[7:0] <= 8'b00000000; //8
`define NINE_ON IO_SSEG[7:0] <= 8'b00010000; //9 T

module DigitalClock(
    input M_CLOCK,
    input [3:0] IO_PB,
    input [7:0] IO_DSW,
	 output reg [3:0] IO_SSEGD, // IO Board Seven Segment Digits			
	 output reg [7:0] IO_SSEG,  // 7=dp, 6=g, 5=f,4=e, 3=d,2=c,1=b, 0=a
	 output IO_SSEG_COL,    // 7 segment colon select
    output [3:0] F_LED, 
    output [7:0] IO_LED,
	 output reg TX
    );
	 
	assign IO_SSEG_COL = 1;		//activate the colon displays
	assign F_LED = 4'b0000;
	 
	 
	//TEMP VARIABLES
	reg [25:0] SecondsCounter = 0; //Seconds counter
	reg [19:0] MultiPlexerCounter = 0; //Multiplexing counter
	reg [5:0] HowManySeconds = 1; //Seconds Counter from 0-60
	
	//FLAGS
	reg HALFSECONDFLAG = 0;
	
	//Single Digit Variables
	reg [2:0] DigitONE = 1;
	reg [3:0] DigitTWO = 2;
	reg [2:0] DigitTHREE = 0;
	reg [3:0] DigitFOUR = 0;
	
	//Initialize output reg values
	initial begin
		IO_SSEGD = 4'b1111;	// deactivate the seven segment display
		IO_SSEG = 8'b11111111;	// deactivate the seven segment display
		//IO_LED = 8'b00000000;
	end
	
	 
   //Digit half off half on control always
	//Also seconds counter
	always @(posedge M_CLOCK) begin 
		TX <= HALFSECONDFLAG;
		SecondsCounter <= SecondsCounter + 1'b1;
		if(SecondsCounter == 50000000) begin
			SecondsCounter <= 0;		
				
				case(IO_DSW)
				
				//Switch Mechanisms
				8'b00111111:  begin //IFF first 2 are up -STANDARD CLOCK
				if(HowManySeconds == 60) begin //Minute timer
				HowManySeconds <= 1;
						if(DigitFOUR == 9) begin //Going to change to 10 so increment next digit instead
							DigitFOUR <= 0;
							//Increment DigitThree
							if(DigitTHREE == 5) begin //Going to change to 6 so increment next digit instead
							DigitTHREE <= 0;
							//Increment DigitTWO which is dependent on Digit ONE
								if(DigitONE >= 1) begin
									if(DigitTWO >= 2) begin
										DigitTWO <= 1; //If time is 12:59 - go to 01:00
										DigitONE <= 0;
									end
									else begin
										DigitTWO <= DigitTWO + 1'b1; //Otherwise we going to 2 from 10:00 to 11:59
									end
								end
								else begin //IF DigitONE isn't 1 then we are 00:00 to 09:59
									if(DigitTWO == 9) begin
										DigitTWO <= 0; 
										DigitONE <= 1;
									end
									else begin 
										DigitTWO <= DigitTWO + 1'b1;
									end
								end						
							end
							else begin //otherwise increment by 1
								DigitTHREE <= DigitTHREE + 1'b1;
							end
						end
						else begin //IF digitFOUR is 0-8 then increment
							DigitFOUR <= DigitFOUR + 1'b1;	
						end
				end 
			else begin
				HowManySeconds <= HowManySeconds + 1'b1;
			end
				end
			8'b11001110:  begin //STOPWATCH MODE -COUNTDOWN TIMER PAY ATTENTION TO LAST SWITCH TO TURN ON THE STOPWATCH
							if(DigitFOUR == 0) begin //going to change to 9 sine we're counting down
								DigitFOUR <= 9;
								if(DigitTHREE == 0) begin //going to change to 5
										DigitTHREE <= 5;
										if(DigitTWO == 0 && DigitONE > 0) begin //going to change 9
											DigitTWO <= 9;
											DigitONE <= DigitONE - 1'b1;
										end
										else if(DigitTWO == 0 && DigitONE == 0) begin //IF timer has counted to 0 - stay at 0 for all
											DigitTWO <= 0; 
											DigitONE <= 0;
											DigitTHREE <= 0;
											DigitFOUR <= 0;
										end
										else DigitTWO <= DigitTWO - 1'b1;
								end
								else DigitTHREE <= DigitTHREE - 1'b1;		
							end
							else DigitFOUR <= DigitFOUR - 1'b1; //decrement iff D4 is 1-9			
				end
			8'b11110010: begin //STOPWATCH ACTIVATE MODE		 	
					if(DigitFOUR == 9) begin //Going to change to 10 so increment next digit instead
							DigitFOUR <= 0;
							if(DigitTHREE == 5) begin //Going to change to 6 so increment next digit instead
								DigitTHREE <= 0;
								if(DigitTWO == 9) begin
									DigitTWO <= 0;
									if(DigitONE == 5) begin
										DigitONE <= 6; DigitTWO <= 0; DigitTHREE <= 0; DigitFOUR <= 0; //If our timer reaches 1 hour - stop counting and always show 60:00
									end
									else DigitONE <= DigitONE + 1'b1;
								end
								else DigitTWO <= DigitTWO + 1'b1;
							end
							else DigitTHREE <= DigitTHREE + 1'b1;
						end
						else DigitFOUR <= DigitFOUR + 1'b1;	
				end 	//end previous case	
				endcase
			
		end
		
		
		//Half Second Module flag module -Will keep outside case statement
		if(SecondsCounter < 25000000) begin
			HALFSECONDFLAG <= 0; //Digit off
		end
		else begin
			HALFSECONDFLAG <= 1;	
		end
		
		//Pushbutton Manipulation on a per case basis.
		if(SecondsCounter == 100000) begin 
		
		case(IO_DSW)
			8'b00111111:begin //STANDARD CLOCK					
						if(!IO_PB[3]) DigitFOUR <= DigitFOUR + 1'b1;
						if(!IO_PB[2]) DigitTHREE <= DigitTHREE + 1'b1;
						if(!IO_PB[1]) begin
							if(DigitONE == 1 && DigitTWO >= 2) DigitTWO <= 0;
							else DigitTWO <= DigitTWO + 1'b1;
						end
						if(!IO_PB[0]) 
							if(DigitONE == 1) DigitONE <= 0;
							else DigitONE <= DigitONE + 1'b1;
					end
					
			8'b11001111: begin //TIMER TIME SET MODE ...crude handling
	
						if(!IO_PB[3]) begin
							if(DigitFOUR == 9) DigitFOUR <= 0;
							else DigitFOUR <= DigitFOUR + 1'b1;
						end
						if(!IO_PB[2]) begin
							if(DigitTHREE == 5) DigitTHREE <= 0;
							else DigitTHREE <= DigitTHREE + 1'b1;
						end
						if(!IO_PB[1]) begin
							if(DigitTWO == 9) DigitTWO <= 0;
							else DigitTWO <= DigitTWO + 1'b1;
						end
						if(!IO_PB[0]) begin
							if(DigitONE == 6) DigitONE <= 0;
							else DigitONE <= DigitONE + 1'b1;
						end
					end
			8'b11110011: begin //STOPWATCH TIME RESET
					if(!IO_PB[3] || !IO_PB[2] || !IO_PB[1] || !IO_PB[0]) begin
						DigitONE <= 0; DigitTWO <= 0; DigitTHREE <= 0; DigitFOUR <= 0;
					end
				end
		endcase
		end
	end 

	//Main Logic Always Block
	always @(posedge M_CLOCK) begin
		MultiPlexerCounter <= MultiPlexerCounter + 1'b1;
		if(MultiPlexerCounter == 1000000) begin
			MultiPlexerCounter <= 0;
			
		end
		//1st 7 segment display digit on, rest off
		if(MultiPlexerCounter < 250000) begin
			IO_SSEGD <= 4'b1110;
			//7 segment display logic
			case (DigitONE)
				0: begin
						`ZERO
					end
				1: begin
						`ONE
					end
				2: begin
						`TWO
					end
				3: begin
						`THREE
					end
				4: begin
						`FOUR
					end
				5: begin
						`FIVE
					end
				6: begin
						`SIX
					end
				default: begin
						`ONE
					end			
			endcase
		end
		//2nd 7 segment display digit on, rest off
		else if(MultiPlexerCounter >= 250000 && MultiPlexerCounter < 500000) begin
			IO_SSEGD <= 4'b1101;
			//7 segment display logic
			case (DigitTWO)
				0: begin
						`ZERO
					end
				1: begin
						`ONE
					end
				2: begin
						`TWO
					end
				3: begin
						`THREE
					end
				4: begin
						`FOUR
					end
				5: begin
						`FIVE
					end
				6: begin
						`SIX
					end
				7: begin
						`SEVEN
					end
				8: begin
						`EIGHT
					end
				9: begin
						`NINE
					end
				default: begin
						`TWO
					end			
			endcase
		end
		//3rd 7 segment display digit on, rest off
		else if(MultiPlexerCounter >= 500000 && MultiPlexerCounter < 750000) begin
			IO_SSEGD <= 4'b1011;
			//7 segment display logic
			case (DigitTHREE)
				0: begin
						`ZERO
					end
				1: begin
						`ONE
					end
				2: begin
						`TWO
					end
				3: begin
						`THREE
					end
				4: begin
						`FOUR
					end
				5: begin
						`FIVE
					end
				default: begin
						`ZERO
					end			
			endcase
		end
		//4th 7 segment display digit on, rest off
		else begin //if(MultiPlexerCounter >= 750000 && MultiPlexerCounter < 1000000)
			IO_SSEGD <= 4'b0111;
			//Second Beeper LOGIC
			if(HALFSECONDFLAG) begin
				case (DigitFOUR)
				0: begin
						`ZERO_ON
					end
				1: begin
						`ONE_ON
					end
				2: begin
						`TWO_ON
					end
				3: begin
						`THREE_ON
					end
				4: begin
						`FOUR_ON
					end
				5: begin
						`FIVE_ON
					end
				6: begin
						`SIX_ON
					end
				7: begin
						`SEVEN_ON
					end
				8: begin
						`EIGHT_ON
					end
				9: begin
						`NINE_ON
					end
				default: begin
						`ZERO_ON
					end			
				endcase
			end
			else begin
				case (DigitFOUR)
				0: begin
						`ZERO
					end
				1: begin
						`ONE
					end
				2: begin
						`TWO
					end
				3: begin
						`THREE
					end
				4: begin
						`FOUR
					end
				5: begin
						`FIVE
					end
				6: begin
						`SIX
					end
				7: begin
						`SEVEN
					end
				8: begin
						`EIGHT
					end
				9: begin
						`NINE
					end
				default: begin
						`ZERO
					end			
				endcase
			end
			
		end
	end
	
	//Using my usual IO LED assign statement just to keep track of what mode i'm in during testing.
	assign IO_LED = {!IO_DSW[7], !IO_DSW[6], !IO_DSW[5], !IO_DSW[4], !IO_DSW[3], !IO_DSW[2], !IO_DSW[1], !IO_DSW[0]};
		
endmodule
