module ClockDivider(
	input		MasterClock,
	output	reg	Clock
	output  reg gameClock;
	);
	
	parameter GameClockBreakPoint = 50000000;   // 2Hz
	
	reg clockCounter;
	reg gameClockCounter;
	
	initial begin
		Clock = 0;
		gameClock = 0;
		clockCounter = 0;
		gameClockCounter = 0;
	end

	always @ (posedge MasterClock) begin
		clockCounter <= ~clockCounter;
		//Clock <= ~Clock && clockCounter;
		if (clockCounter) begin
		    Clock <= ~Clock;
		end
		
		
		if (gameClocker == GameClockBreakPoint) begin
		    gameClockCounter <= 0;
		    gameClock <= 1;
		end else begin
		    gameClockCounter <= gameClockCounter + 1;
		    gameClock <= 0;
		end
	end

endmodule
