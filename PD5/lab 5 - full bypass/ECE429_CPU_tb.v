module ECE429_CPU_tb();

reg clock;
reg parseEnable;

reg[0:31] maxfetchAddr;

wire[0:31] parseAddr;
wire[0:31] parseData;
wire[0:1] parseAccessSize;
wire parseDone;
wire parseError;
wire cpuStall;

initial begin
	clock = 0;
	maxfetchAddr = 32'h00000000;
	parseEnable = 0;
	#1
	parseEnable = 1;
	#1
	parseEnable = 0;
	
	@(posedge clock);
end

always begin
	#10 clock = ~clock;
end

assign cpuStall = ~parseDone;

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

ECE429_CPU c(
	.clock(clock),
	.stall(cpuStall),
	.parseAddr(parseAddr),
	.maxfetchAddr(maxfetchAddr),
	.parseData(parseData),
	.parseAccessSize(parseAccessSize)
);

ECE429_SRECParser #("SimpleAdd.srec") s(
	.clock(clock),
	.parseEnable(parseEnable),
	.parseAddr(parseAddr), 
	.memData(parseData), 
	.parseAccessSize(parseAccessSize), 
	.parseDone(parseDone), 
	.parseError(parseError)
);

endmodule