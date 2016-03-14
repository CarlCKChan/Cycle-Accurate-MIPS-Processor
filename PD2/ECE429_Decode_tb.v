module ECE429_Decode_tb();

reg clock;
reg parseEnable;
wire[0:31] parseAddr;		// A 32-bit address to put into the memory
wire[0:31] memAddr;
wire[0:31] memData;			// A 32-bit piece of data to write to memory
wire[0:1] parseAccessSize;		// The access size to write to the memory using
wire[0:1] memAccessSize;
wire memR_W;					// Whether to read or write to memory
wire parseDone;					// Set to 1 once parser is parseDone
wire parseError;					// Set to 1 on parseError

wire fetchR_W;
wire[0:31] fetchAddr;
wire[0:31] decAddr;
wire[0:1] fetchAccessSize;

reg[0:31] maxfetchAddr;

reg[0:31] tmp_insn_in;

wire fetStall;

wire [0:31] dataout;		// To see output of the memory

initial begin
	clock = 0;
	maxfetchAddr = 32'h00000000;
	tmp_insn_in = 32'h00000000;
	// Toggle parse enable
	parseEnable = 0;
	#1
	parseEnable = 1;
	#1
	parseEnable = 0;

	@(posedge clock);

end

assign memR_W = (parseDone) ? fetchR_W : ~parseDone;
assign memAddr = (parseDone) ? fetchAddr : parseAddr; 
assign memAccessSize = (parseDone) ? fetchAccessSize : parseAccessSize;
assign decAddr = fetchAddr;
assign fetStall = ~parseDone;
assign insn_in = (fetStall) ? 32'h00000000 : tmp_insn_in;

always begin
  #10 clock = ~clock;
end


always @(parseAddr) begin
	if(parseAddr > maxfetchAddr) begin
		maxfetchAddr = parseAddr;
	end
end


always @(parseError) begin
  if(parseError == 1) begin
    $finish;
  end
end

always @(negedge clock) begin
	if (parseDone == 1) begin
		tmp_insn_in = dataout;
		
		if(fetchAddr >= maxfetchAddr) begin
			$finish;
		end

		$display("read at mem[0x%h] = 0x%h\n", fetchAddr, dataout);
	end
end

ECE429_Fetch f(
	.clk_in(clock), 
	.pc_out(fetchAddr), 
	.pc_decode_out(decAddr), 
	.rw_out(fetchR_W), 
	.stall_in(fetStall), 
	.access_size_out(fetchAccessSize)
);

ECE429_SRECParser #("fact.srec") s(
	.clock(clock),
	.parseEnable(parseEnable),
	.parseAddr(parseAddr), 
	.memData(memData), 
	.parseAccessSize(parseAccessSize), 
	.parseDone(parseDone), 
	.parseError(parseError)
);

ECE429_Memory m(
  .clock(clock),
  .address(memAddr),
  .datain(memData),
  .access_size(memAccessSize),
  .r_w(memR_W),
  .dataout(dataout)
);

ECE429_Decode d(
  .insn_in(tmp_insn_in),
  .pc_in(decAddr)
);

endmodule
