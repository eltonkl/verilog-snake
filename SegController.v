`include "Constants.v"

module SegController(
    input wire          Clock,
    //input wire  [3:0]   FirstDigit,
    input wire  [3:0]   SecondDigit,
    input wire  [3:0]   ThirdDigit,
    input wire  [3:0]   FourthDigit,
    output reg  [2:0]   A,
    output reg  [6:0]   C
    );

    reg[1:0] digitIndex;
    
    initial begin
        digitIndex = 0;
        A = 'b000;
        C = 'b1111111;
    end

    always @ (posedge Clock) begin
        if (digitIndex == 0) begin
            digitIndex = 2;
        end
        else begin
            digitIndex = digitIndex - 1'b1;
        end
        case(digitIndex)
            //3: begin
            //    bin2seg(FirstDigit, c);
            //    A = 'b0111;
            //end
            2: begin
                bin2seg(SecondDigit);
                A = 'b011;
            end
            1: begin
                bin2seg(ThirdDigit);
                A = 'b101;
            end
            default: begin
                bin2seg(FourthDigit);
                A = 'b110;
            end
        endcase
    end

    task bin2seg;
        input  [3:0] number;
    begin
        case(number)
            1: C = `SEG_PATTERN_ONE;
            2: C = `SEG_PATTERN_TWO;
            3: C = `SEG_PATTERN_THREE;
            4: C = `SEG_PATTERN_FOUR;
            5: C = `SEG_PATTERN_FIVE;
            6: C = `SEG_PATTERN_SIX;
            7: C = `SEG_PATTERN_SEVEN;
            8: C = `SEG_PATTERN_EIGHT;
            9: C = `SEG_PATTERN_NINE;
            default: C = `SEG_PATTERN_ZERO;
        endcase
    end
    endtask
endmodule
