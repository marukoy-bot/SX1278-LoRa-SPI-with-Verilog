module clk_1MHz(
	input wire i_clk, 
	input wire i_rst,
	output reg o_clk
	);
	
reg [3:0] r_count;

initial r_count <= 0;

always @(posedge i_clk) begin
	if(~i_rst) begin
		r_count <= 4'd0;
		o_clk <= 1'b0;
	end else begin
		if (r_count == 4'd9) begin
			r_count <= 4'd0;
			o_clk <= ~o_clk;
		end else begin
			r_count <= r_count + 1;	
		end
	end
end

endmodule
