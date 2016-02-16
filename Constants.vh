`define H_SIZE          640
`define H_FRONT_PORCH   16
`define H_SYNC_PULSE    96
`define H_BACK_PORCH    48

`define V_SIZE          480
`define V_FRONT_PORCH   10
`define V_SYNC_PULSE    2
`define V_BACK_PORCH    33

`define BLOCK_EMPTY     2'b00
`define BLOCK_SNAKE     2'b01
`define BLOCK_FOOD      2'b10
`define BLOCK_WALL      2'b11

`define DIR_UP          2'b00
`define DIR_DOWN        2'b01
`define DIR_LEFT        2'b10
`define DIR_RIGHT       2'b11