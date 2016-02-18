`define H_PIXELS        640
`define H_FRONT_PORCH   16
`define H_SYNC_PULSE    96
`define H_BACK_PORCH    48

`define V_PIXELS        480
`define V_FRONT_PORCH   10
`define V_SYNC_PULSE    2
`define V_BACK_PORCH    33

`define BITS_PER_BLOCK  2
`define BLOCK_EMPTY     2'b00
`define BLOCK_SNAKE     2'b01
`define BLOCK_FOOD      2'b10
`define BLOCK_WALL      2'b11

`define BITS_PER_DIR    2
`define DIR_UP          2'b00
`define DIR_DOWN        2'b01
`define DIR_LEFT        2'b10
`define DIR_RIGHT       2'b11

`define BLOCK_HEIGHT    40
`define BLOCK_WIDTH     40
`define GRID_HEIGHT     ( `V_SIZE / `BLOCK_HEIGHT )
`define GRID_WIDTH      ( `H_SIZE / `BLOCK_WIDTH )

// R (3 bits) G (3 bits) B (2 bits)
`define COLOR_FOOD      8'b11100000
`define COLOR_WALL      8'b11111111
`define COLOR_SNAKE     8'b00011100
`define COLOR_EMPTY     8'b00000000
