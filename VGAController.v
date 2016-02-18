`include "Constants.v"

module VGAController(
    input [`BITS_PER_BLOCK-1:0]     Blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1],
    input                           Clock,
    output reg [0:7]                RGB,
    output                          HSync,
    output                          VSync
    );

    parameter hPeriod = `H_FRONT_PORCH + `H_SYNC_PULSE + `H_BACK_PORCH + `H_PIXELS;
    parameter vPeriod = `V_FRONT_PORCH + `V_SYNC_PULSE + `V_BACK_PORCH + `V_PIXELS;
    parameter hPositive = 0;
    parameter vPositive = 0;

    reg [9:0] hCounter;
    reg [8:0] vCounter;
    wire [3:0] xBlockIndex = hCounter/`BLOCK_WIDTH;
    wire [3:0] yBlockIndex = vCounter/`BLOCK_HEIGHT;

    initial begin
        hCounter = 0;
        vCounter = 0;
    end

    always @ (posedge Clock) begin
        if (hCounter >= hPeriod - 1) begin
            hCounter <= 0;
        end
        else begin
            hCounter <= hCounter + 1;
        end

        if (vCounter >= vPeriod - 1) begin
            vCounter <= 0;
        end
        else begin
            vCounter <= vCounter + 1;
        end

        if (hCounter < `H_PIXELS + `H_FRONT_PORCH || hCounter > `H_PIXELS + `H_FRONT_PORCH + `H_SYNC_PULSE) begin
            HSync <= ~hPositive;
        end
        else begin
            hSync <= hPositive;
        end

        if (vCounter < `V_PIXELS + `V_FRONT_PORCH || vCounter > `V_PIXELS + `V_FRONT_PORCH + `V_SYNC_PULSE) begin
            VSync <= ~VPositive;
        end
        else begin
            VSync <= VPositive;
        end
    end

    always @ (*) begin
        case (Blocks[yBlockIndex][xBlockIndex])
            `BLOCK_EMPTY:   RGB = `COLOR_EMPTY;
            `BLOCK_SNAKE:   RGB = `COLOR_SNAKE;
            `BLOCK_FOOD:    RGB = `COLOR_FOOD;
            `BLOCK_WALL:    RGB = `COLOR_WALL;
        endcase
    end

endmodule
