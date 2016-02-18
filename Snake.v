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
    output wire         VGAVSync
    );

	reg [`BITS_PER_BLOCK-1:0]     blocks [0:`GRID_HEIGHT-1] [0:`GRID_WIDTH-1];
	reg leftPressed;
	reg rightPressed;
	reg upPressed;
	reg downPressed;
	reg centerPressed;
	
	wire clk;
	
	initial begin
		leftPressed = 0;
		rightPressed = 0;
		upPressed = 0;
		downPressed = 0;
		centerPressed = 0;
	end
	
	ClockDivider cd(
		.MasterClock(MasterClock),
		.Clock(clk)
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

endmodule
