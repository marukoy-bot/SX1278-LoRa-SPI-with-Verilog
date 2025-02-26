//SX1278
//EP2C5T144C8N
//clk50Mhz	17
//~d2 led	3
//~d4 led	7
//~d5 led	9
//~btn 		144
//SPI @8MHz (CPOL = 0, CPHA = 0)

module spi_rx(
	//system
	input clk,
	input reset_n,
	
	//SPI
	output nss,
	output sck,
	output mosi,
	input miso,
	
	//data sync
	input [15:0] mosi_word,
	output [15:0] miso_word,
	input start,
	output busy
	
	//debug/simulation
	//output [7:0] o_counter,
	//output [7:0] o_delay_counter
);

reg r_nss;
reg r_sck;
reg r_mosi;

reg [15:0] r_miso_word;
reg r_busy;

reg [5:0] counter;
reg [5:0] delay_counter;

assign nss = r_nss;
assign sck = r_sck;
assign mosi = r_mosi;
assign miso_word = r_miso_word;
assign busy = r_busy;

//debug/simulation
//assign o_counter = counter;
//assign o_delay_counter = delay_counter;

always @(negedge clk or negedge reset_n) begin
	if (!reset_n) begin
		r_nss <= 1'b1;
		r_sck <= 1'b0;
		r_mosi <= 1'b0;
		
		r_miso_word <= 16'h0000;
		r_busy <= 1'b0;
		
		counter <= 0;
		delay_counter <= 0;
	end else begin
		case (counter)
			0: begin	
				r_nss <= 1'b1;
				if (delay_counter < 24) begin
					delay_counter <= delay_counter + 1;
				end else begin
					delay_counter <= 0;	
				end
				if (start) begin
					r_busy <= 1'b1;
					counter <= 1;
				end
			end
			1: begin
				r_nss <= 1'b0;
				if (delay_counter < 24) begin
					delay_counter <= delay_counter + 1;
				end else begin
					delay_counter <= 0;	
					counter <= 2;
				end
			end
			2: begin
				r_mosi <= mosi_word[15];
				
				counter <= 3;
			end
			3: begin
				r_sck <= 1'b1;
				r_miso_word[15] <= miso;
				counter <= 4;	
			end
			4: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[14];
				counter <= 5;	
			end
			5: begin
				r_sck <= 1'b1;
				r_miso_word[14] <= miso;
				counter <= 6;
			end
			6: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[13];
				counter <= 7;	
			end
			7: begin
				r_sck <= 1'b1;
				r_miso_word[13] <= miso;
				counter <= 8;
			end
			8: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[12];
				counter <= 9;	
			end
			9: begin
				r_sck <= 1'b1;
				r_miso_word[12] <= miso;
				counter <= 10;
			end
			10: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[11];
				counter <= 11;		
			end
			11: begin
				r_sck <= 1'b1;
				r_miso_word[11] <= miso;
				counter <= 12;
			end
			12: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[10];
				counter <= 13;		
			end
			13: begin
				r_sck <= 1'b1;
				r_miso_word[10] <= miso;
				counter <= 14; 
			end
			14: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[9];
				counter <= 15;	
			end
			15: begin
				r_sck <= 1'b1;
				r_miso_word[9] <= miso;
				counter <= 16;
			end
			16: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[8];
				counter <= 17;	
			end
			17: begin
				r_sck <= 1'b1;
				r_miso_word[8] <= miso;
				counter <= 18;
			end
			18: begin
				r_sck <= 1'b0;
				if (delay_counter < 24) begin
					delay_counter <= delay_counter + 1;
				end else begin
					delay_counter <= 0;	
					counter <= 19;
				end
			end	
			19: begin	
				r_mosi <= mosi_word[7];
				counter <= 20;
			end
			20: begin
				r_sck <= 1'b1;
				r_miso_word[7] <= miso;
				counter <= 21;	
			end
			21: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[6];
				counter <= 22;	
			end
			22: begin
				r_sck <= 1'b1;
				r_miso_word[6] <= miso;
				counter <= 23;
			end
			23: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[5];
				counter <= 24;	
			end
			24: begin
				r_sck <= 1'b1;
				r_miso_word[5] <= miso;
				counter <= 25;
			end
			25: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[4];
				counter <= 26;	
			end
			26: begin
				r_sck <= 1'b1;
				r_miso_word[4] <= miso;
				counter <= 27;
			end
			27: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[3];
				counter <= 28;	
			end
			28: begin
				r_sck <= 1'b1;
				r_miso_word[3] <= miso;
				counter <= 29;
			end
			29: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[2];
				counter <= 30;	
			end
			30: begin
				r_sck <= 1'b1;
				r_miso_word[2] <= miso;
				counter <= 31;	
			end
			31: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[1];
				counter <= 32;	
			end
			32: begin
				r_sck <= 1'b1;
				r_miso_word[1] <= miso;
				counter <= 33;
			end
			33: begin
				r_sck <= 1'b0;
				r_mosi <= mosi_word[0];
				counter <= 34;		
			end
			34: begin
				r_sck <= 1'b1;
				r_miso_word[0] <= miso;
				counter <= 35;
			end
			35: begin
				r_sck <= 1'b0;
				if (delay_counter < 24) begin
					delay_counter <= delay_counter + 1;
				end else begin
					delay_counter <= 0;	
					counter <= 36;
				end
			end
			36: begin
				r_nss <= 1'b1;
				if (delay_counter < 48) begin
					delay_counter <= delay_counter + 1;
				end else begin
					delay_counter <= 0;	
					r_busy <= 1'b0;
					counter <= 0;
				end
			end
			default: begin end
		endcase
	end
end	
endmodule

module clk_8MHz(
	input i_clk,
	input i_reset_n,
	output reg o_clk
);

reg [1:0] counter;

always @(posedge i_clk or negedge i_reset_n) begin
	if (!i_reset_n) begin
		counter <= 0;
		o_clk <= 0;
	end else begin
		if (counter == 2) begin
			o_clk <= ~o_clk;
			counter <= 0;	
		end else begin
			counter <= counter + 1;
		end
	end
end
endmodule

module SX1278RX(
	input clk,
	input reset_n,
	
	output nss,
	output sck,
	output mosi,
	input miso,
	input dio0,
	
	output reg [7:0] led
	
	//debug
	//output [15:0] o_miso_word,
	//output [7:0] o_state
);

wire clk8MHz;
reg start;
wire busy;

localparam 	r  = 1'b0,
			w  = 1'b1,
			RegVersion  = 7'h42,
			RegOpMode  = 7'h01,
			RegFrfMsb = 7'h06,
			RegFrfMid = 7'h07,
			RegFrfLsb = 7'h08,
			RegFifoTxBaseAddr = 7'h0e,
			RegFifoRxBaseAddr = 7'h0f,
			RegLna = 7'h0c,
			RegModemConfig3 = 7'h26,
			RegPaDac = 7'h4d,
			RegOcp = 7'h0b,
			RegPaConfig = 7'h09,
			RegIrqFlags = 7'h12,
			RegModemConfig1 = 7'h1d,
			RegFifoAddrPtr = 7'h0d,
			RegPayloadLength = 7'h22,
			RegFifo = 7'h00,
			RegRxNBytes = 7'h13,
			RegFifoRxCurrentAddr = 7'h10;
			
reg [7:0] state;
reg [15:0] mosi_word;
wire [15:0] miso_word;
reg [7:0] loop2_counter;
reg [23:0] delay_counter;

//assign o_miso_word = miso_word;
//assign o_state = state;

clk_1MHz u1(
	.i_clk(clk),
	.i_reset_n(reset_n),
	.o_clk(clk8MHz)
);

spi_rx u2(
	.clk(clk8MHz),
	.reset_n(reset_n),
	
	.nss(nss),
	.sck(sck),
	.mosi(mosi),
	.miso(miso),
	
	.mosi_word(mosi_word),
	.miso_word(miso_word),
	.start(start),
	.busy(busy)
);

	always @(posedge clk8MHz or negedge reset_n) begin
	if (!reset_n) begin
		start <= 1'b0;
		state <= 0;
		mosi_word <= 16'h0000;
		led <= 8'h00;
		delay_counter <= 0;
	end else begin
		case (state)
			0: begin
				if (!busy) begin
                    mosi_word <= {r, RegVersion, 8'h00}; // @miso {r/w, register, value}
					start <= 1'b1;
					state <= 1;
				end
			end	
			1: begin
				start <= 1'b0;
				state <= 2;
			end
			2: begin
				if (!busy) begin
					mosi_word <= {w, RegOpMode, 8'h80};
					start <= 1'b1;
					state <= 3;
				end
			end
			3: begin
				start <= 1'b0;
				state <= 4;
			end
			4: begin
				if (!busy) begin
					mosi_word <= {w, RegFrfMsb, 8'h6c};
					start <= 1'b1;
					state <= 5;
				end
			end
			5: begin
				start <= 1'b0;
				state <= 6;
			end
			6: begin
				if (!busy) begin
					mosi_word <= {w, RegFrfMid, 8'h80};
					start <= 1'b1;
					state <= 7;	
				end
			end
			7: begin
				start  <= 1'b0;
				state <= 8;	
			end
			8: begin
				if (!busy) begin
					mosi_word <= {w, RegFrfLsb, 8'h00};
					start <= 1'b1;
					state <= 9;
				end	
			end
			9: begin
				start <= 1'b0;
				state <= 10;
			end
			10: begin
				if (!busy) begin
					mosi_word <= {w, RegFifoTxBaseAddr, 8'h00};
					start <= 1'b1;
					state <= 11;
				end
			end
			11: begin
				start <= 1'b0;
				state <= 12;
			end
			12: begin 
				if (!busy) begin
					mosi_word <= {w, RegFifoRxBaseAddr, 8'h00};
					start <= 1'b1;
					state <= 13;
				end
			end
			13: begin
				start <= 1'b0;
				state <= 14;
			end
			14: begin
				if (!busy) begin
					mosi_word <= {r, RegLna, 8'h00};
					start <= 1'b1;
					state <= 15;
				end
			end
			15: begin
				start <= 1'b0;
				state <= 16;
			end
			16: begin
				if (!busy) begin
					mosi_word <= {w, RegLna, 8'h00};
					start <= 1'b1;
					state <= 17;
				end
			end
			17: begin
				start <= 1'b0;
				state <= 18;
			end
			18: begin
				if (!busy) begin
					mosi_word <= {w, RegModemConfig3, 8'h04};
					start <= 1'b1;
					state <= 19;
				end
			end
			19: begin
				start <= 1'b0;
				state <= 20;
			end
			20: begin
				if (!busy) begin
					mosi_word <= {w, RegPaDac, 8'h84};
					start  <= 1'b1;
					state <= 21;
				end
			end
			21: begin
				start <= 1'b0;
				state <= 22;
			end
			22: begin
				if (!busy) begin
					mosi_word <= {w, RegOcp, 8'h2b};
					start <= 1'b1;
					state <= 23;
				end
			end
			23: begin
				start <= 1'b0;
				state <= 24;
			end
			24: begin
				if (!busy) begin
					mosi_word <= {w, RegPaConfig, 8'h8f};
					start <= 1'b1;
					state <= 25;
				end
			end
			25: begin
				start <= 1'b0;
				state <= 26;
			end
			26: begin
				if (!busy) begin
					mosi_word <= {w, RegOpMode, 8'h81};
					start <= 1'b1;
					state <= 27;
				end
			end
			27: begin
				start <= 1'b0;
				state <= 28;
			end
			28: begin //---------------------------------loop1---------------------------------
				if (!busy) begin
					mosi_word <= {r, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 29;
				end
			end
			29: begin
				start <= 1'b0;
				state <= 30;
			end
			30: begin
				if (!busy) begin
					mosi_word <= {r, RegModemConfig1, 8'h00};
					start <= 1'b1;
					state <= 31;
				end
			end
			31: begin
				start <= 1'b0;
				state <= 32;
			end
			32: begin
				if (!busy) begin
					mosi_word <= {w, RegModemConfig1, 8'h72};
					start <= 1'b1;
					state <= 33;
				end
			end
			33: begin
				start <= 1'b0;
				state <= 34;
			end
			34: begin
				if (!busy) begin
					mosi_word <= {w, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 35;
				end
			end
			35: begin
				start = 1'b0;
				state <= 36;
			end
			36: begin
				if (!busy) begin
					mosi_word <= {r, RegOpMode, 8'h00};
					start <= 1'b1;
					state <= 37;
				end
			end
			37: begin
				start <= 1'b0;
				state <= 38;
			end
			38: begin
				if (!busy) begin
					mosi_word <= {w, RegFifoAddrPtr, 8'h00};
					start  <= 1'b1;
					state <= 39;
				end
			end
			39: begin
				start <= 1'b0;
				state <= 40;
			end
			40: begin
				if (!busy) begin
					mosi_word <= {w, RegOpMode, 8'h86};
					start <= 1'b1;
					state <= 41;
				end
			end
			41: begin
				start <= 1'b0;
				state <= 42;
			end
			42: begin//---------------------------------loop2---------------------------------
				if (!busy) begin
					mosi_word <= {r, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 43;
				end
			end
			43: begin
				start <= 1'b0;
				state <= 44;
			end
			44: begin
				if (!busy) begin
					mosi_word <= {r, RegModemConfig1, 8'h00};
					start <= 1'b1;
					state <= 45;
				end
			end
			45: begin
				start <= 1'b0;
				state <= 46;
			end
			46: begin
				if (!busy) begin
					mosi_word <= {w, RegModemConfig1, 8'h72};
					start <= 1'b1;
					state <= 47;
				end	
			end
			47: begin
				start <= 1'b0;
				state <= 48;
			end
			48: begin
				if (!busy) begin
					mosi_word <= {w, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 49;
				end
			end
			49: begin
				start <= 1'b0;
				state <= 50;
			end
			50: begin
				if (!busy) begin
					mosi_word <= {r, RegOpMode, 8'h00};
					start <= 1'b1;
					state <= 51;
				end
			end
			51: begin
				start <= 1'b0;
				state <= 52;
			end
			52: begin
				//if (loop2_counter >= 5) begin
					//loop2_counter <= 0;
					//state <= 53;
				//end else begin
					//loop2_counter <= loop2_counter + 1;
					//state <= 42;
				//end
				state <= 53;
			end
			53: begin
				if (dio0) begin
					state <= 54;
				end else begin
					state <= 28;
				end
			end
			54: begin
				if (!busy) begin
					mosi_word <= {r, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 55;
				end
			end
			55: begin
				start <= 1'b0;
				state <= 56;
			end
			56: begin
				if (!busy) begin
					mosi_word <= {r, RegModemConfig1, 8'h00};
					start <= 1'b1;
					state <= 57;
				end
			end
			57: begin
				start <= 1'b0;
				state <= 58;
			end
			58: begin
				if (!busy) begin
					mosi_word <= {w, RegModemConfig1, 8'h72};
					start <= 1'b1;
					state <= 59;
				end
			end
			59: begin
				start <= 1'b0;
				state <= 60;
			end
			60: begin
				if (!busy) begin
					mosi_word <= {w, RegIrqFlags, 8'h50};
					start <= 1'b1;
					state <= 61;
				end
			end
			61: begin
				start <= 1'b0;
				state <= 62; 
			end
			62: begin
				if (!busy) begin
					mosi_word <= {r, RegRxNBytes, 8'h00};
					start <= 1'b1;
					state <= 63;
				end
			end
			63: begin
				start <= 1'b0;
				state <= 64;
			end
			64: begin
				if (!busy) begin
					mosi_word <= {r, RegFifoRxCurrentAddr, 8'h00};
					start <= 1'b1;
					state <= 65;	
				end
			end
			65: begin
				start <= 1'b0;
				state <= 66;
			end
			66: begin
				if (!busy) begin
					mosi_word <= {w, RegFifoAddrPtr, 8'h00};
					start <= 1'b1;
					state <= 67;
				end
			end
			67: begin
				start <= 1'b0;
				state <= 68;
			end
			68: begin
				if (!busy) begin
					mosi_word <= {w, RegOpMode, 8'h81};
					start <= 1'b1;
					state <= 69;	
				end
			end
			69: begin //nice
				start <= 1'b0;
				state <= 70;
			end
			70: begin
				if (!busy) begin
					mosi_word <= {r, RegRxNBytes, 8'h00};
					start <= 1'b1;
					state <= 71;
				end
			end
			71: begin
				start <= 1'b0;
				state <= 72;
			end
			72: begin
				if (!busy) begin
					mosi_word <= {r, RegRxNBytes, 8'h00};
					start <= 1'b1;
					state <= 73;
				end
			end
			73: begin
				start <= 1'b0;
				state <= 74;
			end
			74: begin
				if (!busy) begin
					mosi_word <= {r, RegFifo, 8'h00};
					start <= 1'b1;
					state <= 75;
				end
			end
			75: begin
				start <= 1'b0;
				state <= 76;
			end
			76: begin
				led <= ~miso_word[15:8]; //output LED+Motor
				start <= 1'b1;
				state <= 77;
			end
			77: begin
				start <= 1'b0;
				state <= 78;
			end
			78: begin
				if (!busy) begin
					mosi_word <= {r, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 79;
				end
			end
			79: begin
				start <= 1'b0;
				state <= 80;
			end
			80: begin
				if (!busy) begin
					mosi_word <= {r, RegModemConfig1, 8'h00};
					start <= 1'b1;
					state <= 81;
				end
			end
			81: begin
				start <= 1'b0;
				state <= 82;
			end
			82: begin
				if (!busy) begin
					mosi_word <= {w, RegModemConfig1, 8'h72};
					start <= 1'b1;
					state <= 83;
				end
			end
			83: begin
				start <= 1'b0;
				state <= 84;
			end
			84: begin
				if (!busy) begin
					mosi_word <= {w, RegIrqFlags, 8'h00};
					start <= 1'b1;
					state <= 85;
				end
			end
			85: begin
				start <= 1'b0;
				state <= 86;
			end
			86: begin
				if (!busy) begin
					mosi_word <= {r, RegOpMode, 8'h00};
					start <= 1'b1;
					state <= 1'b0;
				end
			end
			87: begin
				start <= 1'b0;
				state <= 88;
			end
			88: begin
				if (!busy) begin
					mosi_word <= {w, RegFifoAddrPtr, 8'h00};
					start <= 1'b1;
					state <= 89;
				end
			end
			89: begin
				start <= 1'b0;
				state <= 90;
			end
			90: begin
				if (!busy) begin
					mosi_word <= {w, RegOpMode, 8'h86};
					start <= 1'b1;
					state <= 91;
				end
			end
			91: begin
				start <= 1'b0;
				state <= 28;
			end
		endcase
	end
end
endmodule
