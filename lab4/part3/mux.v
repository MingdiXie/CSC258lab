module mux(LEDR, SW, KEY);
input [9:0]SW;
input [3:0]KEY;
output [9:0]LEDR;

shifter ss1(SW[7:0], SW[9], KEY[1], KEY[2], KEY[0] ,KEY[3], LEDR[7:0]);

endmodule

module shifter(LoadVal, reset_n, Load_n, ShiftRight, clk, ASR, out);
input [7:0]LoadVal;
input reset_n;
input Load_n;
input ShiftRight;
input ASR;
input clk;
output [7:0]out;
wire w1, w2, w3;
assign w1 = 1'b0;

mux2to1 start(
.x(w1),
.y(LoadVal[7]),
.s(ASR),
.m(w3));

shifterBit s1(
.load_val(LoadVal[7]),
.in(w3),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[7]));


shifterBit s2(
.load_val(LoadVal[6]),
.in(out[7]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[6]));


shifterBit s3(
.load_val(LoadVal[5]),
.in(out[6]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[5]));


shifterBit s4(
.load_val(LoadVal[4]),
.in(out[5]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[4]));


shifterBit s5(
.load_val(LoadVal[3]),
.in(out[4]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[3]));


shifterBit s6(
.load_val(LoadVal[2]),
.in(out[3]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[2])); 


shifterBit s7(
.load_val(LoadVal[1]),
.in(out[2]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[1]));


shifterBit s8(
.load_val(LoadVal[0]),
.in(out[1]),
.shift(ShiftRight),
.load_n(Load_n),
.clk(clk),
.reset_n(reset_n),
.out(out[0]));

endmodule
module shifterBit(load_val, in , shift, load_n, clk, reset_n, out);
input load_val;
input in;
input shift;
input load_n;
input clk;
input reset_n;
output out;
wire w1, w2, w3;

mux2to1 u1(
.x(load_val),
.y(w1),
.s(load_n), 
.m(w2));

mux2to1 u2(
.x(w3),
.y(in),
.s(shift), 
.m(w1));

flipflop u3(
.d(w2),
.reset_n(reset_n),
.clock(clk), 
.q(out));

assign w3 = out;
endmodule

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
endmodule


module flipflop(d, reset_n, clock, q);
input reset_n, clock;
input d;
output q;
reg q;
always @(posedge clock)
	begin
	if (reset_n == 1'b0)
	q <= 0;
	else
	q <= d;
end
endmodule

		


