// Part 2 skeleton// Part 2 skeleton
module FD(CLOCK_50, SW, KEY, out_c, out_x, out_y, writeEn);
	input	CLOCK_50;
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [2:0] out_c;
	output [7:0] out_x;
	output [6:0] out_y;
	output writeEn;
	wire loadx, loady, loadc, enable;

	assign start = ~KEY[1];
	assign load = ~KEY[3];

FSM f1(start, load, KEY[0], CLOCK_50, loadx, loady, loadc, enable, writeEn);


datapath d1(SW[6:0], SW[9:7],loadx,loady,loadc,enable,CLOCK_50,KEY[0],out_c,out_x,out_y);
endmodule

module part2
 (
  CLOCK_50,      // On Board 50 MHz
  // Your inputs and outputs here
        KEY,
        SW,
  // The ports below are for the VGA output.  Do not change.
  VGA_CLK,         // VGA Clock
  VGA_HS,       // VGA H_SYNC
  VGA_VS,       // VGA V_SYNC
  VGA_BLANK_N,      // VGA BLANK
  VGA_SYNC_N,      // VGA SYNC
  VGA_R,         // VGA Red[9:0]
  VGA_G,        // VGA Green[9:0]
  VGA_B         // VGA Blue[9:0]
 );

 input   CLOCK_50;    // 50 MHz
 input   [9:0]   SW;
 input   [3:0]   KEY;

 // Declare your inputs and outputs here
 // Do not change the following outputs
 output   VGA_CLK;       // VGA Clock
 output   VGA_HS;     // VGA H_SYNC
 output   VGA_VS;     // VGA V_SYNC
 output   VGA_BLANK_N;    // VGA BLANK
 output   VGA_SYNC_N;    // VGA SYNC
 output [9:0] VGA_R;       // VGA Red[9:0]
 output [9:0] VGA_G;      // VGA Green[9:0]
 output [9:0] VGA_B;       // VGA Blue[9:0]
 
 wire resetn;
 assign resetn = KEY[0];
 assign start = ~KEY[1];
 assign load = ~KEY[3];
 
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

datapath d10(
.xy(SW[6:0]),
.colour(SW[9:7]),
.loadx(loadx),
.loady(loady),
.loadc(loadc),
.enable(enable),
.clk(CLOCK_50),
.reset(KEY[0]),
.out_c(colour),
.out_x(x),
.out_y(y));

    // Instansiate FSM control
    // control c0(...);

FSM f10(
.start(start),
.load(load),
.reset(KEY[0]),
.clk(CLOCK_50),
.loadx(loadx),
.loady(loady),
.loadc(loadc),
.enable(enable),
.writeEn(writeEn)
);
    
endmodule


module FSM(start, load, reset, clk, loadx, loady, loadc, enable, writeEn);
 input start, load, reset, clk;
 output reg loadx, loady, loadc, enable, writeEn;
 
 reg [3:0] current_state, next_state; 
    localparam  sload_x    = 3'd0,
                sload_xw   = 3'd1,
                sload_y    = 3'd2,
                sload_yw   = 3'd3,
  sloaded = 3'd4,
  sdraw  = 3'd5,
  swait = 3'd6;



    always @(*)
    begin: state_table 
            case (current_state)
                sload_x: next_state = load ? sload_xw : sload_x; 
                sload_xw: next_state = load ? sload_xw : sload_y; 
                sload_y: next_state = load ? sload_yw : sload_y; 
                sload_yw: next_state = load ? sload_yw : sloaded;
  sloaded: next_state = sdraw;
  swait: next_state = sdraw;
  sdraw: next_state = swait;

            default:     next_state = sload_x;
        endcase
    end

 always @(*) 
 begin
  loadx = 1'b0;
  loady = 1'b0;
  loadc = 1'b0;
  enable = 1'b0;  
  writeEn = 1'b0;
  
 case (current_state)
            sload_xw: begin
                loadx = 1'b1;
                end
            sload_yw: begin
                loady = 1'b1;
      loadc = 1'b1;
                end
//      swait: begin
//                 writeEn = 1'b0;
//                 end
     sdraw: begin
                enable = 1'b1;
  writeEn = 1'b1;
  end

        endcase
 end

 always @(posedge clk)
 begin
 if (reset == 1'b0) 
  begin
  current_state <= sload_x;
  end
 else 
  begin
  current_state <= next_state;
  end
 end
endmodule



module datapath(xy,colour,loadx,loady,loadc,enable,clk,reset,out_c,out_x,out_y);
 input [6:0] xy;
 input [2:0] colour;
 input loadx, loady, loadc, enable, clk, reset;
 
 output [7:0] out_x;
 output [6:0] out_y;
 output [2:0] out_c;
 reg [4:0] counter;
 reg [7:0] x;
 reg [6:0] y;
 reg [2:0] c;
 reg [0:0] add_one;
 always @(posedge clk)
  begin
   if(reset == 1'b0) 
    begin
    x <= 8'b0;
    y <= 8'b0;
    c <= 3'b0;
    counter <= 5'b0;
    end
   else 
    begin
    if (loadx == 1'b1)
     x <= {1'b0, xy};
    if (loady == 1'b1)
     y <= xy;
    if (loadc == 1'b1)
     c <= colour;
    if (enable == 1'b1)
     begin
     if (counter != 5'b11111)
      counter <= counter + 1;
     else begin
      counter <= 5'b0;
          end
     end
    end
  end
 
 assign out_x = counter[2:1] + x;
 assign out_y = counter[4:3] + y;
 assign out_c = c;

endmodule
