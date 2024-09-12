module main_interface(
	input i_clk,
	input i_rst,
	input [7:0] i_ctrl, //N, S, E, W, b1, b2, b3, b4
	output o_spi_cs_l, // to SX1278
	output o_spi_clk, // to SX1278
	output o_spi_mosi, // to SX1278
	input i_spi_miso,
	output [4:0] _state,
	output [7:0] _address_byte,
	output [7:0] _data_byte,
	output wire [7:0] o_spi_miso
);

wire w_clk_1MHz;
reg [7:0] r_miso;
reg [7:0] r_data_byte;
reg [7:0] r_address_byte; //{wr, [6:0] addr}
reg [4:0] r_state;

parameter w = 1'b1;
parameter r = 1'b0;

parameter 		
	REG_FIFO 						= 8'h00,
	REG_OP_MODE 						= 8'h01,
	REG_FRF_MSB 						= 8'h06,
	REG_FRF_MID 						= 8'h07,
	REG_FRF_LSB 						= 8'h08,
	REG_PA_CONFIG 						= 8'h09,
	REG_OCP 						= 8'h0b,
	REG_LNA 						= 8'h0c,
	REG_FIFO_ADDR_PTR        = 8'h0d,
  	REG_FIFO_TX_BASE_ADDR    = 8'h0e,
  	REG_FIFO_RX_BASE_ADDR    = 8'h0f,
  	REG_FIFO_RX_CURRENT_ADDR = 8'h10,
  	REG_IRQ_FLAGS            = 8'h12,
  	REG_RX_NB_BYTES          = 8'h13,
  	REG_PKT_SNR_VALUE        = 8'h19,
  	REG_PKT_RSSI_VALUE       = 8'h1a,
  	REG_RSSI_VALUE           = 8'h1b,
  	REG_MODEM_CONFIG_1       = 8'h1d,
  	REG_MODEM_CONFIG_2       = 8'h1e,
  	REG_PREAMBLE_MSB         = 8'h20,
  	REG_PREAMBLE_LSB         = 8'h21,
  	REG_PAYLOAD_LENGTH       = 8'h22,
  	REG_MODEM_CONFIG_3       = 8'h26,
  	REG_FREQ_ERROR_MSB       = 8'h28,
  	REG_FREQ_ERROR_MID       = 8'h29,
  	REG_FREQ_ERROR_LSB       = 8'h2a,
  	REG_RSSI_WIDEBAND        = 8'h2c,
  	REG_DETECTION_OPTIMIZE   = 8'h31,
  	REG_INVERTIQ             = 8'h33,
  	REG_DETECTION_THRESHOLD  = 8'h37,
  	REG_SYNC_WORD            = 8'h39,
  	REG_INVERTIQ2            = 8'h3b,
  	REG_DIO_MAPPING_1        = 8'h40,
  	REG_VERSION              = 8'h42,
  	REG_PA_DAC               = 8'h4d,
  	
// modes
  	MODE_LONG_RANGE_MODE     = 8'h80,
  	MODE_SLEEP               = 8'h00,
  	MODE_STDBY               = 8'h01,
  	MODE_TX                  = 8'h03,
  	MODE_RX_CONTINUOUS       = 8'h05,
  	MODE_RX_SINGLE           = 8'h06,
  	MODE_CAD                 = 8'h07,	

// PA config
  	PA_BOOST                 = 8'h80,

// IRQ masks
  	IRQ_TX_DONE_MASK           = 8'h08,
  	IRQ_PAYLOAD_CRC_ERROR_MASK = 8'h20,
  	IRQ_RX_DONE_MASK           = 8'h40,
  	IRQ_CAD_DONE_MASK          = 8'h04,
  	IRQ_CAD_DETECTED_MASK      = 8'h01,

  	RF_MID_BAND_THRESHOLD    		= 29'd525_000_000,
  	RSSI_OFFSET_HF_PORT      		= 8'd157,
  	RSSI_OFFSET_LF_PORT      		= 8'd164,

  	MAX_PKT_LENGTH           		= 8'd255;

task writeRegister(input [7:0] address, input [7:0] value);
	begin
		r_address_byte <= {w, address [6:0]};
		r_data_byte <= value;
	end
endtask

	task readRegister(input [7:0] address, output [7:0] value); //not final, needs tweaking
	begin
		r_address_byte <= {r, address [6:0]};
		value <= r_miso;
	end
endtask

initial begin
	r_miso <= 8'h00;
	r_data_byte <= 0;
	r_address_byte <= 0;
	r_state <= 0;
end

assign _state = r_state;
assign _address_byte = r_address_byte;
assign _data_byte = r_data_byte;

clk_1MHz c1(
	.i_clk(i_clk), 
	.i_rst(i_rst), 
	.o_clk(w_clk_1MHz)
	);
	
spi_controller s1(
	.i_clk(w_clk_1MHz), //system clk (50MHz)
	.i_rst(i_rst),
	.i_data({r_address_byte, r_data_byte}),
	.o_spi_cs_l(o_spi_cs_l), //active LOW chip select
	.o_spi_clk(o_spi_clk), //spi clk (10MHz)
	.o_spi_mosi(o_spi_mosi),
	.i_spi_miso(i_spi_miso),
	.o_spi_miso_data(o_spi_miso)
	);

//
//code for data transmisson sequence
//based on LoRa.cpp functions translated to Verilog (not any more)
//https://github.com/sandeepmistry/arduino-LoRa/blob/master/src/LoRa.cpp
//

always @(posedge w_clk_1MHz) begin
    if (~i_rst) begin
        r_miso <= 8'h00;
        r_state <= 0;
        writeRegister(8'h00, 8'h00);
    end else begin
        case (r_state)
            0: begin // Set to standby mode
                @(posedge o_spi_cs_l) begin 
                    writeRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_STDBY);
                    r_state <= 1;    
                end
            end 
            1: begin // Reset FIFO address pointer
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_FIFO_ADDR_PTR, 8'h00);
                    r_state <= 2;
                end
            end
            2: begin // Set PA configuration
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_PA_CONFIG, PA_BOOST | (17 - 2)); // PA_BOOST with level 15
                    r_state <= 3;
                end
            end
            3: begin // Set PA DAC
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_PA_DAC, 8'h84); // Default value for +17 dBm
                    r_state <= 4;
                end
            end
            4: begin // Set OCP
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_OCP, 8'h2B); // Set OCP to 100 mA
                    r_state <= 5;
                end
            end
            5: begin // Enable AGC
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_MODEM_CONFIG_3, 8'h04); // Enable AGC
                    r_state <= 6;
                end
            end
            
            6: begin // Write data to FIFO
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_FIFO, i_ctrl); //
                    r_state <= 7;
                end
            end
            7:
            begin // Set to TX mode
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_TX);
                    r_state <= 8;
                end
            end
            8: begin // Wait for TxDone IRQ
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK);
                    r_state <= 9;
                end
            end
            9: begin // Set back to standby mode
                @(posedge o_spi_cs_l) begin
                    writeRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_STDBY);
                    r_state <= 6; // Return to initial state or next operation
                end
            end
            default: r_state <= 0;
        endcase  
    end
end
endmodule

module tb_main_interface();
	reg clk;
	reg rst;
	reg [7:0] ctrl;
	wire spi_cs_l; // to SX1278
	wire spi_clk; // to SX1278
	wire spi_mosi; // to SX1278
	reg spi_miso;
	wire [7:0] o_spi_miso;
	wire [4:0] _state;
	wire [7:0] _address_byte;
	wire [7:0] _data_byte;
	
main_interface m1(
	.i_clk(clk),
	.i_rst(rst),
	.i_ctrl(ctrl),
	.o_spi_cs_l(spi_cs_l), // to SX1278
	.o_spi_clk(spi_clk), // to SX1278
	.o_spi_mosi(spi_mosi), // to SX1278
	.i_spi_miso(spi_miso),
	._state(_state),
	._address_byte(_address_byte),
	._data_byte(_data_byte),
	.o_spi_miso(o_spi_miso)
	);
	
	always #10 clk = ~clk;
	
	initial begin
		spi_miso <= 1'b0;
		rst = 1;
		clk = 0;
		ctrl = 8'b10110111;
		repeat(10) @(posedge clk) rst = 1;
		repeat(10) @(posedge clk) rst = 0;
		repeat(10) @(posedge clk) rst = 1; 
		
		if(_state == 8)
		begin
			@(posedge spi_clk) spi_miso = 0;
			@(posedge spi_clk) spi_miso = 0;
			@(posedge spi_clk) spi_miso = 0;
			@(posedge spi_clk) spi_miso = 0;
			@(posedge spi_clk) spi_miso = 1;
			@(posedge spi_clk) spi_miso = 0;
			@(posedge spi_clk) spi_miso = 0;
			@(posedge spi_clk) spi_miso = 0;
		end
	end
endmodule
