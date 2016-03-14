include "ECE429_ControlBits.v";

module ECE429_CPU(clock, stall, parseAddr, maxfetchAddr, parseData, parseAccessSize);

input clock;
input[0:31] parseData;
input stall;
input[0:1] parseAccessSize;		// The access size to write to the memory using
input[0:31] maxfetchAddr;
input[0:31] parseAddr;

wire[0:31] memAddr;
wire[0:31] memData;			// A 32-bit piece of data to write to memory
wire[0:1] memAccessSize;
wire memR_W;					// Whether to read or write to memory

wire fetchR_W;
wire[0:31] fetchAddr;
wire[0:31] decAddr;
wire[0:1] fetchAccessSize;
wire[0:31] insn_in;

wire[0:4] rsIn;
wire[0:4] rtIn;
wire[0:31] rsOut;
wire[0:31] rtOut;
wire[0:15] immdOut;
wire[0:31] aluOut;
wire[0:25] jmpAddr;
wire aluBran;

wire[0:31] eJmpAddr;
wire[0:31] eBranAddr;

reg[0:31] inputB;
reg[0:31] tmp_insn_in;
reg fetchStall;
reg[0:31] DX_PC;
reg[0:31] DX_IR;
reg[0:15] DX_Immd;
reg[0:25] DX_Jmp;
reg[0:31] XM_PC;
reg[0:31] XM_IR;
reg[0:`CONTROL_BITS_END] DX_Ctrl;
reg[0:`CONTROL_BITS_END] XM_Ctrl;
reg[0:31] XM_O;
reg[0:31] XM_B;
reg[0:31] DX_Branch;
reg[0:31] DX_Final_PC;

wire [0:31] dataout;		// To see output of the memory
wire [0:`CONTROL_BITS_END] control_array;

reg[0:31] SignExtendedImmed;

initial begin
	tmp_insn_in = 32'h00000000;
	fetchStall = stall;
	DX_IR <= 32'h00000000;
	DX_PC <= 32'h00000000;
	DX_Ctrl <= 17'h00000;
	XM_IR <= 32'h00000000;
	XM_PC <= 32'h00000000;
	XM_Ctrl <= 17'h00000;
end

assign memR_W = (!stall) ? fetchR_W : stall;
assign memAddr = (!stall) ? fetchAddr : parseAddr; 
assign memAccessSize = (!stall) ? fetchAccessSize : parseAccessSize;
assign decAddr = fetchAddr;
assign insn_in = (fetchStall) ? 32'h00000000 : dataout;
assign eJmpAddr = { DX_PC[0:3], DX_Jmp, 2'b00 };
assign eBranAddr = (SignExtendedImmed << 2) + DX_PC;

always @* begin
	SignExtendedImmed = { {16{DX_Immd[0]}}, DX_Immd[0:15] };
end
	
always @*
begin
	if (DX_Ctrl[`JALOP_OFFSET] == 1) begin
		inputB = 32'h00000008;
	end else begin
		if (DX_Ctrl[`ALUINB_BEGIN_OFFSET:`ALUINB_END_OFFSET] == 1) begin
			inputB = SignExtendedImmed;
		end else if (DX_Ctrl[`ALUINB_BEGIN_OFFSET:`ALUINB_END_OFFSET] == 2) begin
			inputB = {16'h0000, DX_Immd[0:15]};
		end else begin
			inputB = rtOut;
		end
	end
end

always @* begin
	if (DX_Ctrl[`BR_OFFSET] == 1 && aluBran == 1) begin
		DX_Branch = eBranAddr;
	end else begin
		DX_Branch = DX_PC;
	end
end
	
always @* begin
	if (DX_Ctrl[`JP_OFFSET] == 1) begin
		DX_Final_PC = eJmpAddr;
	end else begin
		DX_Final_PC = DX_Branch;
	end
end

always @(posedge clock) begin
	if (!stall) begin
		$display("rising edge\n");
	end
end

always @(posedge clock) begin
	fetchStall <= stall;
end

always @(posedge clock) begin
	if (!stall) begin
		DX_IR <= dataout;
		DX_PC <= fetchAddr;
		DX_Ctrl <= control_array;
		DX_Immd <= immdOut;
		DX_Jmp <= jmpAddr;
		XM_IR <= DX_IR;
		XM_PC <= DX_PC;
		XM_Ctrl <= DX_Ctrl;
		XM_O <= aluOut;
	end
end	

always @(negedge clock) begin
	if (fetchStall == 0) begin
		$display("read at mem[0x%h] = 0x%h\n", fetchAddr-4, dataout);
		$display("DX_IR: 0x%h, DX_PC: 0x%h, DX_Ctrl: 0x%h, 
		DX_Final_PC: 0x%h, XM_IR: 0x%h, XM_PC: 0x%h, XM_Ctrl: 0x%h, 
		XM_O: 0x%h, eBranAddr: 0x%h, eJmpAddr: 0x%h\n", DX_IR, 
		DX_PC, DX_Ctrl, DX_Final_PC, XM_IR, XM_PC, XM_Ctrl, XM_O,
		eBranAddr, eJmpAddr);
		if(fetchAddr >= maxfetchAddr) begin
			$finish;
		end
	end
end

ECE429_Fetch f(
	.clk_in(clock), 
	.pc_out(fetchAddr), 
	.pc_decode_out(decAddr), 
	.rw_out(fetchR_W), 
	.stall_in(stall), 
	.access_size_out(fetchAccessSize)
);

ECE429_Memory m(
  .clock(clock),
  .address(memAddr),
  .datain(parseData),
  .access_size(memAccessSize),
  .r_w(memR_W),
  .dataout(dataout)
);

ECE429_Decode d(
  .insn_in(insn_in),
  .pc_in(decAddr), 
  .controlBitVector(control_array), 
  .op_code(), 
  .reg_RS(rsIn), 
  .reg_RT(rtIn), 
  .reg_RD(), 
  .reg_SHAMT(), 
  .reg_FUNCT(), 
  .jump_ADDR(jmpAddr), 
  .immediate_value(immdOut)
);

ECE429_ALU alu(
	.inputA(rsOut), 
	.inputB(inputB), 
	.inputSHAMT(), 
	.ALUop(DX_Ctrl[`ALUOP_BEGIN_OFFSET:`ALUOP_END_OFFSET]), 
	.takeBranch(aluBran), 
	.ALUOutput(aluOut)
);

ECE429_RegFile rf(
	.clock(clock),
	.rsIn(rsIn), 
	.rsOut(rsOut), 
	.rtIn(rtIn), 
	.rtOut(rtOut), 
	.rdIn(), 
	.rd_dataIn(), 
	.control()
);

endmodule
