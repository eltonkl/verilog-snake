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
    reg snakeHead_V [0:$clog2(`GRID_HEIGHT)-1]; // y-coordinate
    reg snakeHead_H [0:$clog2(`GRID_WIDTH)-1];  // x-coordinate
    reg snakeTail_V [0:$clog2(`GRID_HEIGHT)-1];
    reg snakeTail_H [0:$clog2(`GRID_WIDTH)-1];
    reg food_V [0:`GRID_HEIGHT-1];
    reg food_H [0:`GRID_WIDTH-1];
    reg snakeHeadDir [BITS_PER_DIR];
    reg leftPressed;
    reg rightPressed;
    reg upPressed;
    reg downPressed;
    reg centerPressed;
    reg buttonPressed[2:0];
    
    reg gameClock;

    wire clk;

    initial begin
        // set the button pressed signals to 0 (not enable)
        leftPressed = 0;
        rightPressed = 0;
        upPressed = 0;
        downPressed = 0;
        centerPressed = 0;

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
        snakeHead_V = 20;
        snakeHead_H = 20;
        snakeTail_V = 20;
        snakeTail_H = 20;
        snakeDir[snakeHead_V][snakeHead_H] = `DIR_RIGHT;
        blocks[snakeHead_V][snakeHead_H] = `BLOCK_SNAKE;
    end

    ClockDivider cd(
        .MasterClock(MasterClock),
        .Clock(clk),
        .gameClock(gameClock)
    );

    Debouncer btnL(
        .Clock(clk),
        .Signal(ButtonLeft),
        .Enabled(leftPressed)
    );

    Debouncer btnR(
        .Clock(clk),
        .Signal(ButtonRight),
        .Enabled(rightPressed)
    );
    
    Debouncer btnU(
        .Clock(clk),
        .Signal(ButtonUp),
        .Enabled(upPressed)
    );
    
    Debouncer btnD(
        .Clock(clk),
        .Signal(ButtonDown),
        .Enabled(downPressed)
    );
    
    Debouncer btnC(
        .Clock(clk),
        .Signal(ButtonCenter),
        .Enabled(centerPressed)
    );

    VGAController(
        .Blocks(blocks),
        .Clock(clk),
        .RGB(VGArgb),
        .HSync(VGAHSync),
        .VSync(VGAVSync)
    );
    
    // snake moving mechanism
    always @ (posedge gameClock) begin
        // setup the position of snakeHead pointer
        snakeHeadDir = snakeDir[snakeHead_V][snakeHead_H];
        case (snakeHeadDir)
            DIR_UP: begin
                        snakeHead_V = snakeHead_V + 1;
                    end
            DIR_DOWN: begin
                        snakeHead_V = snakeHead_V - 1;
                    end
            DIR_LEFT: begin
                        snakeHead_H = snakeHead_H - 1;
                    end
            DIR_RIGHT: begin
                        snakeHead_H = snakeHead_H + 1;
                    end
            default: $display ("OOPS");
        endcase
        
        // setup the position of snakeTail pointer
        case (snakeDir[snakeTail_V][snakeTail_H])
            DIR_UP: begin
                        snakeTail_V = snakeTail_V + 1;
                    end
            DIR_DOWN: begin
                        snakeTail_V = snakeTail_V - 1;
                    end
            DIR_LEFT: begin
                        snakeTail_H = snakeTail_H - 1;
                    end
            DIR_RIGHT: begin
                        snakeTail_H = snakeTail_H + 1;
                    end
            default: $display ("OOPS");
        endcase
        
        blocks[snakeHead_V][snakeHead_H] = `BLOCK_SNAKE;
        blocks[snakeTail_V][snakeTail_H] = `BLOCK_EMPTY;
        snakeDir[snakeHead_V][snakeHead_H] = snakeHeadDir;  // set the new head's dir to the previous head dir
    end

endmodule
