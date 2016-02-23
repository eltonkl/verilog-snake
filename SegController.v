`include "Constants.v"

module SegController(
    input wire          Clock,
    input wire          En,
    input wire  [3:0]   FirstDigit,
    input wire  [3:0]   SecondDigit,
    input wire  [3:0]   ThirdDigit,
    input wire  [3:0]   FourthDigit,
    output wire [3:0]   A,
    output wire [6:0]   C
    );

    reg[1:0] digitIndex;
    reg[3:0] a;
    reg[6:0] c;

    assign A = a;
    assign C = c;
    
    initial begin
        digitIndex = 0;
        a = 'b0001;
        c = 'b0000000;
    end

    always @ (posedge Clock) begin
        if (digitIndex == 0) begin
            digitIndex <= 3;
        end
        else begin
            digitIndex <= digitIndex - 2'b1;
        end
        case(digitIndex)
            3: begin
                bin2seg(FirstDigit, c);
                a = 'b0111;
            end
            2: begin
                bin2seg(SecondDigit, c);
                a = 'b1011;
            end
            1: begin
                bin2seg(ThirdDigit, c);
                a = 'b1101;
            end
            default: begin
                bin2seg(FourthDigit, c);
                a = 'b1110;
            end
        endcase
    end

    task bin2seg;
        input  [3:0] number;
        output [6:0] segment;
    begin
        if (En == 1) begin
            case(number)
                1: segment = `SEG_PATTERN_ONE;
                2: segment = `SEG_PATTERN_TWO;
                3: segment = `SEG_PATTERN_THREE;
                4: segment = `SEG_PATTERN_FOUR;
                5: segment = `SEG_PATTERN_FIVE;
                6: segment = `SEG_PATTERN_SIX;
                7: segment = `SEG_PATTERN_SEVEN;
                8: segment = `SEG_PATTERN_EIGHT;
                9: segment = `SEG_PATTERN_NINE;
                `LETTER_H: segment = `SEG_PATTERN_H
                `LETTER_I: segment = `SEG_PATTERN_I
                `LETTER_G: segment = `SEG_PATTERN_G
                default: segment = `SEG_PATTERN_ZERO;
            endcase
        end
        else begin
            segment = `SEG_PATTERN_OFF;
        end
    end
    endtask
endmodule
