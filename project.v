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
  VGA_B,         // VGA Blue[9:0]
 HEX0,
 HEX1,
  HEX2,
 HEX3,
 PS2_CLK, 
 PS2_DAT,
 LEDR
 );
 input   CLOCK_50;    // 50 MHz
 input   [9:0]   SW;
 input   [3:0]   KEY;
 inout PS2_CLK;
 inout PS2_DAT;
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
 //output [6:0] HEX0;
 output [6:0] HEX1;
 output [6:0] HEX0;
 output [6:0] HEX2;
 output [6:0] HEX3;
 output [6:0] LEDR;
 wire resetn;
 assign resetn = KEY[0];
 assign start = ~KEY[1];
 
 // Create the colour, x, y and writeEn wires that are inputs to the controller.
 wire [2:0] colour;
 wire [7:0] x;
 wire [6:0] y;
 wire writeEn;
 wire [3:0] sss1;
 wire [3:0] sss2;
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
   
// KEYBOARD DECLARATION
    wire skey;
    wire akey;
    wire wkey;
    wire dkey;
    wire [5:0] useless;
  wire spaceb;
 wire [3:0] hscore1;
 wire [3:0] hscore2;
 
    keyboard_tracker #(.PULSE_OR_HOLD(0)) KB0(CLOCK_50, resetn, PS2_CLK, PS2_DAT, wkey, akey, skey, dkey, useless[5], useless[4], useless[3], useless[2], spaceb, useless[0]);
 // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
KMS k1(akey, skey, dkey, wkey, SW[1:0], resetn, CLOCK_50, start, writeEn, colour, x, y, sss1, sss2, spaceb);
history hhh1(sss1,sss2,CLOCK_50,resetn,SW[3:2],~KEY[3],hscore1,hscore2);
seven_seg_decoder s1(sss1 ,HEX0); 
seven_seg_decoder s2(sss2 ,HEX1);
 seven_seg_decoder s3(hscore1 ,HEX2); 
 seven_seg_decoder s4(hscore2 ,HEX3); 
endmodule
module KMS(aaa, sss, ddd, www, difficulty, reset, clk, load, writeEn, colour, out_x, out_y, score1, score2, spaceb);
input reset, clk, load, aaa, sss, ddd, www;
input [1:0] difficulty;
input spaceb;
output writeEn;
output [2:0] colour;
output [7:0] out_x;
output [6:0] out_y;
output [3:0] score1;
output [3:0] score2;
wire finish, enable, done, enable_d, enable_xy, enable_e;
wire [1:0] out_l;
wire [7:0] count_x;
wire [6:0] count_y;

FSM f1(out_l, finish, colour, load, reset, clk, enable, writeEn, done, enable_d, enable_xy, enable_e);
datapath d1(count_x, count_y, enable_e, enable,clk, reset, out_x, out_y, done);
xycounter c1(out_l, clk, enable_xy, reset, count_x, count_y, aaa, sss, ddd, www, score1, score2, spaceb);
delaycounter d3(clk, enable_d, finish, difficulty);
LFSR l1(reset, clk, out_l);
 
endmodule

module FSM(ooo, finish, colour, load, reset, clk, enable, writeEn, done, enable_d, enable_xy, enable_e);
 input load, reset, clk, finish, done;
 input [1:0] ooo;
 output reg enable, writeEn, enable_d, enable_xy, enable_e;
 output reg [2:0] colour;
 
 reg [3:0] current_state, next_state;
    localparam  init    = 3'd0,
      sloaded = 3'd1,
            sdraw  = 3'd2,
            swait = 3'd3,
 slongwait = 3'd4,
 serase = 3'd5,
 serasew = 3'd6,
inwait = 3'd7;
 
    always @(*)
    begin: state_table
            case (current_state)
                init: next_state = load ? sloaded : inwait;
  inwait: next_state = init;
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
enable_e = 1'b0;
 case (current_state)
// sloaded let xy_counter add one
     sloaded: begin
      enable_xy = 1'b1;
  end
     inwait: begin
      enable_e = 1'b1;
      writeEn = 1'b1;
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

module datapath(in_x, in_y, enable_e, enable,clk,reset, out_x, out_y, done);
 input enable, clk, reset, enable_e;
 input [7:0] in_x;
 input [6:0] in_y;
 output reg done;
 output [7:0] out_x;
 output [6:0] out_y;
 reg [7:0] counter;//[7:0]
reg [14:0] counter1;
reg era;
 always @(posedge clk)
  begin
   if(reset == 1'b0)
    begin
    counter <= 8'b0;//8'b0;
    done <= 1'b0;
    counter1 <= 15'b0;
    era <= 1'b1;     
    end
   else if (enable == 1'b1)
     begin
     if (counter != 8'b11111111)// 8'b11111111
 begin
      counter <= counter + 1;
            done <= 1'b0;
 end
     else begin
      counter <= 8'b0;//8'b0;
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
  end
 
 assign out_x = counter[7:3] + in_x + counter1[14:7];//counter[7:3]
 assign out_y = counter[2:0] + in_y + counter1[6:0];//counter[2:0]
endmodule

module xycounter(l_out, clock, enable_xy, reset, count_x, count_y, aaa, sss, ddd,www, score1, score2, spaceb);
input clock, reset, enable_xy, aaa, sss, ddd, www, spaceb;
input [1:0] l_out;
output reg [7:0] count_x;
output reg [6:0] count_y;
output reg [3:0] score1;
output reg [3:0] score2;
reg [3:0] bonus;
always @(posedge clock)
begin
if (reset == 1'b0)
begin
    count_x <= 8'd4;//8'd81
    count_y <= 7'd0;
    score1 <= 4'b0;
  score2 <= 4'b0;
  bonus <= 4'b1;
  
end
else begin
if (enable_xy == 1'b1) begin
 count_y <= count_y + 1'b1;
 if (count_y == 7'd112) begin
  
  if ((sss ==1'b1 & count_x != 8'd84 & spaceb == 1'b1)|(aaa ==1'b1 & count_x != 8'd44 & spaceb == 1'b1)|(www ==1'b1 & count_x != 8'd4 & spaceb == 1'b1)|(ddd ==1'b1 & count_x != 8'd124 & spaceb == 1'b1)) begin// & count_x == 8'd44
  bonus <= 4'b1;
  end
  
  if (aaa ==1'b1 & count_x == 8'd44 & spaceb == 1'b1) begin//& count_x == 8'd4
  score1 <= score1 + bonus;
  if (bonus < 4'd8)
  bonus <= 2 * bonus; 
   if (score1 + bonus >= 4'd10)
 begin
  score1 <= score1 - 4'd10;
  score2 <= score2 +1;
 end
  end
  
  
if (sss ==1'b1 & count_x == 8'd84 & spaceb == 1'b1) begin// & count_x == 8'd44
  score1 <= score1 + bonus;
  if (bonus < 4'd8)
  bonus <= 2 * bonus;
 if (score1 + bonus >= 4'd10)
 begin
  score1 <= score1 - 4'd10;
  score2 <= score2 +1;
 end
  end
  
  
  if (www ==1'b1 & count_x == 8'd4 & spaceb == 1'b1) begin//& count_x == 8'd4
  score1 <= score1 + bonus;
   if (score1 + bonus >= 4'd10)
 begin
  score1 <= score1 - 4'd10;
  score2 <= score2 +1;
 end
 if (bonus < 4'd8)
  bonus <= 2 * bonus;
  end
   
  
 if (ddd ==1'b1 & count_x == 8'd124 & spaceb == 1'b1) begin// & count_x == 8'd44
  if (score1 + bonus >= 4'd10)
   begin
    score1 <= score1 - 4'd10;
    score2 <= score2 +1;
   end
  score1 <= score1 + bonus;
  if (bonus < 4'd8)
  bonus <= 2 * bonus;
 end
  


  if (l_out == 2'b11) begin
  count_x <= 8'd4;//8'd4
      count_y <= 7'd0;
  end
  else if (l_out == 2'b01) begin
  count_x <= 8'd44;//8'd44
      count_y <= 7'd0;
  end
  else if (l_out == 2'b10) begin
  count_x <= 8'd84;//8'd84
      count_y <= 7'd0;
  end
  else if (l_out == 2'b00) begin
  count_x <= 8'd124;//8'd124
      count_y <= 7'd0;
  end
          end
  
         end
      end
end
endmodule
                                                                                                                                                    

module delaycounter(clock,enable,outclock,switch);
input clock,enable;
input [1:0] switch;
output outclock;
reg [21:0]q;
reg [21:0]d;
//assign d = 20'd840_000;
assign outclock= (q == 0) ? 1:0;
always @(*)
begin
 case (switch [1:0])
  2'b00: d = 22'd840_000;
  2'b01: d = 22'd420_000; //22'd1680_000
  2'b10: d = 22'd2360_000;
  2'b11: d = 22'd4720_000;
  default: d = 22'd840_000;
 endcase
end
 
 
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


module LFSR(reset, clk, ooo);
    input reset;
    input clk;
  output [1:0] ooo;
    reg [3:0] out;
  assign feedback = ~(out[3] ^ out[2]);
  assign ooo = out[1:0];
    always @(posedge clk) begin
        if (reset == 1'b0)
            out <= 4'b0;
   else
    out <= {out[2:0], feedback};
    end
endmodule


module history(score1,score2,clk,reset,mux,load,outs1,outs2);
 input [3:0] score1;
 input [3:0] score2;
 input clk,reset,load;
 output [3:0] outs1;
 output [3:0] outs2;
 reg [3:0] q1,q2,q3,q4,q5,q6,q7,q8;
 reg [1:0] done;
 always @(posedge clk) begin
 if (reset == 1'b0) begin
  q1 <= 4'b0;
  q2 <= 4'b0;
  q3 <= 4'b0;
  q4 <= 4'b0;
  q5 <= 4'b0;
  q6 <= 4'b0;
  q7 <= 4'b0;
  q8 <= 4'b0;
  done <= 2'b00;
 end
 if (load) begin
  q1 <= score1;
  q2 <= score2;
  done <= 2'b01;
 end
 else if (load == 1'b1 & done == 2'b01) begin
  q3 <= score1;
  q4 <= score2;
 done <= done + 1'b1;
 end
 else if (load == 1'b1 & done == 2'b10) begin
  q5 <= score1;
  q6 <= score2;
 done <= done + 1'b1;
 end
 else if (load == 1'b1 & done == 2'b11) begin
  q7 <= score1;
  q8 <= score2;
 end
end
 always @(*)
begin
 case (mux [1:0])
		2'b00: outs1 = q1;
		2'b01: outs1 = q3;
  2'b10: outs1 = q5;
  2'b11: outs1 = q7;
		default: outs1 = q1;
	endcase
end
  always @(*)
begin
 case (mux [1:0])
  2'b00: outs2 = q2;
  2'b01: outs2 = q4;
  2'b10: outs2 = q6;
  2'b11: outs2 = q8;
		default: outs2 = q2;
	endcase
end
 
endmodule


module seven_seg_decoder(S,HEXO);
input [3:0]S;
output [6:0] HEXO;
assign HEXO[0] = (~S[3]&~S[2]&~S[1]&S[0])|(~S[3]&S[2]&~S[1]&~S[0])|(S[3]&S[2]&~S[1]&S[0])|(S[3]&~S[2]&S[1]&S[0]);
assign HEXO[1] = (S[3]&S[2]&~S[0])|(~S[3]&S[2]&~S[1]&S[0])|(S[3]&S[1]&S[0])|(S[2]&S[1]&~S[0]);
assign HEXO[2] = (S[3]&S[2]&S[1])|(S[3]&S[2]&~S[0])|(~S[3]&~S[2]&S[1]&~S[0]);
assign HEXO[3] = (~S[2]&~S[1]&S[0])|(S[2]&S[1]&S[0])|(~S[3]&S[2]&~S[1]&~S[0])|(S[3]&~S[2]&S[1]&~S[0]);
assign HEXO[4] = (~S[1]&~S[3]&S[2])|(~S[3]&S[0])|(~S[2]&~S[1]&S[0]);
assign HEXO[5] = (~S[3]&~S[2]&S[0])|(~S[3]&S[1]&S[0])|(~S[3]&~S[2]&S[1])|(S[3]&S[2]&~S[1]&S[0]);
assign HEXO[6] = (~S[1]&~S[3]&~S[2])|(~S[3]&S[2]&S[1]&S[0])|(S[3]&S[2]&~S[1]&~S[0]);
endmodule
module keyboard_tracker #(parameter PULSE_OR_HOLD = 0) (
    input clock,
  input reset,
  
  inout PS2_CLK,
  inout PS2_DAT,
  
  output w, a, s, d,
  output left, right, up, down,
  output space, enter
  );
  
  // A flag indicating when the keyboard has sent a new byte.
  wire byte_received;
  // The most recent byte received from the keyboard.
  wire [7:0] newest_byte;
    
  localparam // States indicating the type of code the controller expects
             // to receive next.
             MAKE            = 2'b00,
             BREAK           = 2'b01,
     SECONDARY_MAKE  = 2'b10,
     SECONDARY_BREAK = 2'b11,
     
     // Make/break codes for all keys that are handled by this
     // controller. Two keys may have the same make/break codes
     // if one of them is a secondary code.
     // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS 
     W_CODE = 8'h1d,
     A_CODE = 8'h1c,
     S_CODE = 8'h1b,
     D_CODE = 8'h23,
     LEFT_CODE  = 8'h6b,
     RIGHT_CODE = 8'h74,
     UP_CODE    = 8'h75,
     DOWN_CODE  = 8'h72,
     SPACE_CODE = 8'h29,
     ENTER_CODE = 8'h5a;
     
    reg [1:0] curr_state;
  
  // Press signals are high when their corresponding key is being pressed,
  // and low otherwise. They directly represent the keyboard's state.
  // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS  
    reg w_press, a_press, s_press, d_press;
  reg left_press, right_press, up_press, down_press;
  reg space_press, enter_press;
  
  // Lock signals prevent a key press signal from going high for more than one
  // clock tick when pulse mode is enabled. A key becomes 'locked' as soon as
  // it is pressed down.
  // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
  reg w_lock, a_lock, s_lock, d_lock;
  reg left_lock, right_lock, up_lock, down_lock;
  reg space_lock, enter_lock;
  
  // Output is equal to the key press wires in mode 0 (hold), and is similar in
  // mode 1 (pulse) except the signal is lowered when the key's lock goes high.
  // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
    assign w = w_press && ~(w_lock && PULSE_OR_HOLD);
    assign a = a_press && ~(a_lock && PULSE_OR_HOLD);
    assign s = s_press && ~(s_lock && PULSE_OR_HOLD);
    assign d = d_press && ~(d_lock && PULSE_OR_HOLD);
    assign left  = left_press && ~(left_lock && PULSE_OR_HOLD);
    assign right = right_press && ~(right_lock && PULSE_OR_HOLD);
    assign up    = up_press && ~(up_lock && PULSE_OR_HOLD);
    assign down  = down_press && ~(down_lock && PULSE_OR_HOLD);
    assign space = space_press && ~(space_lock && PULSE_OR_HOLD);
    assign enter = enter_press && ~(enter_lock && PULSE_OR_HOLD);
  
  // Core PS/2 driver.
  PS2_Controller #(.INITIALIZE_MOUSE(0)) core_driver(
      .CLOCK_50(clock),
    .reset(~reset),
    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT),
    .received_data(newest_byte),
    .received_data_en(byte_received)
    );
    
    always @(posedge clock) begin
      // Make is default state. State transitions are handled
        // at the bottom of the case statement below.
    curr_state <= MAKE;
    
    // Lock signals rise the clock tick after the key press signal rises,
    // and fall one clock tick after the key press signal falls. This way,
    // only the first clock cycle has the press signal high while the
    // lock signal is low.
    // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
    w_lock <= w_press;
    a_lock <= a_press;
    s_lock <= s_press;
    d_lock <= d_press;
    
    left_lock <= left_press;
    right_lock <= right_press;
    up_lock <= up_press;
    down_lock <= down_press;
    
    space_lock <= space_press;
    enter_lock <= enter_press;
    
      if (~reset) begin
        curr_state <= MAKE;
    
    // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
    w_press <= 1'b0;
    a_press <= 1'b0;
    s_press <= 1'b0;
    d_press <= 1'b0;
    left_press  <= 1'b0;
    right_press <= 1'b0;
    up_press    <= 1'b0;
    down_press  <= 1'b0;
    space_press <= 1'b0;
    enter_press <= 1'b0;
    
    w_lock <= 1'b0;
    a_lock <= 1'b0;
    s_lock <= 1'b0;
    d_lock <= 1'b0;
    left_lock  <= 1'b0;
    right_lock <= 1'b0;
    up_lock    <= 1'b0;
    down_lock  <= 1'b0;
    space_lock <= 1'b0;
    enter_lock <= 1'b0;
        end
    else if (byte_received) begin
        // Respond to the newest byte received from the keyboard,
    // by either making or breaking the specified key, or changing
    // state according to special bytes.
    case (newest_byte)
        // TODO: ADD TO HERE WHEN IMPLEMENTING NEW KEYS
            W_CODE: w_press <= curr_state == MAKE;
      A_CODE: a_press <= curr_state == MAKE;
      S_CODE: s_press <= curr_state == MAKE;
      D_CODE: d_press <= curr_state == MAKE;
      
      LEFT_CODE:  left_press  <= curr_state == MAKE;
      RIGHT_CODE: right_press <= curr_state == MAKE;
      UP_CODE:    up_press    <= curr_state == MAKE;
      DOWN_CODE:  down_press  <= curr_state == MAKE;
      
      SPACE_CODE: space_press <= curr_state == MAKE;
      ENTER_CODE: enter_press <= curr_state == MAKE;
      // State transition logic.
      // An F0 signal indicates a key is being released. An E0 signal
      // means that a secondary signal is being used, which will be
      // followed by a regular set of make/break signals.
      8'he0: curr_state <= SECONDARY_MAKE;
      8'hf0: curr_state <= curr_state == MAKE ? BREAK : SECONDARY_BREAK;
        endcase
        end
        else begin
        // Default case if no byte is received.
        curr_state <= curr_state;
    end
    end
endmodule
