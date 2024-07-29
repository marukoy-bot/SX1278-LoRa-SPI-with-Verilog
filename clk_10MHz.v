module clk_10MHz(
	input wire clk_in, 
	input wire rst, 
	output reg clk_out
	);
	
reg [2:0] count;

initial count <= 0;

always @(posedge clk_in or posedge rst) begin
	if(rst) begin
		count <= 3'd0;
		clk_out <= 1'd0;
	end else begin
		if (count == 3'd4) begin
			count <= 3'd0;
			clk_out <= ~clk_out;
		end else begin
			count <= count + 1;	
		end
	end
end

endmodule

module tb_clk;
reg rst;
reg clk_in;
wire clk_out;

clk_10MHz c1(
	.clk_in(clk_in), 
	.rst(rst),
	.clk_out(clk_out)
	);
initial begin 
	clk_in = 0;
	forever #10 clk_in = ~clk_in;
end

initial begin
	rst = 1;          // Apply reset
    #100;
    rst = 0;          // Release reset
    #1_000_000;
    $stop;
end
endmodule
