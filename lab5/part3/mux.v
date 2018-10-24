module mux(LEDR, SW, KEY);
    input [8:0] SW; //2:0 switch       8. clk
    input [1:0] KEY; //1. to start     0. reset
    output [0:0] LEDR;
    morsecoder m1(
	.switch(SW[2:0]),
	.start(KEY[1]),
	.clk(SW[8]),
	.reset_n(KEY[0]),
	.out(LEDR[0]));

endmodule

module morsecoder(switch, start, clk, reset_n, out);
	input [2:0] switch;
	input [0:0] start;//0
	input [0:0] reset_n;//0
	input [0:0] clk;
	output [0:0] out;
	wire [13:0] letter;
	wire [24:0] rout;
	wire shift_enable;

	assign shift_enable = (rout == 0) ? 1 : 0;	

	reg Enable;
	
	always @(negedge start, negedge reset_n)
	begin
		if (reset_n == 0)
			begin
			Enable <= 0;
			end
		else if (start == 0)
			begin
			Enable <= 1'b1;
			end
	end
		
	ratedivider rd0(Enable, clk, reset_n, rout);
	
	shifter s0(shift_enable, letter, reset_n, clk, out);

	LUT l0(switch, letter);

endmodule

module shifter(enable, letter, reset_n, clk, out);
	input enable, reset_n, clk;
	input [13:0] letter;
	output reg out;
	
	reg [13:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 0)
			begin
			out <= 0;
			q <= letter;
			end
		else if (enable == 1)
			begin
			out <= q[0];
			q <= q >> 1'b1;
			end

	end

endmodule

module ratedivider(enable, clk, reset_n, q);
	input enable, clk, reset_n;
	wire [24:0] load;

	assign load = 25'b0000000000000000000000001;
	output reg [24:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= load;
				else
					q <= q - 1'b1;
			end
	end
endmodule




module LUT(select, Lutout);
input [2:0] select;
output [13:0] Lutout;

reg [13:0] Lutout;
always @(*)
begin
	case (select [2:0])
		3'b000: Lutout = {5'b10101,9'b0};
		3'b001: Lutout = {3'b111,11'b0};
		3'b010: Lutout = {7'b1010111,7'b0};
		3'b011: Lutout = {9'b101010111,5'b0};
		3'b100: Lutout = {9'b101110111,5'b0};
		3'b101: Lutout = {14'b11101010111000};
		3'b110: Lutout = {14'b11101011101110};
		3'b111: Lutout = {14'b11101110101000};
		default: Lutout = 0;
	endcase
end
endmodule

