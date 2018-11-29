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
	assign start = ~KEY[1];
	
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

KMS k1(resetn, CLOCK_50, start, writeEn, colour, x, y);
endmodule

module KMS(reset, clk, load, writeEn, colour, out_x, out_y);
input reset, clk, load;
output writeEn;
output [2:0] colour;
output [7:0] out_x;
output [6:0] out_y;
wire finish, enable, done, enable_d, enable_xy;
wire [1:0] out_l;
wire [7:0] count_x;
wire [6:0] count_y;

FSM f1(finish, colour, load, reset, clk, enable, writeEn, done, enable_d, enable_xy);

datapath d1(count_x, count_y, enable,clk, reset, out_x, out_y, done);

xycounter c1(out_l, clk, enable_xy, reset, count_x, count_y);

delaycounter d3(clk, enable_d, finish); 

LFSR l1(reset, clk, out_l);  
endmodule



module FSM(finish, colour, load, reset, clk, enable, writeEn, done,enable_d, enable_xy);
 input load, reset, clk, finish, done;
 output reg enable, writeEn, enable_d, enable_xy;
 output reg [2:0] colour;
 
 reg [3:0] current_state, next_state;
    localparam  init    = 3'd0,
      sloaded = 3'd1,
            sdraw  = 3'd2,
            swait = 3'd3,
	slongwait = 3'd4,
	serase = 3'd5,
	serasew = 3'd6;
 


    always @(*)
    begin: state_table
            case (current_state)
                init: next_state = load ? sloaded : init;
		sloaded: next_state = sdraw;
		sdraw: next_state = swait;
		swait: next_state = done ? slongwait : sdraw;
		slongwait: next_state = finish ? serase : slongwait;
		serase: next_state = serasew;
		serasew: next_state = done ? sloaded : serase;
            default:     next_state = init;
        endcase
    end

 always @(*)
 begin
  enable = 1'b0;  
  writeEn = 1'b0;
  colour = 3'b000;
enable_d = 1'b0;
enable_xy = 1'b0;
 case (current_state)
// sloaded let xy_counter add one
     sloaded: begin
      enable_xy = 1'b1;
  end


     sdraw: begin
      enable = 1'b1;
      writeEn = 1'b1;
      colour = 3'b111;
  end

// inplement an delay counter
	slongwait:begin
	enable_d = 1'b1;
	end

     serase: begin
      enable = 1'b1;
      writeEn = 1'b1;
  end

// in case
//serasew: begin
//colour = 3'b000;
//end

        endcase
 end


// change state every clk wave
 always @(posedge clk)
 begin
 if (reset == 1'b0)
  current_state <= init;
 else
  current_state <= next_state;
 end
endmodule




module datapath(in_x, in_y, enable,clk,reset, out_x, out_y, done);
 input enable, clk, reset;
 input [7:0] in_x;
 input [6:0] in_y;
 output reg done;
 output [7:0] out_x;
 output [6:0] out_y;
 reg [3:0] counter;
 always @(posedge clk)
  begin
   if(reset == 1'b0)
    begin
    counter <= 4'b0;
    done <= 1'b0;
    end
   else
    begin
    if (enable == 1'b1)
     begin
     if (counter != 4'b1111)//7'b1111111
	begin
      counter <= counter + 1;
            done <= 1'b0;
	end
     else begin
      counter <= 4'b0;
      done <= 1'b1;
          end
     end
    end
  end
 
 assign out_x = counter[1:0] + in_x;//counter[3:1] + 
 assign out_y = counter[3:2] + in_y;//counter[7:4] + 

endmodule


module xycounter(l_out, clock, enable_xy, reset, count_x, count_y);
input clock, reset, enable_xy;
input [1:0] l_out;
output reg [7:0] count_x;
output reg [6:0] count_y;
always @(posedge clock)
begin
if (reset == 1'b0)
begin
    count_x <= 8'd80;//8'd80
    count_y <= 7'd0;
end
else begin
if (enable_xy == 1'b1) begin
	count_y <= count_y + 1'b1;
	if (count_y == 7'd115) begin
		if (l_out == 2'b00) begin
		count_x <= 8'd90;
    		count_y <= 7'd0;
		end
		else if (l_out == 2'b10) begin
		count_x <= 8'd100;
    		count_y <= 7'd0;
		end
		else if (l_out == 2'b01) begin
		count_x <= 8'd110;
    		count_y <= 7'd0;
		end
//		if (l_out == 2'b11) begin
//		count_x <= 8'd81;
//    		count_y <= 7'd0;
//		end
			       end
		
		       end
      end
end
endmodule

                                                                                                                                                      



module delaycounter(clock,enable,outclock);
input clock,enable;
output outclock;
reg [26:0]q;
wire [26:0]d;

assign d = 27'd12_499_999; //here 27'd12_499_999
assign outclock= (q == 0) ? 1:0;

always @(posedge clock)
begin
if (enable == 1'b0)
begin
q <= d;
end
else
q <= q - 1;
end
endmodule


module LFSR(reset, clk, out);
    input reset;
    input clk;
    output reg [1:0] out;
    always @(posedge clk) begin
        if (reset == 1'b0)
            out <= 2'b01;
   else
    out <= out ** 4'b1010 + out ** 4'b0111 + !(out[1] ^ out[0]);
    end
endmodule
