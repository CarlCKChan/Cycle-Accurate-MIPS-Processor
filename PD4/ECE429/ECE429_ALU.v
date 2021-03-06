include "ECE429_ControlBits.v";

module ECE429_ALU( inputA, inputB, inputSHAMT, ALUop, takeBranch, ALUOutput );

input[0:31] inputA;
input[0:31] inputB;
input[0:4] inputSHAMT;
input[0: `ALUOP_LEN_BITS-1 ] ALUop;
output takeBranch;
output[0:31] ALUOutput;

reg takeBranch;
reg[0:31] ALUOutput;


always @(inputA or inputB or inputSHAMT or ALUop)
begin

	case( ALUop )
		5'b00000:				// Add
		begin
			takeBranch = 0;
			ALUOutput = inputA + inputB;
		end
		5'b00001:				// Compare ( < ) Signed
		begin
			takeBranch = ( $signed(inputA) < $signed(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $signed(inputA) < $signed(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		5'b00010:				// Multiply
		begin
			takeBranch = 0;
			ALUOutput = $signed(inputA) * $signed(inputB);
		end
		5'b00011:				// Shift Left Logical
		begin
			takeBranch = 0;
			ALUOutput = inputB << inputSHAMT;
		end
		5'b00100:				// Shift Right Logical
		begin
			takeBranch = 0;
			ALUOutput = inputB >> inputSHAMT;
		end
		5'b00101:				// Shift Left Arithmetic
		begin
			takeBranch = 0;
			ALUOutput = inputB <<< inputSHAMT;
		end
		5'b00110:				// Shift Right Arithmetic
		begin
			takeBranch = 0;
			ALUOutput = inputB >>> inputSHAMT;
		end
		5'b00111:				// AND
		begin
			takeBranch = 0;
			ALUOutput = inputA & inputB;
		end
		5'b01000:				// OR
		begin
			takeBranch = 0;
			ALUOutput = inputA | inputB;
		end
		5'b01001:				// XOR
		begin
			takeBranch = 0;
			ALUOutput = inputA ^ inputB;
		end
		5'b01010:				// NOR
		begin
			takeBranch = 0;
			ALUOutput = ~(inputA | inputB);
		end
		5'b01011:				// Subtract
		begin
			takeBranch = 0;
			ALUOutput = inputA - inputB;
		end
		5'b01100:				// Compare ( < ) Unsigned
		begin
			takeBranch = ( $unsigned(inputA) < $unsigned(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $unsigned(inputA) < $unsigned(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		5'b01101:				// Compare ( >= )
		begin
			takeBranch = ( $unsigned(inputA) >= $unsigned(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $unsigned(inputA) >= $unsigned(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		5'b01110:				// Compare ( == )
		begin
			takeBranch = ( $unsigned(inputA) == $unsigned(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $unsigned(inputA) == $unsigned(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		5'b01111:				// Compare ( != )
		begin
			takeBranch = ( $unsigned(inputA) != $unsigned(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $unsigned(inputA) != $unsigned(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		5'b10000:				// Compare ( <= )
		begin
			takeBranch = ( $unsigned(inputA) <= $unsigned(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $unsigned(inputA) <= $unsigned(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		5'b10001:				// Compare ( > )
		begin
			takeBranch = ( $unsigned(inputA) > $unsigned(inputB) ) ? 1 : 0 ;
			ALUOutput = ( $unsigned(inputA) > $unsigned(inputB) ) ? 32'h00000001 : 32'h00000000 ;
		end
		default:				// Error
		begin
			takeBranch = 0;
			ALUOutput = 32'h0000;
			$display("ERROR: ALUop code not recognized: %b\n", ALUop);
		end
	endcase

end

endmodule

