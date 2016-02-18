module ClockDivider(
	input		MasterClock,
	output	reg	Clock
	);
	
	reg clockCount;
	
	initial begin
		Clock = 0;
		clockCount = 0;
	end

	always @ (posedge MasterClock) begin
		clockCount <= ~clockCount;
		Clock <= ~Clock && clockCount;
	end

endmodule
