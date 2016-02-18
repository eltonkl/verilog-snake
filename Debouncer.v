module Debouncer(
    input wire 	Clock,
    input wire  Signal,
    output wire Enabled
    );
	
	reg step;
	reg stepPrev;
	
	assign Enabled = step && !step_prev;
	
	initial
	begin
		step = 0;
		stepPrev = 0;
	end

	always @ (posedge Clock)
	begin
		step <= Signal;
		stepPrev <= step;
	end

endmodule
