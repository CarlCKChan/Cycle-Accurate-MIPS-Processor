`include "ECE429_ControlBits.v"
`define REGFILE_SIZE_BYTES 32	// 32 registers

module ECE429_RegFile(clock, rsIn, rsOut, rtIn, rtOut, rdIn, rd_dataIn, control);

input clock;
input [0:4] rsIn;
input [0:4] rtIn;
input [0:4] rdIn;
input [0:10] control;
input [0:31] rd_dataIn;

output [0:31] rsOut;
output [0:31] rtOut;

reg[0:31] reg_file[0: `REGFILE_SIZE_BYTES -1 ];
reg[0:31] rsOutReg;
reg[0:31] rtOutReg;

reg[0:32] i;

wire[0:31] rsDataOut;
wire[0:31] rtDataOut;

initial begin
	for (i = 0; i < 32; i = i + 1) begin
		reg_file[i] = i;
	end
end

assign rsOut = rsOutReg;
assign rtOut = rtOutReg;

always @ (posedge clock)
begin
	rsOutReg = reg_file[rsIn];
	rtOutReg = reg_file[rtIn];
	$display("rs: 0x%h, rt: 0x%h\n", rsOutReg, rtOutReg);
end

always @ (negedge clock)
begin
	if (control[`RWE_OFFSET]) begin
	reg_file[rdIn] = rd_dataIn;
	end
end

endmodule
	