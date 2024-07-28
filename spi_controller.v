module spi_controller(
	input wire clk, //system clk (50MHz)
	input wire reset,
	input wire [15:0] datain,
	output wire spi_cs_l, //active LOW chip select
	output wire spi_sclk, //spi clk (10MHz)
	output wire spi_data, //spi data
	output wire busy_bit
);

reg [15:0] MOSI;
reg [4:0] count;
reg cs_l;
reg sclk;
reg [2:0] state;
reg busy;

initial begin
	MOSI <= 0;
	count <= 0;
	cs_l <= 0;
	sclk <= 0;
	state <= 0;
	busy <= 0;
end

always @(posedge clk or posedge reset) begin
	if(reset) begin
		MOSI <= 16'b0;
		count <= 5'd16;
		cs_l <= 1'b1;
		sclk <= 1'b0;
		busy <= 0;
		state <= 0;
	end else begin
		case (state)
			0: begin
				sclk <= 1'b0;
				cs_l <= 1'b1;
				state <= 1;
				busy <= 0;
				end
			1: begin
				sclk <= 1'b0;
				cs_l <= 1'b0;
				MOSI <= datain[count - 1];
				count <= count - 1;
				busy <= 1;
				state <= 2;
				end
			2: begin
				sclk <= 1'b1;
				if(count > 0) 
					state <= 1;
				else begin
					count <= 16;
					busy = 0;
					state <= 0;
				end
				end
			default: state <= 0;
		endcase
	end
end

assign spi_cs_l = cs_l;
assign spi_sclk = sclk;
assign spi_data = MOSI;
assign busy_bit = busy;

endmodule



module tb_SPI;
//inputs
reg clk;
reg reset;
reg [15:0] datain;

//outputs
wire spi_cs_l;
wire spi_sclk;
wire spi_data;
wire [4:0] counter;

spi_state dut(
	.clk(clk),
	.reset(reset),
	.datain(datain),
	.spi_cs_l(spi_cs_l),
	.spi_sclk(spi_sclk),
	.spi_data(spi_data)
);

initial begin
	clk = 0;
	reset = 1;
	datain = 0;
end

always #5 clk = ~clk;

initial begin
	#10 reset = 1'b0;
	
	#10 	datain = 16'b1000_0000_1010_1010;
	#1000 datain = 16'b1001_0011_1111_0000;
	#1000 datain = 16'b1001_0011_0000_1111;
	#1000 datain = 16'b1001_0011_1100_1100;
	
	#1000 datain = 16'b1001_0011_1011_0010;
	#1000 datain = 16'b1001_0011_0000_0000;
end
	
endmodule

