`include "Constants.v"

module VGAController(
    // TODO: need to pack/unpack array
    input wire [yCoordBits-1:0] snakeY [0:numSnakePieces-1], // y-coordinate
    input wire [xCoordBits-1:0] snakeX [0:numSnakePieces-1],  // x-coordinate
    input wire [yCoordBits-1:0] foodY,
    input wire [xCoordBits-1:0] foodX,
    input wire                          Clock,
    output reg [0:7]                    RGB,
    output wire                         HSync,
    output wire                         VSync
    );

    parameter hPixels = 800;    // Pixels per horizontal line
    parameter vLines = 521;     // Vertical lines per frame
    parameter hPulse = 96;      // Pulse length for horizontal sync
    parameter vPulse = 2;       // Pulse length for vertical sync
    parameter hBP = 144;        // End of horizontal back porch
    parameter hFP = 784;        // Beginning of horizontal front porch 
    parameter vBP = 31;         // End of vertical back porch
    parameter vFP = 511;        // Beginning of vertical front porch
    parameter vPolarity = 1'b0;    // Polarity when vertical pin is active
    parameter hPolarity = 1'b0;    // Polarity when horizontal pin is active
    parameter rgbInactive = 8'b00000000;
    // Active horizontal video region: hFP - hBP = 640
    // Active vertical video region: vFP - vBP = 480
    
    reg [9:0] hCounter = 0;
    reg [9:0] vCounter = 0;
    reg [$clog2(`NUM_SNAKE_PIECES)-1:0] i;
    
    always @ (posedge Clock) begin
        if (hCounter < hPixels - 1)
            hCounter <= hCounter + 1;
        else begin
            hCounter <= 0;
            if (vCounter < vLines - 1)
                vCounter <= vCounter + 1;
            else
                vCounter <= 0;
        end
    end

    assign HSync = (hCounter < hPulse) ? hPolarity : ~hPolarity;
    assign VSync = (vCounter < vPulse) ? vPolarity : ~vPolarity;
    
    wire [3:0] xBlockIndex = (hCounter - hBP)/`BLOCK_WIDTH;
    wire [3:0] yBlockIndex = (vCounter - vBP)/`BLOCK_HEIGHT;

    wire [(`BITS_PER_BLOCK)-1:0] blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
    
    genvar unpackHeight, unpackWidth;
    generate
        for (unpackHeight = 0; unpackHeight < (`GRID_HEIGHT); unpackHeight = unpackHeight + 1) begin : for_outer
            for (unpackWidth = 0; unpackWidth < (`GRID_WIDTH); unpackWidth = unpackWidth + 1) begin : for_inner
                assign blocks[unpackHeight][unpackWidth] = { Blocks[(`BITS_PER_BLOCK * ((unpackHeight * `GRID_WIDTH) + unpackWidth)) + 1], Blocks[(`BITS_PER_BLOCK * ((unpackHeight * `GRID_WIDTH) + unpackWidth))] };
            end
        end
    endgenerate
 
    always @ (*) begin
        if (vCounter >= vBP && vCounter < vFP) begin
            if (hCounter > hBP && hCounter < (hBP + 640)) begin
                // initialize to empty
                RGB = `COLOR_EMPTY;
                if (yBlockIndex == 0 or yBlockIndex == (`GRID_HEIGHT - 1) or xBlockIndex == 0 or xBlockIndex == (`GRID_WIDTH - 1))
                    RGB = `COLOR_WALL;
                else if (yBlockIndex == foodY && xBlockIndex == foodX)
                    RGB = `COLOR_FOOD;
                else begin
                    for (i = 0; i < NUM_SNAKE_PIECES; i = i + 1) begin
                        if (yBlockIndex == snakeY[i] && xBlockIndex == snakeX[i])
                            RGB = `COLOR_SNAKE;
                    end
                end
            end
            // Not in the active video region
            else
                RGB = rgbInactive;
        end
        // Not in the active video region
        else begin
            RGB = rgbInactive;
        end
    end
endmodule
