
module test();

reg[0:15] testing;
reg[0:31] testing2;

initial begin
	testing = 16'h0000;
	testing2 = {16'hFFFF, testing};
	$display("%d\n", testing2);

end

endmodule
