
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
reg [12:0] x,y;
reg [3:0] load;
reg signed [19:0] a,b;
reg signed [39:0] mul,cal;
reg [2:0] cur,nxt;//0:corner 1:edge 2:other 3:max-pool 4:start
reg layer0_finish;
always @(*)begin
	if(cur == 4)begin
		if(ready == 1)begin
			nxt <= 0;
		end
		else begin
			nxt <= 4;
		end
	end
	else if(cur == 3)begin
		nxt <= 3;
	end
	else begin
		if (layer0_finish == 1) begin
			nxt <= 3;
		end
		else if((x == 0 && y != 63 && y != 0)||(x == 63 && y != 63 && y != 0)||(y == 0 && x != 63 && x != 0)||(y == 63 && x != 63 && x != 0) )begin
			nxt <= 1;
		end
		else if ((x == 0 && y == 0)||(x == 0 && y == 63)||(x == 63 && y == 0)||(x == 63 && y == 63)) begin
			nxt <= 0;
		end
		else begin
			nxt <= 2;
		end
	end
end
always @(*)begin
	mul = a*b;
end
always @(posedge clk or posedge reset) begin
	if (reset) begin
		x <= 0;
		y <= 0;
	    cur <= 4; 
		busy <= 0;
		csel <= 0;
		a <= 0;
		b <= 0;
		load <= 0;
		cal <= 40'h013100000;
		layer0_finish <= 0;
	end
	else begin
		cur <= nxt;
		case(cur)
			4:begin
				
			end 
			0:begin
				load <= load + 1; 
				case(x + (y<<6))
					0:begin
						busy <= 1;
						if(load == 0)begin
							iaddr <= x + (y << 6);
						end
						else if(load == 1) begin
							a <= idata;
							b <= 20'hF8F71;
							iaddr <= x+1 + (y << 6);
						end
						else if(load == 2)begin
							a <= idata;
							b <= 20'hF6E54;
							cal <= cal + mul;
							iaddr <= x + ((y+1) << 6);
						end
						else if(load == 3) begin
							a <= idata;
							b <= 20'hFC834;
							cal <= cal + mul;
							iaddr <= (x+1) + ((y+1) << 6);
						end
						else if(load == 4) begin
							a <= idata;
							b <= 20'hFAC19;
							cal <= cal + mul;
						end
						else if (load == 5) begin
							cal <= cal + mul; 
						end
						if (load == 6) begin
							cwr <= 1;
							csel <= 1;
							caddr_wr <= x + (y<<6);
							x <= x + 1;
							load <= 0;
							cal <= 40'h013100000;
							if(cal[39] == 0)begin
								if(cal[15] == 1)begin
									cdata_wr <= cal[35:16]+1;
								end
								else begin
									cdata_wr <= cal[35:16];
								end
							end
							else begin
								cdata_wr <= 0;
							end
						end
					end
					63:begin
						busy <= 1;
						if(load == 0)begin
							iaddr <= x-1 + (y << 6);
						end
						else if(load == 1) begin
							a <= idata;
							b <= 20'h01004;
							iaddr <= x + (y << 6);
						end
						else if(load == 2)begin
							a <= idata;
							b <= 20'hF8F71;
							cal <= cal + mul;
							iaddr <= x-1 + ((y+1) << 6);
						end
						else if(load == 3) begin
							a <= idata;
							b <= 20'hFA6D7;
							cal <= cal + mul;
							iaddr <= (x) + ((y+1) << 6);
						end
						else if(load == 4) begin
							a <= idata;
							b <= 20'hFC834;
							cal <= cal + mul;
						end
						else if (load == 5) begin
							cal <= cal + mul;
						end
						if (load == 6) begin
							caddr_wr <= x + (y<<6);
							cal <= 40'h013100000;
							x <= 0;
							y <= y + 1;
							load <= 0; 
							if(cal[39] == 0)begin
								if(cal[15] == 1)begin
									cdata_wr <= cal[35:16]+1;
								end
								else begin
									cdata_wr <= cal[35:16];
								end
							end
							else begin
								cdata_wr <= 0;
							end
						end
					end
					4032:begin
						busy <= 1;
						if(load == 0)begin
							iaddr <= x + ((y-1) << 6);
						end
						else if(load == 1) begin
							a <= idata;
							b <= 20'h092D5;
							iaddr <= x+1 + ((y-1) << 6);
						end
						else if(load == 2)begin
							a <= idata;
							b <= 20'h06D43;
							cal <= cal + mul;
							iaddr <= x + ((y) << 6);
						end
						else if(load == 3) begin
							a <= idata;
							b <= 20'hF8F71;
							cal <= cal + mul;
							iaddr <= (x+1) + ((y) << 6);
						end
						else if(load == 4) begin
							a <= idata;
							b <= 20'hF6E54;
							cal <= cal + mul;
						end
						else if (load == 5) begin
							cal <= cal + mul;
						end
						if (load == 6) begin
							caddr_wr <= x + (y<<6);
							cal <= 40'h013100000;
							x <= x + 1;
							load <= -1;
							if(cal[39] == 0)begin
								if(cal[15] == 1)begin
									cdata_wr <= cal[35:16]+1;
								end
								else begin
									cdata_wr <= cal[35:16];
								end
							end
							else begin
								cdata_wr <= 0;
							end
						end
					end
					4095:begin
						if(load == 0)begin
							busy <= 1;
							iaddr <= x-1 + ((y-1) << 6);
						end
						else if(load == 1) begin
							a <= idata;
							b <= 20'h0A89E;
							iaddr <= x + ((y-1) << 6);
						end
						else if(load == 2)begin
							a <= idata;
							b <= 20'h092D5;
							cal <= cal + mul;
							iaddr <= x-1 + ((y) << 6);
						end
						else if(load == 3) begin
							a <= idata;
							b <= 20'h01004;
							cal <= cal + mul;
							iaddr <= (x) + ((y) << 6);
						end
						else if(load == 4) begin
							a <= idata;
							b <= 20'hF8F71;
							cal <= cal + mul;
						end
						else if (load == 5) begin
							cal <= cal + mul;
						end
						if (load == 6) begin
							caddr_wr <= x + (y<<6);
							cal <= 40'h013100000;
							layer0_finish <= 1;
							x <= 0;
							y <= 0;
							load <= -1;
							if(cal[39] == 0)begin
								if(cal[15] == 1)begin
									cdata_wr <= cal[35:16]+1;
								end
								else begin
									cdata_wr <= cal[35:16];
								end
							end
							else begin
								cdata_wr <= 0;
							end
						end
					end
				endcase
			end
			1:begin//edge
				busy <= 1;
				load <= load + 1;
				if(x == 0)begin
					if(load == 0)begin
						iaddr <= x + ((y-1) << 6);
					end
					else if(load == 1) begin
						a <= idata;
						b <= 20'h092D5;
						iaddr <= x+1 + ((y-1) << 6);
					end
					else if(load == 2)begin
						a <= idata;
						b <= 20'h06D43;
						cal <= cal + mul;
						iaddr <= x + ((y) << 6);
					end
					else if(load == 3) begin
						a <= idata;
						b <= 20'hF8F71;
						cal <= cal + mul;
						iaddr <= (x+1) + ((y) << 6);
					end
					else if (load == 4) begin
						a <= idata;
						b <= 20'hF6E54;
						cal <= cal + mul;
						iaddr <= (x) + ((y+1) << 6);
					end
					else if (load == 5) begin
						a <= idata;
						b <= 20'hFC834;
						cal <= cal + mul;
						iaddr <= (x) + ((y+1) << 6);
					end
					else if(load == 6) begin
						a <= idata;
						b <= 20'hFAC19;
						cal <= cal + mul;
					end
					else if (load == 7) begin
						cal <= cal + mul;
					end
					if (load == 8) begin
						caddr_wr <= x + (y<<6);
						cal <= 40'h013100000;
						x <= x + 1;
						load <= 0;
						if(cal[39] == 0)begin
							if(cal[15] == 1)begin
								cdata_wr <= cal[35:16]+1;
							end
							else begin
								cdata_wr <= cal[35:16];
							end
						end
						else begin
							cdata_wr <= 0;
						end
					end
				end
				else if (x == 63) begin
					if(load == 0)begin
						iaddr <= x-1 + ((y-1) << 6);
					end
					else if(load == 1) begin
						a <= idata;
						b <= 20'h0A89E;
						iaddr <= x + ((y-1) << 6);
					end
					else if(load == 2)begin
						a <= idata;
						b <= 20'h092D5;
						cal <= cal + mul;
						iaddr <= x-1 + ((y) << 6);
					end
					else if(load == 3) begin
						a <= idata;
						b <= 20'h01004;
						cal <= cal + mul;
						iaddr <= (x) + ((y) << 6);
					end
					else if (load == 4) begin
						a <= idata;
						b <= 20'hF8F71;
						cal <= cal + mul;
						iaddr <= (x-1) + ((y+1) << 6);
					end
					else if (load == 5) begin
						a <= idata;
						b <= 20'hFA6D7;
						cal <= cal + mul;
						iaddr <= (x) + ((y+1) << 6);
					end
					else if(load == 6) begin
						a <= idata;
						b <= 20'hFC834;
						cal <= cal + mul;
					end
					else if (load == 7) begin
						cal <= cal + mul;
					end
					if (load == 8) begin
						caddr_wr <= x + (y<<6);
					end
					else if (load == 9) begin
						cal <= 40'h013100000;
						x <= 0;
						y <= y + 1;
						load <= 0; 
						if(cal[39] == 0)begin
							if(cal[15] == 1)begin
								cdata_wr <= cal[35:16]+1;
							end
							else begin
								cdata_wr <= cal[35:16];
							end
						end
						else begin
							cdata_wr <= 0;
						end
					end
				end
				else if (y == 0) begin
					if(load == 0)begin
						iaddr <= x-1 + ((y) << 6);
					end
					else if(load == 1) begin
						a <= idata;
						b <= 20'h01004;
						iaddr <= x + ((y) << 6);
					end
					else if(load == 2)begin
						a <= idata;
						b <= 20'hF8F71;
						cal <= cal + mul;
						iaddr <= x+1 + ((y) << 6);
					end
					else if(load == 3) begin
						a <= idata;
						b <= 20'hF6E54;
						cal <= cal + mul;
						iaddr <= (x-1) + ((y+1) << 6);
					end
					else if (load == 4) begin
						a <= idata;
						b <= 20'hFA6D7;
						cal <= cal + mul;
						iaddr <= (x) + ((y+1) << 6);
					end
					else if (load == 5) begin
						a <= idata;
						b <= 20'hFC834;
						cal <= cal + mul;
						iaddr <= (x+1) + ((y+1) << 6);
					end
					else if(load == 6) begin
						a <= idata;
						b <= 20'hFAC19;
						cal <= cal + mul;
					end
					else if (load == 7) begin
						cal <= cal + mul;
					end
					if (load == 8) begin
						caddr_wr <= x + (y<<6);
					end
					else if (load == 9) begin
						cal <= 40'h013100000;
						if(x!=63)begin
							x <= x + 1;
						end
						else begin
							x <= 0;
							y <= y + 1;
						end
						load <= 0;
						if(cal[39] == 0)begin
							if(cal[15] == 1)begin
								cdata_wr <= cal[35:16]+1;
							end
							else begin
								cdata_wr <= cal[35:16];
							end
						end
						else begin
							cdata_wr <= 0;
						end
					end
				end
				else if (y == 63) begin
					if(load == 0)begin
						iaddr <= x-1 + ((y-1) << 6);
					end
					else if(load == 1) begin
						a <= idata;
						b <= 20'h0A89E;
						iaddr <= x + ((y-1) << 6);
					end
					else if(load == 2)begin
						a <= idata;
						b <= 20'h092D5;
						cal <= cal + mul;
						iaddr <= x+1 + ((y-1) << 6);
					end
					else if(load == 3) begin
						a <= idata;
						b <= 20'h06D43;
						cal <= cal + mul;
						iaddr <= (x-1) + ((y) << 6);
					end
					else if (load == 4) begin
						a <= idata;
						b <= 20'h01004;
						cal <= cal + mul;
						iaddr <= (x) + ((y) << 6);
					end
					else if (load == 5) begin
						a <= idata;
						b <= 20'hF8F71;
						cal <= cal + mul;
						iaddr <= (x+1) + ((y) << 6);
					end
					else if(load == 6) begin
						a <= idata;
						b <= 20'hF6E54;
						cal <= cal + mul;
					end
					else if (load == 7) begin
						cal <= cal + mul;
					end
					if (load == 8) begin
						caddr_wr <= x + (y<<6);
					end
					else if (load == 9) begin
						cal <= 40'h013100000;
						x <= x + 1;
						load <= 0;
						if(cal[39] == 0)begin
							if(cal[15] == 1)begin
								cdata_wr <= cal[35:16]+1;
							end
							else begin
								cdata_wr <= cal[35:16];
							end
						end
						else begin
							cdata_wr <= 0;
						end
					end
				end
			end
			2:begin
				busy <= 1;
				load <= load + 1;
				if(load == 0)begin
					iaddr <= x-1 + ((y-1) << 6);
				end
				else if(load == 1) begin
					a <= idata;
					b <= 20'h0A89E;
					iaddr <= x + ((y-1) << 6);
				end
				else if(load == 2)begin
					a <= idata;
					b <= 20'h092D5;
					cal <= cal + mul;
					iaddr <= x+1 + ((y-1) << 6);
				end
				else if(load == 3) begin
					a <= idata;
					b <= 20'h06D43;
					cal <= cal + mul;
					iaddr <= (x-1) + ((y) << 6);
				end
				else if (load == 4) begin
					a <= idata;
					b <= 20'h01004;
					cal <= cal + mul;
					iaddr <= (x) + ((y) << 6);
				end
				else if (load == 5) begin
					a <= idata;
					b <= 20'hF8F71;
					cal <= cal + mul;
					iaddr <= (x+1) + ((y) << 6);
				end
				else if (load == 6) begin
					a <= idata;
					b <= 20'hF6E54;
					cal <= cal + mul;
					iaddr <= (x-1) + ((y+1) << 6);
				end
				else if (load == 7) begin
					a <= idata;
					b <= 20'hFA6D7;
					cal <= cal + mul;
					iaddr <= (x) + ((y+1) << 6);
				end
				else if (load == 8) begin
					a <= idata;
					b <= 20'hFC834;
					cal <= cal + mul;
					iaddr <= (x+1) + ((y+1) << 6);
				end
				else if(load == 9) begin
					a <= idata;
					b <= 20'hFAC19;
					cal <= cal + mul;
				end
				else if (load == 10) begin
					cal <= cal + mul;
				end
				if (load == 11) begin
					caddr_wr <= x + (y<<6);
				end
				else if (load == 12) begin
					cal <= 40'h013100000;
					x <= x + 1;
					load <= 0; 
					if(cal[39] == 0)begin
						if(cal[15] == 1)begin
							cdata_wr <= cal[35:16]+1;
						end
						else begin
							cdata_wr <= cal[35:16];
						end
					end
					else begin
						cdata_wr <= 0;
					end
				end
			end
			3:begin
				load <= load + 1;
				if(load == 0)begin
					a <= 20'h00000; 
					csel <= 1;
					crd <= 1;
					cwr <= 0;
					caddr_rd <= x + (y << 6);
				end
				else if(load == 1)begin
					caddr_rd <= x + 1 + (y << 6);
					a <= (cdata_rd > a)?cdata_rd:a;
				end
				else if(load == 2)begin
					caddr_rd <= x + ((y+1) << 6);
					a <= (cdata_rd > a)?cdata_rd:a;
				end
				else if(load == 3)begin
					caddr_rd <= x + 1 + ((y+1) << 6);
					a <= (cdata_rd > a)?cdata_rd:a;
				end
				else if(load == 4)begin
					a <= (cdata_rd > a)?cdata_rd:a;
				end
				else if (load == 5) begin
					csel <= 3;
					cwr <= 1;
					crd <= 0;
					cdata_wr <= a;
					caddr_wr <= (x >> 1) + (y<<4);
					load <= 0;
					if(x == 62 && (y!= 62 && y != 64))begin
						x <= 0;
						y <= y + 2;
					end
					else if (x == 64 && y == 62 ) begin
						busy <= 0;
					end
					else begin
						x <= x + 2;
					end
				end
			end
		endcase
	end
end
endmodule




