`define H_PIXELS            640
`define V_PIXELS            480

`define BITS_PER_BLOCK      2
`define BLOCK_EMPTY         2'b00
`define BLOCK_SNAKE         2'b01
`define BLOCK_FOOD          2'b10
`define BLOCK_WALL          2'b11

`define BITS_PER_DIR        2
`define DIR_UP              2'b00
`define DIR_DOWN            2'b01
`define DIR_LEFT            2'b10
`define DIR_RIGHT           2'b11

`define BLOCK_HEIGHT        20
`define BLOCK_WIDTH         20
`define GRID_HEIGHT         ( `V_PIXELS / `BLOCK_HEIGHT )
`define GRID_WIDTH          ( `H_PIXELS / `BLOCK_WIDTH )

// R (3 bits) G (3 bits) B (2 bits)
`define COLOR_FOOD          8'b11110100
`define COLOR_WALL          8'b11111111
`define COLOR_SNAKE         8'b00011100
`define COLOR_EMPTY         8'b00000000

`define NUM_SNAKE_PIECES    10

`define BITS_PER_STATE      2
`define STATE_PAUSE         2'b00
`define STATE_DEAD          2'b01
`define STATE_ALIVE         2'b10
`define STATE_FIND_FOOD     2'b11

`define BTN_UP              3'b000
`define BTN_DOWN            3'b001
`define BTN_LEFT            3'b010
`define BTN_RIGHT           3'b011
`define BTN_CENTER          3'b100
`define BTN_NONE            3'b111

`define LETTER_H            10
`define LETTER_I            11
`define LETTER_G            12
`define LETTER_BLANK        13

`define SEG_PATTERN_ONE     'b1111001
`define SEG_PATTERN_TWO     'b0100100
`define SEG_PATTERN_THREE   'b0110000
`define SEG_PATTERN_FOUR    'b0011001
`define SEG_PATTERN_FIVE    'b0010010
`define SEG_PATTERN_SIX     'b0000010
`define SEG_PATTERN_SEVEN   'b1111000
`define SEG_PATTERN_EIGHT   'b0000000
`define SEG_PATTERN_NINE    'b0010000
`define SEG_PATTERN_ZERO    'b1000000
`define SEG_PATTERN_H       'b0001001
`define SEG_PATTERN_I       'b1111001
`define SEG_PATTERN_G       'b0000010
`define SEG_PATTERN_OFF     'b1111111
