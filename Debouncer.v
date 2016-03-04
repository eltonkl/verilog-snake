module Debouncer(
    input wire 	Clock,
    input wire  Signal,
    output wire Enabled
    );

    parameter numTicks = 12500;

    reg step;
    reg stepPrev;
    reg [$clog2(numTicks)-1:0] counter;

    assign Enabled = step && !stepPrev;

    initial begin
        step = 0;
        stepPrev = 0;
        counter = 0;
    end

    always @ (posedge Clock) begin
        if (counter == numTicks) begin
            counter <= 0;
            step <= Signal;
        end else begin
            counter <= counter + 1'b1;
        end
        stepPrev <= step;
    end
endmodule
