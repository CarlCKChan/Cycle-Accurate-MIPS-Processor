include "ECE429_ControlBits.v";
include "ECE429_RegFile.v";

module ECE429_CPU(clock, stall, parseAddr, maxfetchAddr, parseData, parseAccessSize);

input clock;
input[0:31] parseData;
input stall;
input[0:1] parseAccessSize;		// The access size to write to the memory using
input[0:31] maxfetchAddr;
input[0:31] parseAddr;

wire[0:31] ImemAddr;
wire[0:31] DmemAddr;
wire[0:31] ImemDataIn;
wire[0:31] DmemDataIn;
wire[0:1] ImemAccessSize;
wire[0:1] DmemAccessSize;
wire ImemR_W;					// Whether to read or write to memory
wire DmemR_W;

wire fetchR_W;
wire[0:31] fetchAddr;
wire[0:31] decAddr;
wire[0:1] fetchAccessSize;
wire[0:31] insn_in;

wire readRs;
wire readRt;
wire[0:4] rsIn;
wire[0:4] rtIn;
wire[0:4] rdIn;
wire[0:31] rsOut;
wire[0:31] rtOut;
wire[0:15] immdOut;
wire[0:31] aluOut;
wire[0:25] jmpAddr;
wire aluBran;

wire[0:31] eJmpAddr;
wire[0:31] eBranAddr;
wire[0:4] shiftamt;
wire[0:31] regIn;
wire[0:`CONTROL_BITS_END] final_Ctrl;

reg[0:31] finalRD;
reg[0:31] inputB;
reg[0:31] inputA;
reg[0:31] tmp_insn_in;
reg fetchStall;
reg[0:31] FD_PC;
reg[0:31] DX_PC;
reg[0:31] DX_IR;
reg[0:15] DX_Immd;
reg[0:25] DX_Jmp;
reg[0:4] DX_SHAMT;
reg[0:31] DX_Branch;
reg[0:31] DX_Jump;
reg[0:31] DX_Final_PC;
reg[0:4] DX_RD;
reg[0:31] XM_PC;
reg[0:31] XM_IR;
reg[0:4] XM_RD;
reg[0:`CONTROL_BITS_END] DX_Ctrl;
reg[0:`CONTROL_BITS_END] XM_Ctrl;
reg[0:`CONTROL_BITS_END] MW_Ctrl;
reg[0:31] XM_O;
reg[0:31] XM_B;
reg[0:31] MW_O;
reg[0:31] MW_IR;
reg[0:31] MW_PC;
reg[0:4] MW_RD;
reg[0:31] Ddataout_Final;

wire fetch_final_stall;
reg RAW_STALL;			// 1 if a RAW dependency needing a stall is detected, 0 otherwise
reg FD_STALL;			// 


// Holds CPU while memory loaded from SREC file
always @* begin			// 
	if (stall == 1) begin
		FD_STALL = stall;
	end else begin
		FD_STALL = 0;
	end
end


// Stall if the instruction in Decode reads a register written to by a later instruction.  'RWE_OFFSET'
// defines the location in the control array for if an instruction writes back.
always @* begin
	if (readRs && ((rsIn == DX_RD && DX_Ctrl[`RWE_OFFSET]) || (rsIn == XM_RD && XM_Ctrl[`RWE_OFFSET]))) begin
		RAW_STALL = 1;
	end else if (readRt && ((rtIn == DX_RD && DX_Ctrl[`RWE_OFFSET])||( rtIn == XM_RD && XM_Ctrl[`RWE_OFFSET]))) begin
		RAW_STALL = 1;
	end else begin
		RAW_STALL = 0;
	end
end	

// CHANGE : Flushing for branches and jumps
wire JB_FLUSH;			// 1 to flush D/X for jump and branch, zero otherwise
assign JB_FLUSH = ( (DX_Ctrl[`JP_OFFSET]==1) || ( (DX_Ctrl[`BR_OFFSET]==1) && (aluBran==1) ) ) ? 1 : 0;
reg JB_FLUSH_DELAY;		// 1 to flush D/X for jump/branch.  This is to flush the second instruction
always @(posedge clock) begin			// Need to flush two clock cycles
	JB_FLUSH_DELAY <= JB_FLUSH;
end


wire [0:31] Idataout;		// To see output of the memory
wire [0:31] Ddataout;
wire [0:`CONTROL_BITS_END] control_array;

reg[0:31] SignExtendedImmed;

initial begin
	tmp_insn_in = 32'h00000000;
	fetchStall = stall;
	FD_PC <= 32'h00000000;
	DX_IR <= 32'h00000000;
	DX_PC <= 32'h00000000;
	DX_Ctrl <= 18'h00000;
	XM_IR <= 32'h00000000;
	XM_PC <= 32'h00000000;
	XM_Ctrl <= 18'h00000;
	RAW_STALL <= 0;			// TODO : Make this conbinational later
	JB_FLUSH_DELAY <= 0;
end

// Instruction memory inputs
assign ImemR_W = (!stall) ? fetchR_W : stall;
assign ImemAddr = (!stall) ? ((!RAW_STALL) ? fetchAddr : FD_PC) : parseAddr;
assign ImemAccessSize = (!stall) ? fetchAccessSize : parseAccessSize;
assign ImemDataIn = parseData;

// Data memory inputs
assign DmemR_W = (!stall) ? XM_Ctrl[`DMWE_OFFSET] : ImemR_W;
assign DmemAddr = (!stall) ? XM_O : ImemAddr;
assign DmemAccessSize = (!stall) ? XM_Ctrl[`MEMAS_BEGIN_OFFSET:`MEMAS_END_OFFSET] : ImemAccessSize;
assign DmemDataIn = (!stall) ? XM_B : ImemDataIn;

// Decoder inputs
assign decAddr = fetchAddr;
assign insn_in = (fetchStall || JB_FLUSH || JB_FLUSH_DELAY) ? 32'h00000000 : Idataout;	// CHANGE : Added extra conditions for flushes

// Address of instruction after the one in Execute stage (for jumps/branches)
wire[0:31] DX_DelaySlot_PC;
assign DX_DelaySlot_PC = DX_PC+4;

// Jump/branch target addresses
assign eJmpAddr = { DX_DelaySlot_PC[0:3], DX_Jmp, 2'b00 };
assign eBranAddr = (SignExtendedImmed << 2) + DX_DelaySlot_PC;

// Input to register while during write-back stage
assign regIn = (MW_Ctrl[`RWD_OFFSET]) ? Ddataout_Final : MW_O;

// Final control array and stall signal coming from decode stage
assign final_Ctrl = (RAW_STALL) ? `NOP_CONTROL_BITS : control_array;
assign fetch_final_stall = (RAW_STALL || FD_STALL);

// Decide whether load instruction needs to sign-extend last byte.  Doing nothing when reading
// a byte only by default zero-extends its.
always @* begin
	if (MW_Ctrl[`BSX_OFFSET]) begin
		Ddataout_Final = { {24{Ddataout[24]}}, Ddataout[24:31]};
	end else begin
		Ddataout_Final = Ddataout;
	end
end

// Whether write-back to register file should be to Rd or Rt register.  Ex. immediates write to Rt,
// but many other instructions write to Rd.
always @* begin
	if (control_array[`RDST_OFFSET]) begin
		finalRD = rdIn;
	end else begin
		finalRD = rtIn;
	end
end

// Combinationally calculated sign-extended immediate value from instruction
always @* begin
	SignExtendedImmed = { {16{DX_Immd[0]}}, DX_Immd[0:15] };
end

// If doing jump-and-link, need to calculated currPC+8.  Otherwise, use register value.
// The stalls ensure write-back is done when reading.
always @*
begin
	if(DX_Ctrl[`JALOP_OFFSET] == 1) begin
		inputA = DX_PC;
	end else begin
		inputA = rsOut;
	end
end

// If doing jump-and-link, need to calculated currPC+8.  Otherwise, either use register value or
// or an immediate value (sign- or zer-extended).  The stalls ensure write-back is done when reading.
always @*
begin
	if (DX_Ctrl[`JALOP_OFFSET] == 1) begin
		inputB = 32'h00000008;	// TODO : Might need to change back to 8
		//inputB = 32'h00000004;
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

// If it is a branch instruction and you need to take branch, set next PC to target.
// Otherwise, just increment PC by 4 (next instruction).
always @* begin
	if (DX_Ctrl[`BR_OFFSET] == 1 && aluBran == 1) begin
		DX_Branch = eBranAddr;
	end else begin
		//DX_Branch = DX_PC;
		DX_Branch = fetchAddr + 4;
	end
end

// If jumping, set target address.  Otherwise, take other calculated target.
always @* begin
	if (DX_Ctrl[`JP_OFFSET] == 1) begin
		DX_Jump = eJmpAddr;
	end else begin
		DX_Jump = DX_Branch;
	end
end

// If jump is with register, use register value.  Otherwise, use previously calculated value.
always @* begin
	if (DX_Ctrl[`JROP_OFFSET] == 1) begin
		DX_Final_PC = rsOut;
	end else begin
		DX_Final_PC = DX_Jump;
	end
end

always @(posedge clock) begin
	if (!stall) begin
		$display("rising edge\n");
	end
end

always @(posedge clock) begin
	//fetchStall <= stall;
	fetchStall <= FD_STALL;		// 
end

always @(posedge clock) begin
	if (!RAW_STALL) begin
		FD_PC <= fetchAddr;
	end else begin
		FD_PC <= FD_PC;
	end
end

always @(posedge clock) begin
	if (!stall) begin		
		DX_IR <= Idataout;
		DX_PC <= FD_PC;
		DX_Ctrl <= final_Ctrl;
		DX_Immd <= immdOut;
		DX_Jmp <= jmpAddr;
		DX_SHAMT <= shiftamt;
		DX_RD <= finalRD;
		XM_IR <= DX_IR;
		XM_PC <= DX_PC;
		XM_Ctrl <= DX_Ctrl;
		XM_O <= aluOut;
		XM_RD <= DX_RD;
		XM_B <= rtOut;
		MW_IR <= XM_IR;
		MW_PC <= XM_PC;
		MW_Ctrl <= XM_Ctrl;
		MW_O <= XM_O;
		MW_RD <= XM_RD;
	end
end	

always @(negedge clock) begin
	if (stall == 0) begin			// TODO: Might need to change back to fetchStall after PD4
		$display("read at mem[0x%h] = 0x%h\n", FD_PC, Idataout);		// TODO: Might need to change to fetchAddr-4 after PD4
		/*$display("DX_IR: 0x%h, DX_PC: 0x%h, DX_Ctrl: 0x%h, 
		DX_Final_PC: 0x%h, DX_SHAMT: 0x%h, XM_IR: 0x%h, XM_PC: 0x%h, XM_Ctrl: 0x%h, 
		XM_O: 0x%h, eBranAddr: 0x%h, eJmpAddr: 0x%h, aluop: 0x%h\n", DX_IR, 
		DX_PC, DX_Ctrl, DX_Final_PC, DX_SHAMT, XM_IR, XM_PC, XM_Ctrl, XM_O,
		eBranAddr, eJmpAddr, DX_Ctrl[`ALUOP_BEGIN_OFFSET:`ALUOP_END_OFFSET]);*/
		//if(fetchAddr >= (maxfetchAddr + 20)) begin
		if(fetchAddr == (`REGFILE_SPECIAL_RA+8)) begin
		//if((fetchAddr < 100)) begin
			$finish;
		end
	end
end

ECE429_Fetch f(
	.clk_in(clock), 
	.pc_in(DX_Final_PC),
	.pc_out(fetchAddr), 
	.pc_decode_out(decAddr), 
	.rw_out(fetchR_W), 
	//.stall_in(stall), 		// TODO: Change back after PD4
	.stall_in(fetch_final_stall), 
	.access_size_out(fetchAccessSize)
);

// Instruction memory
ECE429_Memory m(
  .clock(clock),
  .address(ImemAddr),
  .datain(ImemDataIn),
  .access_size(ImemAccessSize),
  .r_w(ImemR_W),
  .dataout(Idataout)
);

// Data memory
ECE429_Memory dm(
  .clock(clock),
  .address(DmemAddr),
  .datain(DmemDataIn),
  .access_size(DmemAccessSize),
  .r_w(DmemR_W),
  .dataout(Ddataout)
);

ECE429_Decode d(
  .insn_in(insn_in),
  .pc_in(decAddr), 
  .controlBitVector(control_array), 
  .op_code(), 
  .reg_RS(rsIn), 
  .reg_RT(rtIn), 
  .reg_RD(rdIn), 
  .reg_SHAMT(shiftamt), 
  .reg_FUNCT(), 
  .jump_ADDR(jmpAddr), 
  .immediate_value(immdOut),
  .readRs(readRs),
  .readRt(readRt)
);

ECE429_ALU alu(
	.inputA(inputA), 
	.inputB(inputB), 
	.inputSHAMT(DX_SHAMT), 
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
	.rdIn(MW_RD), 
	.rd_dataIn(regIn), 
	.control(MW_Ctrl)
);

endmodule
