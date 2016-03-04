module Debouncer(
    input wire 	Clock,
    input wire  Signal,
    output wire Enabled
    );
	
    reg step;
    reg stepPrev;
    reg [31:0] counter;

    assign Enabled = step && !stepPrev;

    initial begin
        step = 0;
        stepPrev = 0;
        counter = 0;
    end

    always @ (posedge Clock) begin
        if (counter == 40000) begin
            counter <= 0;
            step <= Signal;
        end else begin
            counter <= counter + 1;
        end

        stepPrev <= step;
    end

endmodule
