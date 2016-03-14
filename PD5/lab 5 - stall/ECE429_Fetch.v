module ECE429_Fetch(clk_in, pc_in, pc_out, pc_decode_out, rw_out, stall_in, access_size_out);

input clk_in;
input [0:31] pc_in;
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

//reg stallDelay1;		// TODO : Remove after PD4
//reg stallDelay2;		// TODO : Remove after PD4

initial begin
	program_counter = 32'h80020000;
	//stallDelay1 = 1;		// TODO : Remove after PD4
	//stallDelay2 = 1;		// TODO : Remove after PD4
end

//always @(posedge clk_in)		// TODO : Remove after PD4
//begin
//	stallDelay1 <= stall_in;
//	stallDelay2 <= stallDelay1;
//end

always @ (posedge clk_in)
begin
	if (!stall_in) begin
	//if (!stallDelay2) begin			// TODO : Change back after PD4
		//program_counter <= program_counter + 4; 		// Changed for PD4
		program_counter <= pc_in; 
	end
end
endmodule
