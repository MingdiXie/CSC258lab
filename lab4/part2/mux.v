module mux(LEDR, SW, KEY, HEX0, HEX4, HEX5);
    input [9:0] SW;
    input [0:0] KEY;
    output [7:0] LEDR;
    output [6:0] HEX0;
    output [6:0] HEX4;
    output [6:0] HEX5;
    wire [3:0] B;
    wire [7:0] Aluo;
    wire [7:0] lifeistough;

    assign B [3:0] = lifeistough [3:0];
    assign LEDR[7:0] = lifeistough;
    ALU u0(SW[3:0], B[3:0], SW[7:5], Aluo[7:0], HEX0[6:0]);
    register a1(Aluo[7:0], SW[9], KEY[0], lifeistough[7:0]);
	

seven_seg_decoder s4(
	.S(LEDR[3:0]), 
	.HEXO(HEX4));
			

seven_seg_decoder s5(
	.S(LEDR[7:4]), 
	.HEXO(HEX5));	

endmodule

module register(d, reset_n, clock, q);
input reset_n, clock;
input [7:0] d;
output [7:0] q;
reg [7:0] q;
always @(posedge clock)
	begin
	if (reset_n == 1'b0)
	q <= 8'b00000000;
	else
	q <= d;
end
endmodule

		
module ALU(A, B, select, Aluout, outh0);
input [3:0] A;
input [3:0] B; 
input [2:0] select;
output [7:0] Aluout;
output [6:0] outh0;
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
		3'b010: Aluout = A[3:0] + B[3:0];
		3'b011: Aluout = {A[3:0]|B[3:0] ,A[3:0]^B[3:0]};
		3'b100: Aluout = {7'b0000000,A[0] | A[1] | A[2] | A[3] | B[0] | B[1] | B[2] | B[3]};
		3'b101: Aluout = B << A;
		3'b110: Aluout = B >> A;
		3'b111: Aluout = A[3:0] * B[3:0];
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
	.B(B[3:0]),
	.cin(w20),	
	.S(sum2),
	.cout(carry2));


// HEX0 to be value of A
seven_seg_decoder s0(
	.S(A[3:0]), 
	.HEXO(outh0));
		
	
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

