`include "Constants.v"

module FoodRandomizer(
        input wire Clock,
        output reg [$clog2(`GRID_HEIGHT)-1:0] yCoord,
        output reg [$clog2(`GRID_WIDTH)-1:0]  xCoord
    );
    
    reg [6:0] bits;
    reg [6:0] bits2;
    
    initial begin
        bits = 0;
        bits2 = 1;
    end

    always @ (posedge Clock) begin
        bits = bits + 1'b1;
        bits2 = bits2 + 1'b1;
        yCoord = (bits % (`GRID_HEIGHT - 1));
        xCoord = (bits2 % (`GRID_WIDTH - 1));
    end

endmodule