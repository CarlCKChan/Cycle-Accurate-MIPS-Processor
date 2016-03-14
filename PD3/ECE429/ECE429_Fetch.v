module ECE429_Fetch(clk_in, pc_out, pc_decode_out, rw_out, stall_in, access_size_out);

input clk_in;
input stall_in;

output [0:31] pc_out;
output [0:31] pc_decode_out;
output rw_out;	// 0 to read, 1 to write
output [0:1] access_size_out;	// 11 for word, 10 for half-word, 01/00 byte

reg [0:31] program_counter;

assign pc_out = program_counter;
assign pc_decode_out = program_counter;
assign access_size_out = 2'b11;
assign rw_out = 1'b0;

initial begin
	program_counter = 32'h80020000;
end

always @ (posedge clk_in)
begin
	if (!stall_in) begin
		program_counter <= program_counter + 4; 
	end
end
endmodule
