`include "Constants.v"

module VGAController(
    output reg [0:2]                Red,
    output reg [0:2]                Green,
    output reg [0:1]                Blue,
    output                          HSync,
    output                          VSync,
    input [`BITS_PER_BLOCK-1:0]     Blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1]
    );


endmodule
