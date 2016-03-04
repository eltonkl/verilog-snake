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
    
    reg [`BITS_PER_BLOCK-1:0] blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
    reg [`BITS_PER_DIR-1:0] snakeDir [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
    reg [$clog2(`GRID_HEIGHT)-1:0] snakeHeadV; // y-coordinate
    reg [$clog2(`GRID_WIDTH)-1:0] snakeHeadH;  // x-coordinate
    reg [$clog2(`GRID_HEIGHT)-1:0] snakeTailV;
    reg [$clog2(`GRID_WIDTH)-1:0]snakeTailH;
    reg [`BITS_PER_DIR-1:0] snakeHeadDir;
    reg [`BITS_PER_DIR-1:0] snakeTailDir;
    
    // food pointers
    //reg [$clog2(`GRID_HEIGHT)-1:0] curFoodV;    // coordinates for current food
    //reg [$clog2(`GRID_WIDTH)-1:0] curFoodH;
    //reg [$clog2(`GRID_HEIGHT)-1:0] nextFoodV;   // the real values we are using (for next food)
    //reg [$clog2(`GRID_WIDTH)-1:0] nextFoodH;    // we only update this (from values of p) when we need to
    //wire [$clog2(`GRID_HEIGHT)-1:0] pNextFoodV;  // value we get from FoodRandomizer
    //wire [$clog2(`GRID_WIDTH)-1:0] pNextFoodH;
    
    // game states
    reg pauseEnable;
    reg gameOver;
    reg [$clog2(`GRID_HEIGHT*`GRID_WIDTH)-1:0] score;
    
    // seg control
    reg segEnable;
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
    reg [2:0] buttonPressed;
    
    wire gameClock;
    wire clock;
    wire fastClock;
    //wire clk;

    wire [0:(`BITS_PER_BLOCK * `GRID_HEIGHT * `GRID_WIDTH)-1] packBlocks;
    genvar h, w;
    generate
        for (h = 0; h < (`GRID_HEIGHT); h = h + 1) begin : for_outer
            for (w = 0; w < (`GRID_WIDTH); w = w + 1) begin : for_inner
                assign packBlocks[(h * `GRID_WIDTH * `BITS_PER_BLOCK) + (w * `BITS_PER_BLOCK)] = blocks[h][w][0];
                assign packBlocks[(h * `GRID_WIDTH * `BITS_PER_BLOCK) + (w * `BITS_PER_BLOCK) + 1] = blocks[h][w][1];
            end
        end
    endgenerate

    initial begin
        highFirstDigit = 0;
        highSecondDigit = 0;
        highThirdDigit = 0;
        highFourthDigit = 0;
        buttonPressed = `BTN_NONE;

        for (i = 0; i < `GRID_WIDTH; i = i + 1) begin
            blocks[0][i] = `BLOCK_WALL;
            blocks[`GRID_HEIGHT-1][i] = `BLOCK_WALL;
        end
        for (i = 1; i < `GRID_HEIGHT - 1; i = i + 1) begin
            blocks[i][0] = `BLOCK_WALL;
            blocks[i][`GRID_WIDTH-1] = `BLOCK_WALL;
        end

        initializeGame();
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

    VGAController vgaC(
        .Blocks(packBlocks),
        .Clock(clock),
        .RGB(VGArgb),
        .HSync(VGAHSync),
        .VSync(VGAVSync)
    );
    
    FoodRandomizer fr(
        .Blocks(packBlocks),
        .MasterClock(MasterClock),
        .ButtonLeft(ButtonLeft),
        .ButtonRight(ButtonRight),
        .ButtonUp(ButtonUp),
        .ButtonDown(ButtonDown),
        .ButtonCenter(ButtonCenter),
        .NextFoodV(pNextFoodV),
        .NextFoodH(pNextFoodH)
    );
    
    SegController sc(
        .Clock(fastClock),
        .En(segEnable),
        .FirstDigit(firstDigit),
        .SecondDigit(secondDigit),
        .ThirdDigit(thirdDigit),
        .FourthDigit(fourthDigit),
        .A(An),
        .C(Seg)
    );

    always @ (posedge clock) begin
        if (centerPressed) begin
            pauseEnable = ~pauseEnable;
        end

        if (!pauseEnable && !gameOver) begin
            if (gameClock) begin
                moveSnake();
            end

            else if (leftPressed) begin
                
            end
            else if (rightPressed) begin
                
            end
            else if (downPressed) begin
                
            end
            else if (upPressed) begin
                
            end
        end
        else if (gameOver) begin
            // Display high score
            if (centerPressed) begin
                initializeGame();
            end
        end
        else begin
            // Game paused
        end
    end

    task moveSnake; begin
        snakeHeadDir = snakeDir[snakeHeadV][snakeHeadH];
        case (snakeHeadDir)
            `DIR_UP: begin
                snakeHeadV = snakeHeadV - 1'b1;
            end
            `DIR_DOWN: begin
                snakeHeadV = snakeHeadV + 1'b1;
            end
            `DIR_LEFT: begin
                snakeHeadH = snakeHeadH - 1'b1;
            end
            `DIR_RIGHT: begin
                snakeHeadH = snakeHeadH + 1'b1;
            end
        endcase
        if (blocks[snakeHeadV][snakeHeadH] == `BLOCK_WALL ||
            blocks[snakeHeadV][snakeHeadH] == `BLOCK_SNAKE) begin
            gameOver = 1;
        end
        else begin
            if (blocks[snakeHeadV][snakeHeadH] != `BLOCK_FOOD) begin
                snakeTailDir = snakeDir[snakeTailV][snakeTailH];
                blocks[snakeTailV][snakeTailH] = `BLOCK_EMPTY;
                case (snakeTailDir)
                    `DIR_UP: begin
                        snakeTailV = snakeTailV - 1'b1;
                    end
                    `DIR_DOWN: begin
                        snakeTailV = snakeTailV + 1'b1;
                    end
                    `DIR_LEFT: begin
                        snakeTailH = snakeTailH - 1'b1;
                    end
                    `DIR_RIGHT: begin
                        snakeTailH = snakeTailH + 1'b1;
                    end
                endcase
            end
            else begin
                incrementScore();
            end
            blocks[snakeHeadV][snakeHeadH] = `BLOCK_SNAKE;
            snakeDir[snakeHeadV][snakeHeadH] = snakeHeadDir;
        end
    end
    endtask

    task incrementScore; begin
        fourthDigit = fourthDigit + 1'b1;
        if (fourthDigit == 10) begin
            fourthDigit = 0;
            thirdDigit = thirdDigit + 1'b1;
            if (thirdDigit == 10) begin
                thirdDigit = 0;
                secondDigit = secondDigit + 1'b1;
                if (secondDigit == 10) begin
                    secondDigit = 0;
                    firstDigit = firstDigit + 1'b1;
                end
            end
        end
        
        if (firstDigit > highFirstDigit) begin
            highFirstDigit = firstDigit;
            highSecondDigit = secondDigit;
            highThirdDigit = thirdDigit;
            highFourthDigit = fourthDigit;
        end
        else if (firstDigit == highFirstDigit) begin
            if (secondDigit > highSecondDigit) begin
                highSecondDigit = secondDigit;
                highThirdDigit = thirdDigit;
                highFourthDigit = fourthDigit;
            end
            else if (secondDigit == highSecondDigit) begin
                if (thirdDigit > highThirdDigit) begin
                    highThirdDigit = thirdDigit;
                    highFourthDigit = fourthDigit;
                end
                else if (thirdDigit == highThirdDigit) begin
                    if (fourthDigit > highFourthDigit) begin
                        highFourthDigit = fourthDigit;
                    end
                end
            end
        end
    end
    endtask

    task initializeGame; begin
        pauseEnable = 0;
        gameOver = 0;
        segEnable = 1;
        firstDigit = 0;
        secondDigit = 0;
        thirdDigit = 0;
        fourthDigit = 0;

        for (i = 1; i < `GRID_HEIGHT - 1; i = i + 1) begin
            for (j = 1; j < `GRID_WIDTH - 1; j = j + 1) begin
                blocks[i][j] = `BLOCK_EMPTY;
            end
        end
        
        // initialize snake starting point
        snakeHeadV = 1;
        snakeHeadH = 1;
        snakeTailV = 1;
        snakeTailH = 1;
        snakeDir[snakeHeadV][snakeHeadH] = `DIR_RIGHT;
        blocks[snakeHeadV][snakeHeadH] = `BLOCK_SNAKE;
        
        // initialize food
        blocks[1][9] = `BLOCK_FOOD;
    end
    endtask

//    // setup user control (set the pressed button to reg buttonPressed)
//    always @ (*) begin
//        if (leftPressed == 1) begin
//            buttonPressed <= `BTN_LEFT;
//        end
//        else if (rightPressed == 1) begin
//            buttonPressed <= `BTN_RIGHT;
//        end
//        else if (upPressed == 1) begin
//            buttonPressed <= `BTN_UP;
//        end 
//        else if (downPressed == 1) begin
//            buttonPressed <= `BTN_DOWN;
//        end
//    end
//    
//    always @ (*) begin
//        if (centerPressed == 1) begin
//            pauseEnable <= ~pauseEnable;
//        end
//    end
//    
//    // change snake moving direction based on button pressed
//    /*
//    always @ (posedge debouncerClock) begin
//        case (buttonPressed)
//            `BTN_LEFT: snakeDir[snakeHead_V][snakeHead_H] = `DIR_LEFT;
//            `BTN_RIGHT: snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
//            `BTN_UP: snakeDir[snakeHead_V][snakeHead_H] = `DIR_UP;
//            `BTN_DOWN: snakeDir[snakeHead_V][snakeHead_H] = `DIR_DOWN;
//            `BTN_CENTER: pauseEnable = ~pauseEnable;
//            default: $display ("OOPS");
//        endcase
//    end
//    */
//    
//    // main game playing mechanism
//    //8 snake moving mechanism
//    always @ (posedge gameClock) begin
//        /*
//        if (leftPressed) begin
//            snakeDir[snakeHead_V][snakeHead_H] = `DIR_LEFT;
//        end
//        else if (rightPressed) begin
//            snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
//        end
//        else if (upPressed) begin
//            snakeDir[snakeHead_V][snakeHead_H] = `DIR_UP;
//        end 
//        else if (downPressed) begin
//            snakeDir[snakeHead_V][snakeHead_H] = `DIR_DOWN;
//        end
//        else if (centerPressed) begin
//            pauseEnable = ~pauseEnable;
//        end
//        */
//        //if (gameClock == 1) begin
//        snakeHeadDir = snakeDir[snakeHead_V][snakeHead_H];
//        case (buttonPressed)
//            `BTN_LEFT: begin
//                if (snakeHeadDir != `DIR_RIGHT) begin
//                    snakeDir[snakeHead_V][snakeHead_H] = `DIR_LEFT;
//                end
//                firstDigit = 1;
//            end
//            `BTN_RIGHT: begin
//                if (snakeHeadDir != `DIR_LEFT) begin
//                    snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
//                end
//                firstDigit = 2;
//            end
//            `BTN_UP: begin
//                if (snakeHeadDir != `DIR_DOWN) begin
//                    snakeDir[snakeHead_V][snakeHead_H] = `DIR_UP;
//                end
//                firstDigit = 3;
//            end
//            `BTN_DOWN: begin
//                if (snakeHeadDir != `DIR_UP) begin
//                    snakeDir[snakeHead_V][snakeHead_H] = `DIR_DOWN;
//                end
//                firstDigit = 4;
//            end
//            default: firstDigit = 5;
//        endcase
//
//        if (!gameOver) begin
//            if (!pauseEnable) begin
//                // setup the position of snakeHead pointer
//                snakeHeadDir = snakeDir[snakeHead_V][snakeHead_H];
//                case (snakeHeadDir)
//                    `DIR_UP: begin
//                                snakeDir[snakeHead_V + 1][snakeHead_H] = snakeHeadDir;
//                                snakeHead_V = snakeHead_V + 1'b1;
//                            end
//                    `DIR_DOWN: begin
//                                snakeDir[snakeHead_V - 1][snakeHead_H] = snakeHeadDir;
//                                snakeHead_V = snakeHead_V - 1'b1;
//                            end
//                    `DIR_LEFT: begin
//                                snakeDir[snakeHead_V][snakeHead_H - 1] = snakeHeadDir;
//                                snakeHead_H = snakeHead_H - 1'b1;
//                            end
//                    `DIR_RIGHT: begin
//                                snakeDir[snakeHead_V][snakeHead_H + 1] = snakeHeadDir;
//                                snakeHead_H = snakeHead_H + 1'b1;
//                            end
//                    default: $display ("OOPS");
//                endcase
//            
//                // check if the will be head coordinate is the same as food coordinate
//                if (blocks[snakeHead_V][snakeHead_H] == `BLOCK_FOOD) begin
//                    // food is eaten
//                    blocks[snakeHead_V][snakeHead_H] = `BLOCK_SNAKE;
//                    
//                    //blocks[nextFoodV][nextFoodH] <= `BLOCK_FOOD;
//                    //nextFoodV <= pNextFoodV;
//                    //nextFoodH <= pNextFoodH;
//                    score = score + 1'b1;
//                    /*fourthDigit = fourthDigit + 1'b1;
//                    if (fourthDigit == 10) begin
//                        fourthDigit = 0;
//                        thirdDigit = thirdDigit + 1'b1;
//                        if (thirdDigit == 10) begin
//                            thirdDigit = 0;
//                            secondDigit = secondDigit + 1'b1;
//                            if (secondDigit == 10) begin
//                                secondDigit = 0;
//                                firstDigit = firstDigit + 1'b1;
//                            end
//                        end
//                    end*/
//                    
//                    
//                end else begin
//                    // food is not eaten
//                    // setup the position of snakeTail pointer
//                    // first empty out the tail's block
//                    blocks[snakeTail_V][snakeTail_H] = `BLOCK_EMPTY;
//                    case (snakeDir[snakeTail_V][snakeTail_H])
//                        `DIR_UP: begin
//                                    snakeTail_V = snakeTail_V + 1'b1;
//                                end
//                        `DIR_DOWN: begin
//                                    snakeTail_V = snakeTail_V - 1'b1;
//                                end
//                        `DIR_LEFT: begin
//                                    snakeTail_H = snakeTail_H - 1'b1;
//                                end
//                        `DIR_RIGHT: begin
//                                    snakeTail_H = snakeTail_H + 1'b1;
//                                end
//                        default: $display ("OOPS");
//                    endcase
//            
//                    // check and kill snake
//                    if (blocks[snakeHead_V][snakeHead_H] != `BLOCK_EMPTY) begin
//                        // because we already checked food, if it's not empty, it's either SNAKE or WALL
//                        gameOver = 1;
//                    end else begin
//                        blocks[snakeHead_V][snakeHead_H] = `BLOCK_SNAKE;
//                        //snakeDir[snakeHead_V][snakeHead_H] = snakeHeadDir;  // set the new head's dir to the previous head dir
//                
//                        // because snake moves, we need to make sure next food coordinate is still valid
//                        if (blocks[nextFoodV][nextFoodH] == `BLOCK_SNAKE) begin
//                            nextFoodV = pNextFoodV;
//                            nextFoodH = pNextFoodH;
//                        end
//                    end
//                end // end food checking if statement
//            end // end pauseEnable if statement
//        end else begin
//            // game over bruh!
//            
//        end
//    end
    

endmodule
