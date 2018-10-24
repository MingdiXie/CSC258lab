//SW[2:0] data inputs
//SW[9] select signal

//LEDR[0] output display

module mux(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;
    wire w1;
    wire w2;
    mux2to1 u0(
        .a(SW[0]),
        .b(SW[1]),
        .s(SW[9]),
        .m(w1)
        );
    mux2to1 u1(
        .a(SW[2]),
        .b(SW[3]),
        .s(SW[9]),
        .m(w2)
        );
    mux2to1 u2(
        .a(w1),
        .b(w2),
        .s(SW[8]),
        .m(LEDR[0])
        );
endmodule

module mux2to1(a, b, s, m);
    input a; //selected when s is 0
    input b; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & b | ~s & a;
    // OR
    // assign m = s ? y : x;

endmodule
