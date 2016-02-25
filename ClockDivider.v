module ClockDivider(
	input		MasterClock,
	output	reg	Clock
	output  reg gameClock;
	output  reg fastClock;  // for seg display
	);
	
	parameter GameClockBreakPoint = 50000000;   // 2Hz
	parameter FastClockBreakPoint = 160000;
	
	reg clockCounter;
	reg gameClockCounter;
	reg fastClockCounter;
	
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
		//Clock <= ~Clock && clockCounter;
		if (clockCounter) begin
		    Clock <= ~Clock;
		end
		
		if (gameClock == GameClockBreakPoint) begin
		    gameClockCounter <= 0;
		    gameClock <= 1;
		end else begin
		    gameClockCounter <= gameClockCounter + 1;
		    gameClock <= 0;
		end
		
		if (fastClock == FastClockBreakPoint) begin
		    fastClockCounter <= 0;
		    fastClock <= 1;
		end else begin
		    fastClockCounter <= fastClockCounter + 1;
		    fastClock <= 0;
		end
		
	end

endmodule
