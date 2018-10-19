module mux(LEDR, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [7:0] SW;
    input [2:0] KEY;
    output [7:0] LEDR;
    output [6:0] HEX0;
    output [6:0] HEX1;
    output [6:0] HEX2;
    output [6:0] HEX3;
    output [6:0] HEX4;
    output [6:0] HEX5;

    ALU u0(SW[7:4], SW[3:0], KEY[2:0], LEDR[7:0], HEX0[6:0], HEX1[6:0], HEX2[6:0], HEX3[6:0], HEX4[6:0], HEX5[6:0]);


endmodule

module ALU(A, B, select, Aluout, outh0, outh1, outh2, outh3, outh4, outh5);
input [3:0] A;
input [7:4] B; 
input [2:0] select;
output [7:0] Aluout;
output [6:0] outh0, outh1, outh2, outh3, outh4, outh5;
wire [3:0] w11;
wire w10, w20;
wire carry1, carry2;
wire [3:0] sum1;
wire [3:0] sum2;

assign w11 = 4'b0001;
assign w10 = 1'b0;
assign w20 = 1'b0;
reg [7:0] Aluout;

always @(*)
begin
	case (select [2:0])
		3'b000: Aluout = {carry1, sum1};
		3'b001: Aluout = {carry2, sum2};	
		3'b010: Aluout = A[3:0] + B[7:4];
		3'b011: Aluout = {A[3:0]|B[7:4] ,A[3:0]^B[7:4]};
		3'b100: Aluout = {7'b0000000,A[0] | A[1] | A[2] | A[3] | B[4] | B[5] | B[6] | B[7]};
		3'b101: Aluout = {A[3:0], B[7:4]};
		default: Aluout = 0;
	endcase
end

Rippleadder r1(
	.A(A[3:0]),
	.B(w11),
	.cin(w10),
	.S(sum1),
	.cout(carry1));

Rippleadder r2(
	.A(A[3:0]),
	.B(B[7:4]),
	.cin(w20),	
	.S(sum2),
	.cout(carry2));


// HEX1 and HEX3 is always 0.
seven_seg_decoder s1(
	.S(4'b0000), 
	.HEXO(outh1));
	
seven_seg_decoder s3(
	.S(4'b0000), 
	.HEXO(outh3));

// HEX0 to be value of B
seven_seg_decoder s0(
	.S(B[7:4]), 
	.HEXO(outh0));
//line 80

// HEX2 to be value of A	

seven_seg_decoder s2(
	.S(A[3:0]), 
	.HEXO(outh2));

// HEX4 to be value of the led output [3:0] 	
seven_seg_decoder s4(
	.S(Aluout[3:0]), 
	.HEXO(outh4));
	
// HEX5 to be value of the led output [7:4]	
seven_seg_decoder s5(
	.S(Aluout[7:4]), 
	.HEXO(outh5));

endmodule

module Rippleadder(A, B, cin, S, cout);
	input [3:0] A;
	input [3:0] B;
	input cin;
	output [3:0] S;
	output cout;
	wire [2:0] w;

fulladder u0(
	.A(A[0]),
	.B(B[0]),
	.cin(cin),
	.S(S[0]),
	.cout(w[0])
);
fulladder u1(
	.A(A[1]),
	.B(B[1]),
	.cin(w[0]),
	.S(S[1]),
	.cout(w[1])
);  
fulladder u2(
	.A(A[2]),
	.B(B[2]),
	.cin(w[1]),
	.S(S[2]),
	.cout(w[2])
);
    fulladder u3(
	.A(A[3]),
	.B(B[3]),
	.cin(w[2]),
	.S(S[3]),
	.cout(cout)
);

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


module fulladder(A, B, cin, S, cout);
	input A;
	input B;
	input cin;
	output S;
	output cout;

assign S = A ^ B ^ cin;
assign cout = A & B | cin & A| cin & B;

endmodule

