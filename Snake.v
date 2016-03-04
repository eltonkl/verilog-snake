`include "Constants.v"

module Snake(
    input wire          MasterClock,
    input wire          ButtonLeft,
    input wire          ButtonRight,
    input wire          ButtonUp,
    input wire          ButtonDown,
    input wire          ButtonCenter,
    output wire [0:7]   VGArgb,
    output wire         VGAHSync,
    output wire         VGAVSync,
    output wire [6:0]   Seg,
    output wire [3:0]   An
    );
    
    parameter yCoordBits = $clog2(`GRID_HEIGHT);
    parameter xCoordBits = $clog2(`GRID_WIDTH);
    parameter numSnakePieces = 4;
    parameter numPiecesBits = $clog2(numSnakePieces);
    
    //reg [`BITS_PER_BLOCK-1:0] blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
    
    reg [bitsPerState-1:0] currentState;
    reg [yCoordBits-1:0] snakeY [0:numSnakePieces-1]; // y-coordinate
    reg [xCoordBits-1:0] snakeX [0:numSnakePieces-1];  // x-coordinate
    reg [yCoordBits-1:0] newHeadY;
    reg [xCoordBits-1:0] newHeadX;
    reg [numPiecesBits-1:0] snakeTail;
    reg [`BITS_PER_DIR-1:0] currentDir;
    reg collidesWithFood;

    reg [yCoordBits-1:0] foodY;
    reg [xCoordBits-1:0] foodX;

    // seg control
    reg segEnable;
    reg [3:0] firstDigit;
    reg [3:0] secondDigit;
    reg [3:0] thirdDigit;
    reg [3:0] fourthDigit;
    
    // other utilities
    reg [4:0] i;
    reg [4:0] j;
    
    wire leftPressed;
    wire rightPressed;
    wire upPressed;
    wire downPressed;
    wire centerPressed;
    
    wire gameClock;
    wire clock;
    wire fastClock;

    initial begin
        for (i = 1; i < numSnakePieces; i = i + 1) begin
            snakeY[i] = 0;
            snakeX[i] = 0;
        end
        snakeTail = 0;
        snakeY[0] = 1;
        snakeX[0] = 1;
        currentDir = `DIR_RIGHT;
        currentState = `STATE_DEAD;
        collidesWithFood = 0;

        firstDigit = 0;
        secondDigit = 0;
        thirdDigit = 0;
        fourthDigit = 0;
    end

    always @ (posedge clock) begin
        if (currentState == `STATE_DEAD) begin
            if (centerPressed) begin
            end
        end
        else if (currentState == `STATE_PAUSE) begin
            if (centerPressed) begin
            end
        end
        else begin
            case (currentDir)
                `DIR_UP: begin
                    newHeadY = snakeY[0] - 1'b1;
                    newHeadX = snakeX[0];
                end
                `DIR_DOWN: begin
                    newHeadY = snakeY[0] + 1'b1;
                    newHeadX = snakeX[0];
                end
                `DIR_LEFT: begin
                    newHeadY = snakeY[0];
                    newHeadX = snakeX[0] - 1'b1;
                end
                `DIR_RIGHT: begin
                    newHeadY = snakeY[0];
                    newHeadX = snakeX[0] + 1'b1;
                end
            endcase
            if (newHeadY == foodY && newHeadX == foodX) begin
                for (i = numSnakePieces - 1; i > 1; i = i - 1) begin
                    snakeY[i] = snakeY[i - 1];
                end
                snakeY[0] = newHeadY;
                snakeX[0] = newHeadX;
                // Reset foodY
                // Reset foodX
            end
        end
    end

    ClockDivider cd(
        .MasterClock(MasterClock),
        .Clock(clock),
        .gameClock(gameClock),
        .fastClock(fastClock)
    );

    Debouncer btnL(
        .Clock(clock),
        .Signal(ButtonLeft),
        .Enabled(leftPressed)
    );

    Debouncer btnR(
        .Clock(clock),
        .Signal(ButtonRight),
        .Enabled(rightPressed)
    );
    
    Debouncer btnU(
        .Clock(clock),
        .Signal(ButtonUp),
        .Enabled(upPressed)
    );
    
    Debouncer btnD(
        .Clock(clock),
        .Signal(ButtonDown),
        .Enabled(downPressed)
    );
    
    Debouncer btnC(
        .Clock(clock),
        .Signal(ButtonCenter),
        .Enabled(centerPressed)
    );

//    VGAController vgaC(
//        .Blocks(packBlocks),
//        .Clock(clock),
//        .RGB(VGArgb),
//        .HSync(VGAHSync),
//        .VSync(VGAVSync)
//    );
    
//    FoodRandomizer fr(
//        .Blocks(packBlocks),
//        .MasterClock(MasterClock),
//        .ButtonLeft(ButtonLeft),
//        .ButtonRight(ButtonRight),
//        .ButtonUp(ButtonUp),
//        .ButtonDown(ButtonDown),
//        .ButtonCenter(ButtonCenter),
//        .NextFoodV(pNextFoodV),
//        .NextFoodH(pNextFoodH)
//    );
    
//    SegController sc(
//        .Clock(fastClock),
//        .En(segEnable),
//        .FirstDigit(firstDigit),
//        .SecondDigit(secondDigit),
//        .ThirdDigit(thirdDigit),
//        .FourthDigit(fourthDigit),
//        .A(An),
//        .C(Seg)
//    );

endmodule
