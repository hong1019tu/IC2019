`timescale 1ns/10ps

module  CONV(
	input		clk,
	input		reset,
	output	reg	busy,	
	input		ready,	
			
	output reg	[11:0]	iaddr,
	input	[19:0]	idata,	
	
	output	reg 	cwr,
	output  reg	[11:0]	caddr_wr,
	output reg	[19:0] 	cdata_wr,
	
	output	reg 	crd,
	output reg	[11:0] 	caddr_rd,
	input	[19:0] 	cdata_rd,
	
	output reg	[2:0] 	csel
	);

reg input_valid;
reg [2:0] cur_state,next_state;
reg [3:0] cnt;
reg [6:0] row,col;
reg signed [19:0] buff[0:8],conv_buff,conv_kernel;
reg signed [39:0] conv;

parameter signed [19:0] kernel00 = 20'h0A89E;
parameter signed [19:0] kernel01 = 20'h092D5;
parameter signed [19:0] kernel02 = 20'h06D43;
parameter signed [19:0] kernel10 = 20'h01004;
parameter signed [19:0] kernel11 = 20'hF8F71;
parameter signed [19:0] kernel12 = 20'hF6E54;
parameter signed [19:0] kernel20 = 20'hFA6D7;
parameter signed [19:0] kernel21 = 20'hFC834;
parameter signed [19:0] kernel22 = 20'hFAC19;

wire [39:0] conv_tmp = conv_buff*conv_kernel;
wire [39:0] layer0_res = (conv[39])? 40'd0 : (conv[15])? conv + 40'h0000010000:conv;

wire [19:0] max01 = (buff[0] > buff[1])? buff[0]:buff[1];
wire [19:0] max23 = (buff[2] > buff[3])? buff[2]:buff[3];
wire [19:0] max03 = (max01 > max23)? max01:max23;

always@(posedge clk or posedge reset)
begin
	
	if(reset)
	begin
		
		busy <= 0;
		iaddr <= 12'd0;
		cwr <= 0;
		caddr_wr <= 12'hFFF;
		cdata_wr <= 20'd0;
		crd <= 0;
		caddr_rd <= 12'd0;
		csel <= 3'd0;

		input_valid <= 0;
		cur_state <= 3'd0;
		cnt <= 4'd0;
		row <= 7'd0;
		col <= 7'd0;
		
		buff[0] <= 20'd0;
		buff[1] <= 20'd0;
		buff[2] <= 20'd0;
		buff[3] <= 20'd0;
		buff[4] <= 20'd0;
		buff[5] <= 20'd0;
		buff[6] <= 20'd0;
		buff[7] <= 20'd0;
		buff[8] <= 20'd0;

		conv <= 40'h0013100000;
		conv_buff <= 20'd0;
		conv_kernel <= 20'd0;

	end
	else
	begin
		
		cur_state <= next_state;
		case(cur_state)

		3'd0: // Read input image
		begin
			
			if(ready || busy)
			begin
				
				busy <= 1;
				input_valid <= ((row > 7'd0) && (row < 7'd65) && (col > 7'd0) && (col < 7'd65))? 1:0;
				iaddr <= ((row > 7'd0) && (row < 7'd65) && (col > 7'd0) && (col < 7'd65))? ({5'd0,row - 7'd1} << 6) + {5'd0,col - 7'd1}:12'd0;
				
				cwr <= 0;
				buff[cnt - 4'd1] <= (cnt > 4'd0)? ((input_valid)? {{20{idata[19]}},idata}:40'd0) : buff[cnt - 4'd1];
				cnt <= (cnt == 4'd9)? 4'd0:cnt + 4'd1;

				if(cnt == 4'd9)
					caddr_wr <= caddr_wr + 12'd1;
				else
				begin
					caddr_wr <= caddr_wr;
					row <= ((cnt == 4'd2) || (cnt == 4'd5))? row + 7'd1 : ((cnt == 4'd8)? ((col == 7'd65)? row - 7'd1:row - 7'd2) : row);
					col <= ((cnt == 4'd2) || (cnt == 4'd5))? col - 7'd2 : ((cnt == 4'd8)? ((col == 7'd65)? 7'd0:col - 7'd1) : col + 7'd1);
				end

			end

		end

		3'd1: // Compute convolution
		begin

			cnt <= (cnt == 4'd9)? 4'd0:cnt + 4'd1;
			conv <= (cnt == 4'd0)? 40'h0013100000 : conv + conv_tmp;
			
			case(cnt)

			4'd0:
			begin
				conv_buff <= buff[0];
				conv_kernel <= kernel00;
			end

			4'd1:
			begin
				conv_buff <= buff[1];
				conv_kernel <= kernel01;
			end

			4'd2:
			begin
				conv_buff <= buff[2];
				conv_kernel <= kernel02;
			end

			4'd3:
			begin
				conv_buff <= buff[3];
				conv_kernel <= kernel10;
			end

			4'd4:
			begin
				conv_buff <= buff[4];
				conv_kernel <= kernel11;
			end

			4'd5:
			begin
				conv_buff <= buff[5];
				conv_kernel <= kernel12;
			end

			4'd6:
			begin
				conv_buff <= buff[6];
				conv_kernel <= kernel20;
			end

			4'd7:
			begin
				conv_buff <= buff[7];
				conv_kernel <= kernel21;
			end

			4'd8:
			begin
				conv_buff <= buff[8];
				conv_kernel <= kernel22;
			end

			endcase

		end

		3'd2: // Write data to L0_MEM0
		begin
			
			cwr <= 1;
			cdata_wr <= layer0_res[35:16];
			csel <= 3'b001;
			cnt <= 4'd0;

			if(caddr_wr == 12'hFFF)
			begin
				row <= 7'd0;
				col <= 7'd0;
			end
			else
			begin
				row <= row;
				col <= col;
			end

		end

		3'd3: // Read data from L0_MEM0
		begin
			
			crd <= 1;
			csel <= 3'b001;
			caddr_rd <= ({5'd0,row} << 6) + {5'd0,col};

			cwr <= 0;
			buff[cnt - 4'd1] <= (cnt > 4'd0)? {{20{cdata_rd[19]}},cdata_rd}:buff[cnt - 4'd1];
			cnt <= cnt + 4'd1;

			if(cnt == 4'd4)
				caddr_wr <= caddr_wr + 12'd1;
			else
			begin
				row <= (cnt == 4'd1)? row + 7'd1 : ((cnt == 4'd3)? ((col == 7'd63)? row + 7'd1 : row - 7'd1) : row);
				col <= (cnt == 4'd1)? col - 7'd1 : ((col == 7'd63)? 7'd0 : col + 7'd1);
			end

		end

		3'd4: // Write data to L1_MEM0
		begin

			cwr <= 1;
			csel <= 3'b011;
			cdata_wr <= max03;
			cnt <= 4'd0;

			if(caddr_wr == 12'h400)
				busy <= 0;

		end

		endcase

	end

end

always@(*)
begin
	
	case(cur_state)

	3'd0: // Read input image
	begin
		if(cnt == 4'd9)
			next_state = 3'd1;
		else
			next_state = 3'd0;
	end

	3'd1: // Compute convolution
	begin
		if(cnt == 4'd9)
			next_state = 3'd2;
		else
			next_state = 3'd1;
	end

	3'd2: // Write data to L0_MEM0
	begin
		if(caddr_wr == 12'hFFF)
			next_state = 3'd3;
		else
			next_state = 3'd0;
	end

	3'd3: // Read data from L0_MEM0
	begin
		if(cnt == 4'd4)
			next_state = 3'd4;
		else
			next_state = 3'd3;
	end

	3'd4: // Write data to L1_MEM0
	begin
		if(caddr_wr == 12'h400)
			next_state = 3'd0;
		else
			next_state = 3'd3;
	end

	default:
		next_state = 3'd0;

	endcase

end



endmodule

