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
    reg [$clog2(`GRID_HEIGHT)-1:0] snakeHead_V; // y-coordinate
    reg [$clog2(`GRID_WIDTH)-1:0] snakeHead_H;  // x-coordinate
    reg [$clog2(`GRID_HEIGHT)-1:0] snakeTail_V;
    reg [$clog2(`GRID_WIDTH)-1:0]snakeTail_H;
    reg [`BITS_PER_DIR-1:0] snakeHeadDir;
    
    // food pointers
    //reg [$clog2(`GRID_HEIGHT)-1:0] curFoodV;    // coordinates for current food
    //reg [$clog2(`GRID_WIDTH)-1:0] curFoodH;
    reg [$clog2(`GRID_HEIGHT)-1:0] nextFoodV;   // the real values we are using (for next food)
    reg [$clog2(`GRID_WIDTH)-1:0] nextFoodH;    // we only update this (from values of p) when we need to
    wire [$clog2(`GRID_HEIGHT)-1:0] pNextFoodV;  // value we get from FoodRandomizer
    wire [$clog2(`GRID_WIDTH)-1:0] pNextFoodH;
    
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
    wire debouncerClock;
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
        pauseEnable = 0;    // not pause
        gameOver = 0;       // game not over
        score = 0;          // score starts from 0
        segEnable = 1;
        firstDigit = 0;
        secondDigit = 0;
        thirdDigit = 0;
        fourthDigit = 0;
        buttonPressed = `BTN_NONE;

        for (i = 0; i < `GRID_HEIGHT; i = i + 1) begin
            for (j = 0; j < `GRID_WIDTH; j = j + 1) begin
                blocks[i][j] = `BLOCK_EMPTY;
            end
        end
        for (i = 0; i < `GRID_WIDTH; i = i + 1) begin
            blocks[0][i] = `BLOCK_WALL;
            blocks[`GRID_HEIGHT-1][i] = `BLOCK_WALL;
        end
        for (i = 1; i < `GRID_HEIGHT - 1; i = i + 1) begin
            blocks[i][0] = `BLOCK_WALL;
            blocks[i][`GRID_WIDTH-1] = `BLOCK_WALL;
        end
        
        // initialize snake starting point
        snakeHead_V = 1;
        snakeHead_H = 1;
        snakeTail_V = 1;
        snakeTail_H = 1;
        snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
        blocks[snakeHead_V][snakeHead_H] = `BLOCK_SNAKE;
        
        // initialize food
        //curFoodV = 30;
        //curFoodH = 30;
        blocks[1][9] = `BLOCK_FOOD;
    end

    ClockDivider cd(
        .MasterClock(MasterClock),
        .Clock(debouncerClock),
        .gameClock(gameClock),
        .fastClock(fastClock)
    );

    Debouncer btnL(
        .Clock(debouncerClock),
        .Signal(ButtonLeft),
        .Enabled(leftPressed)
    );

    Debouncer btnR(
        .Clock(debouncerClock),
        .Signal(ButtonRight),
        .Enabled(rightPressed)
    );
    
    Debouncer btnU(
        .Clock(debouncerClock),
        .Signal(ButtonUp),
        .Enabled(upPressed)
    );
    
    Debouncer btnD(
        .Clock(debouncerClock),
        .Signal(ButtonDown),
        .Enabled(downPressed)
    );
    
    Debouncer btnC(
        .Clock(debouncerClock),
        .Signal(ButtonCenter),
        .Enabled(centerPressed)
    );

    VGAController vgaC(
        .Blocks(packBlocks),
        .Clock(debouncerClock),
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
    
    // setup user control (set the pressed button to reg buttonPressed)
    always @ (posedge debouncerClock) begin
        if (leftPressed) begin
            buttonPressed = `BTN_LEFT;
        end
        
        if (rightPressed) begin
            buttonPressed = `BTN_RIGHT;
        end
    
        if (upPressed) begin
            buttonPressed = `BTN_UP;
        end
        
        if (downPressed) begin
            buttonPressed = `BTN_DOWN;
        end
        
        if (centerPressed) begin
            buttonPressed = `BTN_CENTER;
        end
    end
    
    // change snake moving direction based on button pressed
    /*
    always @ (posedge debouncerClock) begin
        case (buttonPressed)
            `BTN_LEFT: snakeDir[snakeHead_V][snakeHead_H] = `DIR_LEFT;
            `BTN_RIGHT: snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
            `BTN_UP: snakeDir[snakeHead_V][snakeHead_H] = `DIR_UP;
            `BTN_DOWN: snakeDir[snakeHead_V][snakeHead_H] = `DIR_DOWN;
            `BTN_CENTER: pauseEnable = ~pauseEnable;
            default: $display ("OOPS");
        endcase
    end
    */
    
    // main game playing mechanism
    // snake moving mechanism
    always @ (posedge gameClock) begin
        /*
        case (buttonPressed)
            `BTN_LEFT: snakeDir[snakeHead_V][snakeHead_H] = `DIR_LEFT;
            `BTN_RIGHT: snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
            `BTN_UP: snakeDir[snakeHead_V][snakeHead_H] = `DIR_UP;
            `BTN_DOWN: snakeDir[snakeHead_V][snakeHead_H] = `DIR_DOWN;
            `BTN_CENTER: pauseEnable = ~pauseEnable;
            default: $display ("OOPS");
        endcase
        buttonPressed = `BTN_NONE;
        */
        if (!gameOver) begin
            if (!pauseEnable) begin
                // setup the position of snakeHead pointer
                //snakeHeadDir <= snakeDir[snakeHead_V][snakeHead_H];
                case (snakeDir[snakeHead_V][snakeHead_H])
                    `DIR_UP: begin
                                snakeHead_V <= snakeHead_V + 1'b1;
                                blocks[snakeHead_V + 1'b1][snakeHead_H] <= `BLOCK_SNAKE;
                                snakeDir[snakeHead_V + 1'b1][snakeHead_H] <= snakeDir[snakeHead_V][snakeHead_H];
                            end
                    `DIR_DOWN: begin
                                snakeHead_V <= snakeHead_V - 1'b1;
                                blocks[snakeHead_V - 1'b1][snakeHead_H] <= `BLOCK_SNAKE;
                                snakeDir[snakeHead_V + 1'b1][snakeHead_H] <= snakeDir[snakeHead_V][snakeHead_H];
                            end
                    `DIR_LEFT: begin
                                snakeHead_H <= snakeHead_H - 1'b1;
                                blocks[snakeHead_V][snakeHead_H - 1'b1] <= `BLOCK_SNAKE;
                                snakeDir[snakeHead_V][snakeHead_H - 1'b1] <= snakeDir[snakeHead_V][snakeHead_H];
                            end
                    `DIR_RIGHT: begin
                                snakeHead_H <= snakeHead_H + 1'b1;
                                blocks[snakeHead_V][snakeHead_H + 1'b1] <= `BLOCK_SNAKE;
                                snakeDir[snakeHead_V][snakeHead_H + 1'b1] <= snakeDir[snakeHead_V][snakeHead_H];
                            end
                    default: $display ("OOPS");
                endcase
            
                // check if the will be head coordinate is the same as food coordinate
                if (blocks[snakeHead_V][snakeHead_H] == `BLOCK_FOOD) begin
                    // food is eaten
                    blocks[snakeHead_V][snakeHead_H] <= `BLOCK_SNAKE;
                    
                    /*
                    blocks[nextFoodV][nextFoodH] <= `BLOCK_FOOD;
                    nextFoodV <= pNextFoodV;
                    nextFoodH <= pNextFoodH;
                    score <= score + 1'b1;
                    firstDigit <= firstDigit + 1'b1;
                    if (firstDigit == 10) begin
                        firstDigit <= 0;
                        secondDigit <= secondDigit + 1'b1;
                        if (secondDigit == 10) begin
                            secondDigit <= 0;
                            thirdDigit <= thirdDigit + 1'b1;
                            if (thirdDigit == 10) begin
                                thirdDigit <= 0;
                                fourthDigit <= fourthDigit + 1'b1;
                            end
                        end
                    end
                    */
                    
                end else begin
                    // food is not eaten
                    // setup the position of snakeTail pointer
                    // first empty out the tail's block
                    //blocks[snakeTail_V][snakeTail_H] <= `BLOCK_EMPTY;
                    case (snakeDir[snakeTail_V][snakeTail_H])
                        `DIR_UP: begin
                                    snakeTail_V <= snakeTail_V + 1'b1;
                                    blocks[snakeTail_V + 1'b1][snakeTail_H] <= `BLOCK_EMPTY;
                                end
                        `DIR_DOWN: begin
                                    snakeTail_V <= snakeTail_V - 1'b1;
                                    blocks[snakeTail_V - 1'b1][snakeTail_H] <= `BLOCK_EMPTY;
                                end
                        `DIR_LEFT: begin
                                    snakeTail_H <= snakeTail_H - 1'b1;
                                    blocks[snakeTail_V][snakeTail_H - 1'b1] <= `BLOCK_EMPTY;
                                end
                        `DIR_RIGHT: begin
                                    snakeTail_H <= snakeTail_H + 1'b1;
                                    blocks[snakeTail_V][snakeTail_H + 1'b1] <= `BLOCK_EMPTY;
                                end
                        default: $display ("OOPS");
                    endcase
            
                    // check and kill snake
                    if (blocks[snakeHead_V][snakeHead_H] != `BLOCK_EMPTY) begin
                        // because we already checked food, if it's not empty, it's either SNAKE or WALL
                        gameOver = 1;
                    end else begin
                        //blocks[snakeHead_V][snakeHead_H] <= `BLOCK_SNAKE;
                        snakeDir[snakeHead_V][snakeHead_H] <= snakeHeadDir;  // set the new head's dir to the previous head dir
                
                        // because snake moves, we need to make sure next food coordinate is still valid
                        if (blocks[nextFoodV][nextFoodH] == `BLOCK_SNAKE) begin
                            nextFoodV <= pNextFoodV;
                            nextFoodH <= pNextFoodH;
                        end
                    end
                end // end food checking if statement
            end // end pauseEnable if statement
        end else begin
            // game over bruh!
            
        end
    end
    

endmodule
