module spi_controller(
	input i_clk, //system clk (10MHz)
	input i_rst,
	input [15:0] i_data,
	output o_spi_cs_l, //active LOW chip select
	output o_spi_clk, //spi clk (10MHz)
	output o_spi_mosi, //spi mosi
	input i_spi_miso,
	output [7:0] o_spi_miso_data
);

reg r_mosi;
reg [7:0] r_miso;
reg [4:0] r_count;
reg r_spi_cs_l;
reg r_spi_clk;
reg [2:0] r_state;

initial begin
	r_miso <= 8'h00;
	r_mosi <= 1'b0;
	r_count <= 5'd16;
	r_spi_cs_l <= 1'b1;
	r_spi_clk <= 1'b0;
	r_state <= 0;
end

always @(posedge i_clk)
begin
	if (~i_rst)
	begin
		r_miso <= 8'h00;
		r_mosi <= 1'b0;
		r_count <= 5'd16;
		r_spi_cs_l <= 1'b1;
		r_spi_clk <= 1'b0;
		r_state <= 1'b0;
	end
	else
	begin
		case(r_state)
		0:
		begin
			r_spi_clk <= 1'b0;
			r_spi_cs_l <= 1'b1;
			r_state <= 1;
		end
		1:
		begin
			r_spi_clk <= 1'b0;
			r_spi_cs_l <= 1'b1;
			r_state <= 2;
		end
		2:
		begin
			r_spi_clk <= 1'b0;
			r_spi_cs_l <= 1'b0;
			if(i_data[15] == 1'b1)
			begin
				r_mosi <= i_data[r_count - 1];
			end
			else
			begin
				r_mosi <= 1'b0;
				if(r_count < 8)
					r_miso[r_count] <= i_spi_miso;
			end
			r_count <= r_count - 1;
			r_state <= 3;
		end
		3:
		begin
			r_spi_clk <= 1'b1;
			if(r_count > 0)
				r_state <= 2;
			else
			begin			
				if(r_count == 0)
					r_miso[0] <= i_spi_miso;	
				r_count <= 5'd16;
				r_state <= 4;
			end
		end
		4:
		begin
			r_spi_clk <= 1'b0;
			r_state <= 0;
		end
		default: r_state <= 0;
		endcase
	end
end

assign o_spi_cs_l = r_spi_cs_l;
assign o_spi_clk = r_spi_clk;
assign o_spi_mosi = r_mosi;
assign o_spi_miso_data = (r_count == 5'd16) ? r_miso : 8'h00;

//debug
assign o_count = r_count;

endmodule



module tb_SPI;
//inputs
reg clk;
reg rst;
reg [15:0] data;

//outputs
wire spi_cs_l;
wire spi_clk;
wire spi_mosi;
reg spi_miso;
wire [7:0] spi_miso_data;

spi_controller dut(
	.i_clk(clk),
	.i_rst(rst),
	.i_data(data),
	.o_spi_cs_l(spi_cs_l),
	.o_spi_clk(spi_clk),
	.o_spi_mosi(spi_mosi),
	.i_spi_miso(spi_miso),
	.o_spi_miso_data(spi_miso_data)
);

always #10 clk = ~clk;

initial begin
	rst = 1;
	clk = 1'b0;
	spi_miso = 1'b0;
	data = 16'd0;
	repeat(10) @(posedge clk) rst = 1'b1;
	repeat(10) @(posedge clk) rst = 1'b0;
	repeat(10) @(posedge clk) rst = 1'b1;
	
	
	// Test MOSI operation
    @(posedge spi_cs_l) 
        data = 16'b1011001110001111; // First bit is 1, MOSI operation
    @(posedge spi_cs_l) 
    begin
        data = 16'b0000000011111111; //miso
        spi_miso <= 1'b1;
	end
    // Test MISO operation
    @(posedge spi_cs_l) begin
        data = 16'b0111111111111111; // First bit is 0, MISO operation
    	spi_miso <= 1'b0;    
    end
    //
    @(posedge spi_clk) spi_miso <= 1'b1;
    @(posedge spi_clk) spi_miso <= 1'b0;
    @(posedge spi_clk) spi_miso <= 1'b1;
    @(posedge spi_clk) spi_miso <= 1'b1;
    @(posedge spi_clk) spi_miso <= 1'b0;
    @(posedge spi_clk) spi_miso <= 1'b0;
    @(posedge spi_clk) spi_miso <= 1'b1;
    ///
    @(posedge spi_clk) spi_miso <= 1'b1;
    //
    @(posedge spi_clk) spi_miso <= 1'b1;
    @(posedge spi_clk) spi_miso <= 1'b0;
    @(posedge spi_clk) spi_miso <= 1'b0;
    @(posedge spi_clk) spi_miso <= 1'b0;
    @(posedge spi_clk) spi_miso <= 1'b1;
    @(posedge spi_clk) spi_miso <= 1'b1;
    @(posedge spi_clk) spi_miso <= 1'b0;
    ///
    @(posedge spi_clk) spi_miso <= 1'b0;
	
    #5000 $stop;
end
endmodule

