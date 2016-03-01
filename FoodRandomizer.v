`include "Constants.v"

module FoodRandomizer(
        input wire [0:(`BITS_PER_BLOCK * `GRID_HEIGHT * `GRID_WIDTH)-1] Blocks,
        input wire MasterClock,
        input wire ButtonLeft,
        input wire ButtonRight,
        input wire ButtonUp,
        input wire ButtonDown,
        input wire ButtonCenter,
        output reg [$clog2(`GRID_HEIGHT)-1:0] NextFoodV,
        output reg [$clog2(`GRID_WIDTH)-1:0] NextFoodH
    );
    
    reg [6:0] LFSRC;
    reg [6:0] LFSRL;
    reg [6:0] LFSRR;
    reg [`BITS_PER_BLOCK-1:0] blockType;
    
    // unpack
    wire [(`BITS_PER_BLOCK)-1:0] blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
    genvar unpackHeight, unpackWidth;
    generate
        for (unpackHeight = 0; unpackHeight < (`GRID_HEIGHT); unpackHeight = unpackHeight + 1) begin : for_outer
            for (unpackWidth = 0; unpackWidth < (`GRID_WIDTH); unpackWidth = unpackWidth + 1) begin : for_inner
                assign blocks[unpackHeight][unpackWidth] = { Blocks[(`BITS_PER_BLOCK * ((unpackHeight * `GRID_WIDTH) + unpackWidth))], Blocks[(`BITS_PER_BLOCK * ((unpackHeight * `GRID_WIDTH) + unpackWidth)) + 1] };
            end
        end
    endgenerate
    
    always @ (posedge MasterClock or negedge ButtonCenter) begin
        if (~ButtonCenter) begin
            LFSRC <= 7'hf;
        end else begin
            LFSRC <= {LFSRC[5:0], LFSRC[6] ^ LFSRC[1]};
        end
    end
    
    always @ (posedge MasterClock or negedge ButtonLeft) begin
        if (~ButtonLeft) begin
            LFSRL <= 7'hf;
        end else begin
            LFSRL <= {LFSRL[5:0], LFSRL[6] ^ LFSRL[1] ^ ButtonDown};
        end
    end
    
    always @ (posedge MasterClock or negedge ButtonRight) begin
        if (~ButtonRight) begin
            LFSRR <= 7'hf;
        end else begin
            LFSRR <= {LFSRR[5:0], LFSRR[6] ^ LFSRR[1] ^ ButtonUp};
        end
    end
    
    always @ (posedge MasterClock) begin
        NextFoodV <= LFSRC ^ LFSRL & ('b1 > $clog2(`GRID_HEIGHT));
        NextFoodH <= LFSRC ^ LFSRR & ('b1 > $clog2(`GRID_WIDTH));
        
        // check the indices are not out of bounds
        // make sure that this block is not WALL or SNAKE
        
        while (NextFoodV >= `GRID_HEIGHT-1 || NextFoodV <= 0 || NextFoodH >= `GRID_WIDTH-1 || NextFoodH <= 0 || blocks[NextFoodV][NextFoodH] != `BLOCK_EMPTY) begin
            NextFoodV <= LFSRC ^ LFSRL & ('b1 > $clog2(`GRID_HEIGHT));
            NextFoodH <= LFSRC ^ LFSRR & ('b1 > $clog2(`GRID_WIDTH));
        end
    end
    
endmodule