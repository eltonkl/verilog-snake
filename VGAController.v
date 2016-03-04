`include "Constants.v"

module VGAController(
    input wire [0:(yCoordBits * `NUM_SNAKE_PIECES)-1] packSnakeY,
    input wire [0:(xCoordBits * `NUM_SNAKE_PIECES)-1] packSnakeX,
    input wire [yCoordBits-1:0] foodY,
    input wire [xCoordBits-1:0] foodX,
    input wire                          Clock,
    output reg [0:7]                    RGB,
    output wire                         HSync,
    output wire                         VSync
    );

    parameter yCoordBits = $clog2(`GRID_HEIGHT);
    parameter xCoordBits = $clog2(`GRID_WIDTH);
    parameter numSnakePieces = `NUM_SNAKE_PIECES;
    parameter numPiecesBits = $clog2(numSnakePieces);

    wire [yCoordBits-1:0] snakeY [0:numSnakePieces-1]; // y-coordinate
    wire [xCoordBits-1:0] snakeX [0:numSnakePieces-1];  // x-coordinate
    reg [numPiecesBits:0] i;
    
    // unpack into snakeY
    genvar h, k;
    generate
        for (h = 0; h < (`NUM_SNAKE_PIECES); h = h + 1) begin : for_outer
            for (k = 0; k < yCoordBits; k = k + 1) begin : for_inner
                assign snakeY[h][k] = packSnakeY[(h * yCoordBits) + k];
            end
        end
    endgenerate
    
    // unpack into snakeX
    genvar w, l;
    generate
        for (w = 0; w < (`NUM_SNAKE_PIECES); w = w + 1) begin : for_outer2
            for (l = 0; l < xCoordBits; l = l + 1) begin : for_inner2
                assign snakeX[w][l] = packSnakeX[(w * xCoordBits) + l];
            end
        end
    endgenerate

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
 
    always @ (*) begin
        if (vCounter >= vBP && vCounter < vFP) begin
            if (hCounter > hBP && hCounter < (hBP + 640)) begin
                // initialize to empty
                RGB = `COLOR_EMPTY;
                if (yBlockIndex == 0 || yBlockIndex == (`GRID_HEIGHT - 1) || xBlockIndex == 0 || xBlockIndex == (`GRID_WIDTH - 1))
                    RGB = `COLOR_WALL;
                else if (yBlockIndex == foodY && xBlockIndex == foodX)
                    RGB = `COLOR_FOOD;
                else begin
                    for (i = 0; i < numSnakePieces; i = i + 1) begin
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
