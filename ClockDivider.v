module ClockDivider(
	input		MasterClock,
	output	reg	Clock,
	output  reg gameClock,
	output  reg fastClock  // for seg display
	);
	
	parameter GameClockBreakPoint = 15000000;
	parameter FastClockBreakPoint = 160000;
	
	reg clockCounter;
	reg [$clog2(GameClockBreakPoint)-1:0] gameClockCounter;
	reg [$clog2(FastClockBreakPoint)-1:0] fastClockCounter;
	
	initial begin
		Clock = 0;
		gameClock = 0;
		fastClock = 0;
		
		clockCounter = 0;
		gameClockCounter = 0;
		fastClockCounter = 0;
	end

	always @ (posedge MasterClock) begin
		clockCounter <= ~clockCounter;
		if (clockCounter) begin
		    Clock <= ~Clock;
		end
		
		if (gameClockCounter == GameClockBreakPoint) begin
		    gameClockCounter <= 1'b0;
		    gameClock <= 1'b1;
		end else begin
		    gameClockCounter <= gameClockCounter + 1'b1;
		    gameClock <= 1'b0;
		end
		
		if (fastClockCounter == FastClockBreakPoint) begin
		    fastClockCounter <= 1'b0;
		    fastClock <= 1'b1;
		end else begin
		    fastClockCounter <= fastClockCounter + 1'b1;
		    fastClock <= 1'b0;
		end
		
	end
endmodule
