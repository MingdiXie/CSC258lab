module sim(
		CLOCK_50,						
        KEY,
        SW,
		  colour,
		  x,
		  y,
		  writeEn		
	);
	input			CLOCK_50;				
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	output writeEn;
	wire [7:0] tem_x;
	wire [6:0] tem_y;
	wire writeEn;
	wire mo_x;
	wire mo_y;
	wire r_x;
	wire r_y, r_c;
	wire enable_x;
	wire enable_y;
	wire enable_d;
	wire selc;
	wire count;
	wire finish;
	
x_counter u0(
.movex(mo_x),
.reset(r_x),
.x(tem_x),
.clock(CLOCK_50),
.enable(enable_x)
);

y_counter u1(
.movey(mo_y),
.reset(r_y),
.y(tem_y),
.clock(CLOCK_50),
.enable(enable_y)
);
Delay_counter u2(
.clock(CLOCK_50),
.reset(r_c),
.outclock(count)
);


datapath u3(
.x(tem_x),
.y(tem_y),
.reset(r_d),
.sel(selc),
.enable(enable_d),
.plot(writeEn),
.clock(CLOCK_50),
.outx(x),
.outy(y),
.outcolor(colour),
.done(finish)
);


control u4(
.reset(KEY[0]),
.count(count),
.clock(CLOCK_50),
.done(finish),
.go(KEY[1]),
.x(tem_x),
.y(tem_y),
.movex(mo_x),
.movey(mo_y),
.enable_x(enable_x),
.enable_y(enable_y),
.enable_d(enable_d),
.sel(selc),
.reset_d(r_d),
.reset_c(r_c),
.reset_x(r_x),
.reset_y(r_y)
);


endmodule

module lab7_3
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
	wire [7:0] tem_x;
	wire [6:0] tem_y;
	wire writeEn;
	wire mo_x;
	wire mo_y;
	wire r_x;
	wire r_y, r_c;
	wire enable_x;
	wire enable_y;
	wire enable_d;
	wire selc;
	wire count;
	wire finish;

	
	

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
		
x_counter u0(
.movex(mo_x),
.reset(r_x),
.x(tem_x),
.clock(CLOCK_50),
.enable(enable_x)
);

y_counter u1(
.movey(mo_y),
.reset(r_y),
.y(tem_y),
.clock(CLOCK_50),
.enable(enable_y)
);
Delay_counter u2(
.clock(CLOCK_50),
.reset(r_c),
.outclock(count)
);


datapath u3(
.x(tem_x),
.y(tem_y),
.reset(r_d),
.sel(selc),
.enable(enable_d),
.plot(writeEn),
.clock(CLOCK_50),
.outx(x),
.outy(y),
.outcolor(colour),
.done(finish)
);


control u4(
.reset(KEY[0]),
.count(count),
.clock(CLOCK_50),
.done(finish),
.go(KEY[1]),
.x(tem_x),
.y(tem_y),
.movex(mo_x),
.movey(mo_y),
.enable_x(enable_x),
.enable_y(enable_y),
.enable_d(enable_d),
.sel(selc),
.reset_d(r_d),
.reset_c(r_c),
.reset_x(r_x),
.reset_y(r_y)
);


endmodule






module x_counter(movex,reset,x,clock,enable);
input movex,reset,clock,enable;
output reg [7:0]x;
always @(posedge clock)
begin
if (reset == 1'b1)
x <= 8'd81; //Here!!!!!!!!!!!!!!!!!!!!!!
else begin
if (enable == 1'b1)
begin
if (movex == 1'b1)
x <= x;
else
x <= x;
end
end
end
endmodule

module y_counter(movey,reset,y,clock,enable);
input movey,reset,clock,enable;
output reg [6:0]y;
always @(posedge clock)
begin
if (reset == 1'b1)
y <= 7'd0; // here !!!!!!!!!!!!!!!!
else begin
if (enable == 1'b1)
begin
if (movey == 1'b1)
y <= y + 8'd1;
else
y <= y + 8'd1;
end
end
end
endmodule

module Delay_counter(clock,reset,outclock);
input clock,reset;
output outclock;
reg [26:0]q;
wire [26:0]d;

assign d = 27'd12_499_999; // here!!!!!!!!!!!!!
assign outclock= (q == 0) ? 1:0;

always @(posedge clock)
begin
if (q == 0| reset == 1'b1)
begin
q <= d;
end
else
q <= q - 1;
end
endmodule








module datapath(x,y,reset,sel,enable, plot, clock, outx,outy,outcolor,done);
input [7:0]x;
input [6:0]y;
input clock, reset, sel,enable;


output reg [7:0]outx;
output reg [6:0]outy;
output [2:0]outcolor;
output reg plot;
output reg done;
reg [4:0]counter;
reg [2:0]c_state;
reg [2:0]n_state;
reg loadn;
reg update;

assign outcolor = (sel == 1'b1)?3'b000 : 3'b100;

localparam init = 2'd0, load = 2'd1,write =2'd2, final = 2'd3;


always @(*)
begin
loadn = 1'b0;
update = 1'b0;
plot = 1'b0;
done = 1'b0;
case (c_state)
init: begin
if (enable == 1'b1)
n_state = load;
else
n_state = init;
end

load:begin
if (counter == 8'b10000000)
n_state = final;
else begin
n_state = write;
loadn = 1'b1;
end
end

write:begin
update = 1'b1;
plot = 1'b1;
n_state = load;
end

final:begin
done = 1'b1;
n_state = final;
end
endcase
end

always @(posedge clock)
begin
if (reset == 1'b1)
begin
counter <= 7'b0;
c_state = init;
end
else begin
if (enable == 1'b1)
begin
c_state <= n_state;

if (update == 1'b1)
   counter <= counter + 1;


if (loadn == 1'b1)
begin
outx <= x + counter[3:0];
outy <= y + counter[6:4];
end

end
end
end
endmodule



module control(reset, count,clock, done,go,x,y,movex,movey,enable_x,enable_y,enable_d,sel,reset_d, reset_c,reset_x,reset_y);
input reset, count,clock, done,go;
input [7:0]x;
input [6:0]y;

output reg movex,movey;
output reg enable_x,enable_y,enable_d,sel;
output reg reset_d, reset_c,reset_x,reset_y;


reg [2:0]c_state;
reg [2:0]n_state;

localparam init = 3'd0, dr = 3'd1,
ret = 3'd2, w = 3'd3, erase = 3'd4, upd = 3'd5, ending = 3'd6;


always @(*)
begin
enable_d = 1'b0;
enable_x = 1'b0;
enable_y = 1'b0;
reset_d = 1'b0;
reset_x = 1'b0;
reset_y = 1'b0;
reset_c = 1'b0;

case (c_state)

ending: begin
if (done == 1'b0)
begin
n_state = erase;
enable_d = 1'b1;
sel = 1'b1;
end
else
n_state = init;
end


init: begin
reset_d = 1'b1;
reset_x = 1'b1;
reset_y = 1'b1;
reset_c = 1'b1;
movex = 1'b1;
movey = 1'b0;
sel = 1'b0;
if (go == 1'b1)
n_state = init;
else
n_state = dr;
end

dr :begin
if (done == 1'b0)
begin
enable_d = 1'b1;
sel = 1'b0;
end
begin
if (done == 1'b1)
n_state = ret;
end
end

ret:
begin
reset_d = 1'b1;
reset_c = 1'b1;
n_state = w;
end

w:
begin
if (count == 1'b1)
n_state = erase;
else
n_state = w;
end

erase:
begin
if (done == 1'b0)
begin
n_state = erase;
enable_d = 1'b1;
sel = 1'b1;
end
else
n_state = upd;
end

upd:
begin
reset_d = 1'b1;
enable_x = 1'b1;
enable_y = 1'b1;

if (x == 8'd156 & movex == 1'b1)
movex = 1'b0;
if (x == 8'd0 & movex == 1'b0)
movex = 1'b1;
if (y == 7'd0 & movey == 1'b0)
movey = 1'b1;
if (y == 7'd116 & movey == 1'b1)
movey = 1'b0;

n_state = dr;
end
endcase
end

always @(posedge clock)
begin
if (reset == 1'b0)
c_state <= ending;
else
c_state <= n_state;
end
endmodule

