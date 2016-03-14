include "ECE429_Memory.v";

module ECE429_Memory_tb();

reg clock;
reg [0:31] address;
reg [0:31] datain;
reg [0:1] access_size;	// 11 for word, 10 for half-word, 01/00 byte
reg r_w;			// 0 to read, 1 to write

wire [0:31] dataout;

initial begin
  
  $display("time\tclock\taddress\tdatain\taccess_size\tr_w\tdataout");
  $monitor("%g\t%h\t%h\t\t\t\t\%h\t\t\t\t%h\t\t%h\t%h", 
            $time, clock, address, datain, access_size, r_w, dataout);          
             
  clock = 0;
  address = 32'h80020000;
  datain = 32'h10001000;
  access_size = 2'b00;
  r_w = 1;
  
  #600
  address = 32'h80020000;
  datain = 32'h10001000;
  access_size = 2'b00;
  r_w = 0;
  
  
  #1600 $finish;
  
end

always begin
  #100 clock = ~clock;
end

always @ (negedge clock) begin
  if ($time < 600) begin 
    access_size = access_size + 1'b1;
    datain = datain + 1'h1;
    address = address + 32'h00010000;
  end else begin
    access_size = access_size + 1'b1;
    address = address + 32'h00010000;
  end
end

ECE429_Memory m(
  .clock(clock),
  .address(address),
  .datain(datain),
  .access_size(access_size),
  .r_w(r_w),
  .dataout(dataout)
);

endmodule
