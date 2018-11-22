// Part 2 skeleton


module datapath(xy,colour,loadx,loady,loadc,enable,clk,reset,out_c,out_x,out_y);
	input [6:0] xy;
	input [2:0] colour;
	input loadx, loady, loadc, enable, clk, reset;
	
	output [7:0] out_x;
	output [6:0] out_y;
	output [2:0] out_c;
	
	reg [3:0] counter;
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;
	always @(posedge clk)
		begin
			if(reset == 1'b0) 
				begin
				x <= 8'b0;
				y <= 8'b0;
				c <= 3'b0;
				end
			else 
				begin
				if (loadx == 1'b1)
					x <= {1'b0, xy};
				if (loady == 1'b1)
					y <= xy;
				if (loadc == 1'b1)
					c <= colour;
				end
		end
	
	always @(posedge clk)
		begin
			if(reset == 1'b0)
				begin
				counter <= 4'b0;
				end
			else if(enable == 1'b1) 
				begin
				if (counter != 4'b1111)
					counter <= counter + 1;
				else begin
					counter <= 4'b0;
				end
				end
		end
	assign out_x = counter[1:0] + x;
	assign out_y = counter[3:2] + y;
	assign out_c = c;

endmodule

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);

    // Instansiate FSM control
    // control c0(...);
    
endmodule
