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
    parameter numSnakePieces = `NUM_SNAKE_PIECES;
    parameter numPiecesBits = $clog2(numSnakePieces);
    
    //reg [`BITS_PER_BLOCK-1:0] blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
    
    reg [`BITS_PER_STATE-1:0] currentState;
    reg [yCoordBits-1:0] snakeY [0:numSnakePieces-1]; // y-coordinate
    reg [xCoordBits-1:0] snakeX [0:numSnakePieces-1];  // x-coordinate
    reg [yCoordBits-1:0] newHeadY;
    reg [xCoordBits-1:0] newHeadX;
    reg [numPiecesBits-1:0] snakeTail;
    reg [`BITS_PER_DIR-1:0] currentDir;
    reg collidesWithFood;

    parameter deadTicks = 12500000;
    parameter segCurrentScore = 1'b0;
    parameter segHighScore = 1'b1;
    reg [23:0] deadCounter;
    reg segType;

    reg [yCoordBits-1:0] foodY;
    reg [xCoordBits-1:0] foodX;

    // seg control
    reg [3:0] segFirstDigit;
    reg [3:0] segSecondDigit;
    reg [3:0] segThirdDigit;
    reg [3:0] segFourthDigit;
    
    reg [3:0] firstDigit;
    reg [3:0] secondDigit;
    reg [3:0] thirdDigit;
    reg [3:0] fourthDigit;
    
    reg [3:0] highFirstDigit;
    reg [3:0] highSecondDigit;
    reg [3:0] highThirdDigit;
    reg [3:0] highFourthDigit;
    
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

    // pack snakeY
    wire [0:(yCoordBits * `NUM_SNAKE_PIECES)-1] packSnakeY;
    genvar h, k;
    generate
        for (h = 0; h < (`NUM_SNAKE_PIECES); h = h + 1) begin : for_outer
            for (k = 0; k < yCoordBits; k = k + 1) begin : for_inner
                assign packSnakeY[(h * yCoordBits) + k] = snakeY[h][k];
            end
        end
    endgenerate
    
    // pack snakeX
    wire [0:(xCoordBits * `NUM_SNAKE_PIECES)-1] packSnakeX;
    genvar w, l;
    generate
        for (w = 0; w < (`NUM_SNAKE_PIECES); w = w + 1) begin : for_outer2
            for (l = 0; l < xCoordBits; l = l + 1) begin : for_inner2
                assign packSnakeX[(w * xCoordBits) + l] = snakeX[w][l];
            end
        end
    endgenerate

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

    VGAController vgaC(
        .packSnakeY(packSnakeY),
        .packSnakeX(packSnakeX),
        .foodY(foodY),
        .foodX(foodX),
        .Clock(clock),
        .RGB(VGArgb),
        .HSync(VGAHSync),
        .VSync(VGAVSync)
    );

    initial begin
        firstDigit = 0;
        secondDigit = 0;
        thirdDigit = 0;
        fourthDigit = 0;
        
        highFirstDigit = 0;
        highSecondDigit = 0;
        highThirdDigit = 0;
        highFourthDigit = 0;
        
        deadCounter = 0;
        
        for (i = 1; i < numSnakePieces; i = i + 1) begin
            snakeY[i] = 0;
            snakeX[i] = 0;
        end
        snakeTail = 0;
        snakeY[0] = 5;
        snakeX[0] = 5;
        
        foodY = 5;
        foodX = 10;
        
        currentDir = `DIR_RIGHT;
        currentState = `STATE_DEAD;
        collidesWithFood = 0;
        segType = segCurrentScore;
    end

    always @ (*) begin
        if (segType == segHighScore) begin
            segFirstDigit <= highFirstDigit;
            segSecondDigit <= highSecondDigit;
            segThirdDigit <= highThirdDigit;
            segFourthDigit <= highFourthDigit;
        end
        else begin
            segFirstDigit <= firstDigit;
            segSecondDigit <= secondDigit;
            segThirdDigit <= thirdDigit;
            segFourthDigit <= fourthDigit;
        end
    end

    always @ (posedge clock) begin
        if (currentState == `STATE_DEAD) begin
            if (centerPressed == 1) begin
                currentState = `STATE_ALIVE;

                firstDigit = 0;
                secondDigit = 0;
                thirdDigit = 0;
                fourthDigit = 0;

                for (i = 1; i < numSnakePieces; i = i + 1) begin
                    snakeY[i] = 0;
                    snakeX[i] = 0;
                end
                snakeTail = 0;
                snakeY[0] = 5;
                snakeX[0] = 5;
                
                foodY = 5;
                foodX = 10;
                
                currentDir = `DIR_RIGHT;
                collidesWithFood = 0;
                segType = segCurrentScore;
            end
            else begin
                if (deadCounter + 1 == deadTicks) begin
                    deadCounter = 0;
                    segType = ~segType;
                end
                else begin
                    deadCounter = deadCounter + 1;
                end
            end
        end
        else if (currentState == `STATE_PAUSE) begin
            if (centerPressed == 1) begin
                currentState = `STATE_ALIVE;
            end
        end
        else if (currentState == `STATE_FIND_FOOD) begin
            foodX = 3;
            foodY = 9;
            currentState = `STATE_ALIVE;
        end
        else begin
            if (centerPressed == 1) begin
                currentState = `STATE_PAUSE;
            end
            else if (leftPressed == 1) begin
                if (currentDir != `DIR_RIGHT)
                    currentDir = `DIR_LEFT;
            end
            else if (rightPressed == 1) begin
                if (currentDir != `DIR_LEFT)
                    currentDir = `DIR_RIGHT;
            end
            else if (upPressed == 1) begin
                if (currentDir != `DIR_DOWN)
                    currentDir = `DIR_UP;
            end
            else if (downPressed == 1) begin
                if (currentDir != `DIR_UP)
                    currentDir = `DIR_DOWN;
            end
            
            if (gameClock == 1) begin
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
                
                for (i = numSnakePieces - 1; i > 0; i = i - 1) begin
                    snakeY[i] = snakeY[i - 1]; 
                    snakeX[i] = snakeX[i - 1];
                end
                snakeY[0] = newHeadY;
                snakeX[0] = newHeadX;
                if (newHeadY == foodY && newHeadX == foodX) begin
                    if (snakeTail != numSnakePieces - 1) begin
                        snakeTail = snakeTail + 1;
                    end
                    foodY = 0;
                    foodX = 0;
                    currentState = `STATE_FIND_FOOD;
                end
                else if (newHeadY == 0 || newHeadY == `GRID_HEIGHT - 1 ||
                         newHeadX == 0 || newHeadX == `GRID_WIDTH - 1) begin
                    // End game
                    currentState = `STATE_DEAD;
                end
                else begin
                    if (snakeTail != numSnakePieces - 1) begin
                        // Food wasn't picked up, so zero out the tail
                        snakeY[snakeTail + 1] = 0;
                        snakeX[snakeTail + 1] = 0;
                    end
                end
                
            end
        end
    end
    
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
//        .En(1),
//        .FirstDigit(segFirstDigit),
//        .SecondDigit(segSecondDigit),
//        .ThirdDigit(segThirdDigit),
//        .FourthDigit(segFourthDigit),
//        .A(An),
//        .C(Seg)
//    );

endmodule
