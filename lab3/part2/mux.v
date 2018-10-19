//SW[2:0] data inputs
//SW[9] select signal

//LEDR[0] output display

module mux(LEDR, SW);
    input [8:0] SW;
    output [4:0] LEDR;
    wire w1,w2,w3,w4;
    fulladder u0(
	.A(SW[1]),
	.B(SW[2]),
	.cin(SW[0]),
	.S(LEDR[0]),
	.cout(w1)
);
    fulladder u1(
	.A(SW[3]),
	.B(SW[4]),
	.cin(w1),
	.S(LEDR[1]),
	.cout(w2)
);    
fulladder u2(
	.A(SW[5]),
	.B(SW[6]),
	.cin(w2),
	.S(LEDR[2]),
	.cout(w3)
);
    fulladder u3(
	.A(SW[7]),
	.B(SW[8]),
	.cin(w3),
	.S(LEDR[3]),
	.cout(LEDR[4])
);
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
