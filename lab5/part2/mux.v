module mux(SW, HEX0, KEY);
	input [0:0] KEY;
	input [9:0] SW; 
	output [6:0] HEX0;
	
	wire [3:0] cout;
	
	counter c0(SW[2], SW[7:4], SW[9], KEY[0], SW[3], SW[1:0], cout);
	seven_seg_decoder s1(cout, HEX0);

endmodule


module counter(enable, load, par_load, clk, reset_n, switch, out);
	input clk, enable, par_load, reset_n;
	input [1:0] switch;
	input [3:0] load;
	output [3:0] out;
	
	wire [27:0] out1hz, out05hz, out025hz, defhz;
	reg cenable;
	


	always @(*)
		begin
			case(switch)
				2'b00: cenable = enable;
				2'b01: cenable = (out1hz == 0) ? 1 : 0;
				2'b10: cenable = (out05hz == 0) ? 1 : 0;
				2'b11: cenable = (out025hz == 0) ? 1 : 0;
				default: cenable = (defhz == 0) ? 1 : 0;
			endcase
		end
		
	displaycounter d(cenable, load, par_load, clk, reset_n, out);


ratedivider h1hz(
.enable(enable), 
.load({28'd0010111110101111000010000000}), 
.clk(clk), 
.reset_n(reset_n), 
.q(out1hz));

ratedivider h05hz(
.enable(enable), 
.load({28'd101111101011110000100000000}), 
.clk(clk), 
.reset_n(reset_n), 
.q(out05hz));

ratedivider h025hz(
.enable(enable), 
.load({28'd1011111010111100001000000000}), 
.clk(clk), 
.reset_n(reset_n), 
.q(out025hz));

ratedivider def(
.enable(enable), 
.load({28'b0000000000000000000000000011}), 
.clk(clk), 
.reset_n(reset_n), 
.q(defhz));
endmodule


module displaycounter(enable, load, par_load, clk, reset_n, q);
	input enable, clk, par_load, reset_n;
	input [3:0] load;
	output reg [3:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			q <= 4'b0000;
		else if (par_load == 1'b1)
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 4'b1111)
					q <= 4'b0000;
				else
					q <= q + 1'b1;
			end
	end
endmodule


module ratedivider(enable, load, clk, reset_n, q);
	input enable, clk, reset_n;
	input [27:0] load;
	output reg [27:0] q;
	
	always @(posedge clk)
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
