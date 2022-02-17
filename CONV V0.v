
`timescale 1ns/10ps

module  CONV(clk,reset,busy,ready,iaddr,idata,cwr,caddr_wr,cdata_wr,crd,caddr_rd,cdata_rd,csel);
input		clk;
input		reset;
output reg	busy;	
input		ready;	
output reg 	[11:0] iaddr;
input		[19:0]idata;	
output reg 	cwr;
output reg 	[11:0] caddr_wr;
output reg	[19:0] cdata_wr;
output reg 	crd;
output reg 	[11:0] caddr_rd;
input	 	[19:0] cdata_rd;
output reg 	[2:0]  csel;

reg [12:0]x,y,x1,y1;
reg signed [19:0]a,b;
reg signed [39:0]c;
reg  signed [39:0] test;
reg [2:0]state;//0:edge 1:else 2:x y
reg [3:0]load;
reg [11:0]x11,y11;
reg [11:0]x2,y2;
reg [2:0]state2;
reg [2:0]load2;
reg mode;

always @(posedge clk or posedge reset) begin
	if(reset) begin
		busy <= 1'd0;
		iaddr <= 12'd0;
		caddr_wr <= 12'd0;
		cdata_wr <= 20'd0;
		caddr_rd <= 12'd0;
		crd <= 1'd0;
		cwr <= 1'd0;
		csel <= 3'd0;
		x <= -13'd1;
		y <= 13'd0;
		state <= 3'd2;
		load <= 4'd0;
		x1 <= 13'd0;
		y1 <= 13'd0;
		mode <= 1'd0;
		x11 <= 12'd0;
		y11 <= 12'd0;
		x2 <= -12'd2;
		y2 <= 12'd0;
		state2 <= 3'd1;
		load2 <= 3'd0;
		a <= 20'd0;
		b <= 20'd0;
		c <= 40'h013100000;
	end
		else begin
		if (mode == 1'd0) begin
			if (ready == 1'd1) begin
				busy <= 1'd1;
			end
			else if(ready == 1'd0 && busy == 1'd1) begin
				csel <= 3'd1;//
				case (state)
				3'd0 :begin//edge
					load <= load + 4'd1;
					if(x1 == 13'd0 && y1 == 13'd0)begin
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 + (y1 << 6);	
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd1) + (y1 << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hF6E54;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hFC834;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							a <= idata;
							b <= 20'hFAC19;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							c <= c + test;
						end
						else if (load == 4'd7) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd8)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(x1 == 13'd63 && y1 == 13'd0)begin
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= (x1 - 13'd1)+ (y1 << 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd0) + (y1 << 6);
							a <= idata;
							b <= 20'h01004;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 - 13'd1) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hFA6D7;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							a <= idata;
							b <= 20'hFC834;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							c <= c + test;
						end
						else if (load == 4'd7) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd8)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(x1 == 13'd0 && y1 == 13'd63)begin
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 + ((y1 - 13'd1)<< 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd1) + ((y1 - 13'd1) << 6);
							a <= idata;
							b <= 20'h092D5;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h06D43;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							a <= idata;
							b <= 20'hF6E54;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							c <= c + test;
						end
						else if (load == 4'd7) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd8)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(x1 == 13'd63 && y1 == 13'd63)begin
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 - 13'd1 + ((y1 - 13'd1) << 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd0) + ((y1 - 13'd1) << 6);
							a <= idata;
							b <= 20'h0A89E;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 - 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h092D5;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h01004;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							c <= c + test;
						end
						else if (load == 4'd7) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd8)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(y1 == 13'd0)begin
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 - 13'd1 + ((y1 + 13'd0) << 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h01004;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 - 13'd1) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hF6E54;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hFA6D7;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hFC834;
							c <= c + test;
						end
						else if (load == 4'd7) begin
							a <= idata;
							b <= 20'hFAC19;
							c <= c + test;
						end
						else if (load == 4'd8) begin
							c <= c + test;
						end
						else if (load == 4'd9) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd10)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(x1 == 13'd63)begin//right
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 - 13'd1 + ((y1 - 13'd1) << 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd0) + ((y1 - 13'd1) << 6);
							a <= idata;
							b <= 20'h0A89E;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 - 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h092D5;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h01004;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							iaddr <= (x1 - 13'd1) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hFA6D7;
							c <= c + test;
						end
						else if (load == 4'd7) begin
							a <= idata;
							b <= 20'hFC834;
							c <= c + test;
						end
						else if (load == 4'd8) begin
							c <= c + test;
						end
						else if (load == 4'd9) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd10)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(y1 == 13'd63)begin //down
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 - 13'd1 + ((y1 - 13'd1) << 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd0) + ((y1 - 13'd1) << 6);
							a <= idata;
							b <= 20'h0A89E;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 + 13'd1) + ((y1 - 13'd1) << 6);
							a <= idata;
							b <= 20'h092D5;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 - 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h06D43;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h01004;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd7) begin
							a <= idata;
							b <= 20'hF6E54;
							c <= c + test;
						end
						else if (load == 4'd8) begin
							c <= c + test;
						end
						else if (load == 4'd9) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd10)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
					else if(x1 == 13'd0)begin//left
						if(load == 4'd0)begin
							a <= 20'd0;
							b <= 20'd0;
						end
						else if (load == 4'd1) begin
							iaddr <= x1 + 13'd0 + ((y1 - 13'd1) << 6);
						end
						else if (load == 4'd2) begin
							iaddr <= (x1 + 13'd1) + ((y1 - 13'd1) << 6);
							a <= idata;
							b <= 20'h092D5;
							c <= c + test;
						end
						else if (load == 4'd3) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'h06D43;
							c <= c + test;
						end
						else if (load == 4'd4) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd0) << 6);
							a <= idata;
							b <= 20'hF8F71;
							c <= c + test;
						end
						else if (load == 4'd5) begin
							iaddr <= (x1 + 13'd0) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hF6E54;
							c <= c + test;
						end
						else if (load == 4'd6) begin
							iaddr <= (x1 + 13'd1) + ((y1 + 13'd1) << 6);
							a <= idata;
							b <= 20'hFC834;
							c <= c + test;
						end
						else if (load == 4'd7) begin
							a <= idata;
							b <= 20'hFAC19;
							c <= c + test;
						end
						else if (load == 4'd8) begin
							c <= c + test;
						end
						else if (load == 4'd9) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd10)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
				end
				3'd1:begin//else
					load <= load + 4'd1;
					if(load == 4'd0)begin
						iaddr <= (x1 - 13'd1) + ((y1 - 13'd1) << 6);
						a <= 20'd0;
						b <= 20'd0;
					end
					else if(load == 4'd1) begin
						iaddr <= (x1 + 13'd0) + ((y1 - 13'd1) << 6);
						a <= idata;
						b <= 20'h0A89E;
						c <= c + test;
					end
					else if(load == 4'd2) begin
						iaddr <= (x1 + 13'd1) + ((y1 - 13'd1) << 6);
						a <= idata;
						b <= 20'h092D5;
						c <= c + test;
					end
					else if(load == 4'd3) begin
						iaddr <= (x1 - 13'd1) + ((y1 + 13'd0) << 6);
						a <= idata;
						b <= 20'h06D43;
						c <= c + test;
					end
					else if(load == 4'd4) begin
						iaddr <= (x1 + 13'd0) + ((y1 + 13'd0) << 6);
						a <= idata;
						b <= 20'h01004;
						c <= c + test;
					end
					else if(load == 4'd5) begin
						iaddr <= (x1 + 13'd1) + ((y1 + 13'd0) << 6);
						a <= idata;
						b <= 20'hF8F71;
						c <= c + test;
					end
					else if(load == 4'd6) begin
						iaddr <= (x1 - 13'd1) + ((y1 + 13'd1) << 6);
						a <= idata;
						b <= 20'hF6E54;
						c <= c + test;
					end
					else if(load == 4'd7) begin
						iaddr <= (x1 + 13'd0) + ((y1 + 13'd1) << 6);
						a <= idata;
						b <= 20'hFA6D7;
						c <= c + test;
					end
					else if(load == 4'd8) begin
						iaddr <= (x1 + 13'd1) + ((y1 + 13'd1) << 6);
						a <= idata;
						b <= 20'hFC834;
						c <= c + test;
					end
					else if(load == 4'd9) begin
						a <= idata;
						b <= 20'hFAC19;
						c <= c + test;
					end
					else if (load == 4'd10) begin
						c <= c + test;
					end
					else if (load == 4'd11) begin
							if(c[39] == 1'd0)begin
								if(c[15] == 1'b1) begin
									c[35:15] <= (c[35:15] + 21'd1); 
								end
							end
							else c[35:15] <= 0;
						end
						else if(load == 4'd12)begin
							cwr <= 1'd1;
							cdata_wr <= c[35:16];
							caddr_wr <= x1 + (y1 << 6);
							load <= 4'd0;
							state <= 3'd2;
							c <= 40'h013100000;
						end
					end
				3'd2:begin//change_xy
					if (x == 13'd64 && y == 13'd63)begin	
						mode <= 1'd1;
							
					end
					else if (y != 13'd63 && x == 13'd63) begin
						y <= y + 13'd1;
						x <= 13'd0;
					end
					else
						x <= x + 13'd1;
						x1 <= x;
						y1 <= y;
						if(x == -13'd1)begin
							load <= 4'd0;
						end
						else if (x == 13'd0||x==13'd63||y==13'd0||y==13'd63) begin
							state <= 3'd0;
						end
						else 
							state <= 3'd1;
					end
				endcase
			end
		end
		else if(mode)begin
			case (state2)
			3'd0:begin
				load2 <= load2 + 3'd1;
				if(load2 == 3'd0)begin
					csel <= 3'd1;
					crd <= 1'd1;
					cwr <= 1'd0;
					caddr_rd <= (x11) + (y11 << 6);
				end
				else if(load2 == 3'd1)begin
					caddr_rd <= (x11) + 12'd1 + (y11 << 6 );
					a <= cdata_rd;
				end
				else if(load2 == 3'd2)begin
					caddr_rd <= x11 + 12'd0 + ((y11 +12'd1) << 6 );
					a <= (a > cdata_rd)?a:cdata_rd;
				end
				else if(load2 == 3'd3)begin
					caddr_rd <= x11 + 12'd1 + ((y11 + 12'd1) << 6 );
					a <= (a > cdata_rd)?a:cdata_rd;
				end
				else if(load2 == 3'd4)begin
					a <= (a > cdata_rd)?a:cdata_rd;
				end
				else begin
					csel <= 3'd3;
					state2 <= 3'd1;
					cwr <= 1'd1;
					caddr_wr <= (x11 >> 1) + (y11 << 4);
					cdata_wr <= a;
					load2 <= 3'd0;
				end
			end
			default:begin
				if(x2 == 12'd64 && y2 == 12'd62)begin
					busy <= 1'd0;
				end
				else if (x2 == 12'd62 && y2 != 12'd62) begin
					x2 <= 12'd0;
					y2 <= y2 + 12'd2;
				end
				else begin
					x2 <= x2 + 12'd2;
				end
				x11 <= x2;
				y11 <= y2;
				if(x2 == -12'd2)begin
					load2 <= 3'd0;
				end
				else begin
					state2 <= 3'd0;
				end
			end
			endcase
		end
	end
end
always @(*) begin
	test = a * b;
end
endmodule




