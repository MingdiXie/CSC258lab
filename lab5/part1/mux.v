module mux(KEY, SW, HEX0, HEX1);
    input [1:0] SW;
    input [0:0] KEY;
    output [6:0] HEX0;
    output [6:0] HEX1;
    wire [7:0] myout;
    wire [7:0] true;
kms u1(
.d(SW[0]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[0]),
.qqq(myout[0]));

kms u2(
.d(myout[0]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[1]),
.qqq(myout[1]));

kms u3(
.d(myout[1]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[2]),
.qqq(myout[2]));

kms u4(
.d(myout[2]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[3]),
.qqq(myout[3]));

kms u5(
.d(myout[3]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[4]),
.qqq(myout[4]));

kms u6(
.d(myout[4]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[5]),
.qqq(myout[5]));


kms u7(
.d(myout[5]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(true[6]),
.qqq(myout[6]));

register u8(
.d(myout[6]), 
.reset_n(SW[1]),
.clock(KEY[0]),
.q(myout[7]));
assign true[7] = myout[7];


seven_seg_decoder s1(
	.S(true[3:0]), 
	.HEXO(HEX0));

seven_seg_decoder s2(
	.S(true[7:4]), 
	.HEXO(HEX1));

endmodule


module kms(d, reset_n, clock, q, qqq);
input reset_n, clock;
input [0:0] d;
output [0:0] qqq;
output [0:0] q;
reg [0:0] q;
always @(posedge clock, negedge reset_n)
	begin
	if (reset_n == 1'b0)
	q <= 1'b0;
	else if(d == 1'b1)
	q <= ~q;
end

assign qqq = d & q;
endmodule



module register(d, reset_n, clock, q);
input reset_n, clock;
input [0:0] d;
output [0:0] q;
reg [0:0] q;
always @(posedge clock, negedge reset_n)
	begin
	if (reset_n == 1'b0)
	q <= 1'b0;
	else if(d == 1'b1)
	q <= ~q;
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

