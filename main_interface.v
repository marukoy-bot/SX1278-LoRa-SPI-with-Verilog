module main_interface(
	input clk_in,
	input VRx,
	input VRy,
	input SW,
	input btn1,
	input btn2, 
	input btn3,
	input btn4,
	input rst,
	output wire spi_cs_l, // to SX1278
	output wire spi_sclk, // to SX1278
	output wire spi_data, // to SX1278
	output wire [3:0] _state, //reading purposed only
	output wire [7:0] _address_byte,
	output wire [7:0] _data_byte
);

wire clk_10MHz;
reg [7:0] data_byte;
reg [7:0] address_byte;
reg [3:0] state;
wire busy;

initial begin
	data_byte <= 0;
	address_byte <= 0;
	state <= 0;
end

assign _state = state;
assign _address_byte = address_byte;
assign _data_byte = data_byte;

clk_10MHz c1(
	.clk_in(clk_in), 
	.rst(rst), 
	.clk_out(clk_10MHz)
	);
	
spi_state s1(
	.clk(clk_10MHz), //system clk (50MHz)
	.reset(rst),
	.datain({address_byte, data_byte}),
	.spi_cs_l(spi_cs_l), //active LOW chip select
	.spi_sclk(spi_sclk), //spi clk (10MHz)
	.spi_data(spi_data), //spi data
	.busy_bit(busy)
	);

//
//code for data transmisson sequence
//

always @(posedge clk_10MHz) begin
	if (rst) begin
		state <= 0;
		address_byte <= 8'b0;
		data_byte <= 8'b0;
	end else begin
	case (state)
		0: begin //Set RegOpMode
			if(~busy) begin 
				address_byte <= 8'h01; //address for RegOpMode
				data_byte <= 8'b10000001;
				state <= state + 1;
			end
		end 
		1: begin
			if (~busy) 
				state <= state + 1;
		end
		2: begin //Set RegPaConfig
			if (~busy) begin
				address_byte <= 8'h09; //adrres for PA Config
				data_byte <= 11000000; 
				state <= state + 1;
		
	end
		end
		3: begin
			if (~busy) 
				state <= state + 1;
		end
		4: begin
			if (~busy) begin
				address_byte <= 8'h22; //address for regPayloadlength
				data_byte <= 8'b00000001; //payload data - 1 byte
				state <= state + 1;
			end
		end
		5: begin
			if (~busy) 
				state <= state + 1;
		end
		6: begin
			if (~busy) begin
				address_byte <= 8'h00; //address for FIFO
				data_byte <= {VRx, VRy, SW, btn1, btn2, btn3, btn4, rst};
				state <= state + 1;
			end
		end
		7: begin
			if (~busy) 
				state <= state + 1;
		end
		8: begin
			if (~busy) begin
				address_byte <= 8'h01; //address for RegOpMode
				data_byte <= 8'b10000011; //transmit in LoRa mode
				state <= state + 1;
			end
		end
		9: begin
			if (~busy)
				state <= 0;
		end
		default: state <= 0;
	endcase  
	end
end
endmodule

module tb_main_interface();
	reg clk_in;
	reg VRx;
	reg VRy;
	reg SW;
	reg btn1;
	reg btn2; 
	reg btn3;
	reg btn4;
	reg rst;
	wire spi_cs_l; // to SX1278
	wire spi_sclk; // to SX1278
	wire spi_data; // to SX1278
	wire [3:0] _state;
	wire [7:0] _address_byte;
	wire [7:0] _data_byte;
	
main_interface m1(
	.clk_in(clk_in),
	.VRx(VRx),
	.VRy(VRy),
	.SW(SW),
	.btn1(btn1),
	.btn2(btn2), 
	.btn3(btn3),
	.btn4(btn4),
	.rst(rst),
	.spi_cs_l(spi_cs_l), // to SX1278
	.spi_sclk(spi_sclk), // to SX1278
	.spi_data(spi_data), // to SX1278
	._state(_state),
	._address_byte(_address_byte),
	._data_byte(_data_byte)
	);
	
	always #10 clk_in = ~clk_in;
	
	initial begin
		rst = 0; clk_in = 0;
		VRx = 0; VRy = 0; SW = 1; btn1 = 0; btn2 = 1; btn3 = 1; btn4 = 0;
		#10 rst = 1; 
		#10 rst = 0;
		//#10000 VRx = 0; VRy = 0; SW = 1; btn1 = 1; btn2 = 1; btn3 = 0; btn4 = 1; rst = 0;
		//#10000 VRx = 1; VRy = 0; SW = 1; btn1 = 1; btn2 = 0; btn3 = 1; btn4 = 0; rst = 0;
		//#10000 VRx = 1; VRy = 1; SW = 0; btn1 = 0; btn2 = 1; btn3 = 0; btn4 = 1; rst = 0;
		//#10000 VRx = 0; VRy = 1; SW = 0; btn1 = 1; btn2 = 1; btn3 = 1; btn4 = 0; rst = 0;
		//#10000 VRx = 1; VRy = 1; SW = 0; btn1 = 1; btn2 = 0; btn3 = 0; btn4 = 1; rst = 0;
		#1_000_000 $stop;
	end
endmodule
