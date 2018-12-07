module GFX2
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
KMS k1(SW[3:0], SW[7:4], resetn, CLOCK_50, start, writeEn, colour, x, y);
endmodule


module KMS(tdirection, jdirection, reset, clk, load, writeEn, colour, out_x, out_y);
input reset, clk, load;
input [3:0] tdirection;
input [3:0] jdirection;
output writeEn;
output [2:0] colour;
output [7:0] out_x;
output [6:0] out_y;
wire finish, enable, done, enable_d, enable_xy, enable_xyj, enable_e, collision, enable_f, exist;
wire [7:0] count_x;
wire [6:0] count_y;
wire [7:0] fx;
wire [6:0] fy;
wire [7:0] count_xj;
wire [6:0] count_yj;
wire [1:0] mselect;
wire [7:0] outx;
wire [6:0] outy;

FSM f1(exist, collision, finish, colour, load, reset, clk, enable, writeEn, done, enable_d, enable_xy, enable_xyj, mselect, enable_e, enable_f);

datapath d1(outx, outy, enable_e, enable_f, enable,clk, reset, out_x, out_y, done);

xycounter c1(clk, enable_xy, reset, count_x, count_y, tdirection);

xyjcounter cc1(clk, enable_xyj, reset, count_xj, count_yj, jdirection);

food f111(clk, reset, fx, fy);

mux m1(count_xj,count_yj,count_x,count_y, mselect, outx, outy, collision, fx, fy);

delaycounter d3(clk, enable_d, finish);

checkfood ccc(clk,reset, enable_f,count_x,count_y,count_xj,count_yj,fx,fy,exist);
endmodule

//exist, enable_f
module FSM(exist, collision,finish, colour, load, reset, clk, enable, writeEn, done,enable_d, enable_xy, enable_xyj, muxs,enable_e, enable_f);
 input load, reset, clk, finish, done, collision, exist;
 output reg enable, writeEn, enable_d, enable_xy, enable_xyj,enable_e,enable_f;
 output reg [2:0] colour;
 output reg [1:0] muxs;
 reg [3:0] current_state, next_state;
    localparam  init    = 4'd0,
      sloaded = 4'd1,
            sdraw  = 4'd2,
            swait = 4'd3,
sdrawj = 4'd4,
swaitj = 4'd5,

 slongwait = 4'd6,
 serase = 4'd7,
 serasew = 4'd8,

sej = 4'd9,
sejw = 4'd10,
inwait = 4'd11,
checkfood = 4'd12,
drawfood = 4'd13;
 

    always @(*)
    begin: state_table
            case (current_state)
                init: next_state = load ? sloaded : inwait;
  inwait: next_state = init;
  sloaded: next_state = sdraw;
  sdraw: next_state = swait;
  swait: next_state = done ? sdrawj : sdraw;
  sdrawj: next_state = swaitj;
  swaitj: next_state = done ? checkfood : sdrawj;

  checkfood: next_state = exist ? slongwait : drawfood;

  drawfood: next_state = done ? slongwait : drawfood;  

  slongwait: next_state = finish ? serase : slongwait;

  serase: next_state = serasew;

  serasew: next_state = done ? sej : serase;

  sej: next_state = sejw;

  sejw: next_state = done ? sloaded : sej;
        endcase
    end


 always @(*)
 begin
  enable = 1'b0;  
  writeEn = 1'b0;
  colour = 3'b000;
enable_d = 1'b0;
enable_xy = 1'b0;
enable_xyj = 1'b0;
muxs = 2'b00;
enable_e = 1'b0;
enable_f = 1'b0;
 case (current_state)

     sloaded: begin
      enable_xy = 1'b1;
      enable_xyj = 1'b1;
  end
     inwait: begin
      enable_e = 1'b1;
      writeEn = 1'b1;
  end
     sdraw: begin
      enable = 1'b1;
      writeEn = 1'b1;
      colour = 3'b001;
	muxs = 2'b01;//tom
  end



     sdrawj: begin
      enable = 1'b1;
      writeEn = 1'b1;
      colour = 3'b100;
      muxs = 2'b00;//jerry
  end

     drawfood: begin
      enable_f = 1'b1;
      writeEn = 1'b1;
      colour = 3'b010;
      muxs = 2'b10;//muxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  end

 slongwait:begin
 enable_d = 1'b1;
 end

     serase: begin
      enable = 1'b1;
      writeEn = 1'b1;
      muxs = 2'b01;
  end

     serasew: begin
      muxs = 2'b01;
  end

     sej: begin
      enable = 1'b1;
      writeEn = 1'b1;//mux
      muxs = 2'b00;
  end

     sejw: begin
      muxs = 2'b00;
  end

        endcase
 end

// change state every clk wave
 always @(posedge clk)
 begin
 if (reset == 1'b0 | collision == 1'b1)
  current_state <= init;
 else
  current_state <= next_state;
 end
endmodule



module datapath(in_x, in_y, enable_e, enable_f, enable,clk,reset, out_x, out_y, done);
 input enable, clk, reset, enable_e, enable_f;
 input [7:0] in_x;
 input [6:0] in_y;
 output reg done;
 output [7:0] out_x;
 output [6:0] out_y;
 reg [1:0] counter;//
reg [14:0] counter1;
reg era;
 always @(posedge clk)
  begin
   if(reset == 1'b0)
    begin
    counter <= 2'b0;//
    done <= 1'b0;
    counter1 <= 15'b0;
    era <= 1'b1;
    end
   else if (enable == 1'b1)
     begin
     if (counter != 2'b11)//7'b1111111
 begin
      counter <= counter + 1;
	done <= 1'b0;
 end
     else begin
      counter <= 2'b0;//
      done <= 1'b1;
          end
     end

  else if(enable_e == 1'b1 & era == 1'b1)
	begin
     if (counter1 != 15'b111111111111111)
      counter1 <= counter1 + 1;
     else begin
      counter1 <= 15'b0;
      era <= 1'b0;
          end
        end
  else if(enable_f == 1'b1)
	done <= 1'b1; 
        

  end
 
 assign out_x = counter[0] + in_x + counter1[14:7];//counter[3:1] + 
 assign out_y = counter[1] + in_y + counter1[6:0];//counter[7:4] +
endmodule


module checkfood(clock,reset,enable_f,tx,ty,jx,jy,fx,fy,exist);
input clock, reset,enable_f;
input [7:0] tx;
input [7:0] jx;
input [7:0] fx;
input [6:0] ty;
input [6:0] jy;
input [6:0] fy;
output reg exist;
always @(posedge clock)
begin
if (reset == 1'b0)
    exist <= 1'b0;
else if(enable_f)
	exist <= 1'b1;
else if( ((tx == fx) &(ty == fy))| ((jx == fx) &(jy == fy)) )
	exist <= 1'b0;
end
endmodule




module xycounter(clock, enable_xy, reset, count_x, count_y, dir);
input clock, reset, enable_xy;
input [3:0] dir;
output reg [7:0] count_x;
output reg [6:0] count_y;
always @(posedge clock)
begin
if (reset == 1'b0)
begin
    count_x <= 8'd0;//tom starts here
    count_y <= 7'd0;
end
else begin
if (enable_xy == 1'b1) begin
  if (dir[2] == 1'b1) 
 count_y <= count_y + 1'b1;

  if (dir[3] == 1'b1)
 count_y <= count_y - 1'b1;

  if (dir[0] == 1'b1) 
 count_x <= count_x + 1'b1;

  if (dir[1] == 1'b1) 
 count_x <= count_x - 1'b1;

  
         end
      end
end
endmodule
                                                                                                                                                     
module xyjcounter(clock, enable_xyj, reset, count_x, count_y, dir);
input clock, reset, enable_xyj;
input [3:0] dir;
output reg [7:0] count_x;
output reg [6:0] count_y;
always @(posedge clock)
begin
if (reset == 1'b0)
begin
    count_x <= 8'd0;//jerry starts here
    count_y <= 7'd60;
end
else begin
if (enable_xyj == 1'b1) begin
  if (dir[2] == 1'b1) 
 count_y <= count_y + 1'b1;

  if (dir[3] == 1'b1)
 count_y <= count_y - 1'b1;

  if (dir[0] == 1'b1) 
 count_x <= count_x + 1'b1;

  if (dir[1] == 1'b1) 
 count_x <= count_x - 1'b1;

  
         end
      end
end
endmodule


module food(clock, reset, count_x, count_y);
input clock, reset;
output reg [7:0] count_x;
output reg [6:0] count_y;
always @(posedge clock)
begin
if (reset == 1'b0)
begin
    count_x <= 8'd4;//jerry starts here
    count_y <= 7'd60;
end
else begin
	count_x <= 8'd149;
	count_y <= 8'd119;
      end
end
endmodule


module mux(jx,jy,tx,ty,MuxSelect,outx,outy, collision, fx, fy);
input [7:0] jx;
input [7:0] tx;
input [7:0] fx;
input [6:0] fy;
input [6:0] jy;
input [6:0] ty;
input [1:0] MuxSelect;
output reg [7:0] outx;
output reg [6:0] outy;
output [0:0] collision;
always @(*)
begin
	case (MuxSelect [1:0])
		2'b00: outx = jx;
		2'b01: outx = tx;
		2'b10: outx = fx;
		default: outx = jx;
	endcase
end

always @(*)
begin
	case (MuxSelect [1:0])
		2'b00: outy = jy;
		2'b01: outy = ty;
		2'b10: outy = fy;
		default: outy = jy;
	endcase
end
assign collision = (jx == tx) & (jy == ty);

endmodule

module delaycounter(clock,enable,outclock);
input clock,enable;
output outclock;
reg [21:0]q;
wire [21:0]d;
assign d = 20'd840_000;//20'd840_000
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

//module LFSR(reset, clk, ooo);
//    input reset;
//    input clk;
//  output [1:0] ooo;
 //   reg [3:0] out;
  //assign feedback = ~(out[3] ^ out[2]);
  //assign ooo = out[1:0];
    //always @(posedge clk) begin
      //  if (reset == 1'b0)
        //    out <= 4'b0;
   //else
    //out <= {out[2:0], feedback};
    //end
//endmodule
