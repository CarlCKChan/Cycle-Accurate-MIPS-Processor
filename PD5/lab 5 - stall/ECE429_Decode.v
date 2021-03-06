include "ECE429_ControlBits.v";

module ECE429_Decode( insn_in, pc_in, controlBitVector, op_code, reg_RS, reg_RT, reg_RD, reg_SHAMT, reg_FUNCT, jump_ADDR, immediate_value, readRs, readRt);

input[0:31] insn_in;
input[0:31] pc_in;
output[0:`CONTROL_BITS_END] controlBitVector;
output[0:5] op_code;
output[0:4] reg_RS;
output[0:4] reg_RT;
output[0:4] reg_RD;
output[0:4] reg_SHAMT;
output[0:5] reg_FUNCT;
output[0:25] jump_ADDR;
output[0:15] immediate_value;
output readRs;
output readRt;




reg[0:`CONTROL_BITS_END] controlBitVector;			// controlBitVector = { 1'b, 1'b, 2'b, 5'b, 1'b, 1'b, 1'b, 1'b , 1'b, 2'b, 1'b, 1'b };


/* R-Type
 *    A     B     C     D     E     F
 * |-----------------------------------|
 * |  6  |  5  |  5  |  5  |  5  |  6  |
 * |-----------------------------------|
 *
 * J-Type
 *    A                G
 * |-----------------------------------|
 * |  6  |             26              |
 * |-----------------------------------|
 *
 * I-Type
 *    A     B     C          H
 * |-----------------------------------|
 * |  6  |  5  |  5  |       16        |
 * |-----------------------------------|
 *
 *
 *         Letter            Reg Name
 *           A               op_code
 *           B               reg_RS
 *           C               reg_RT
 *           D               reg_RD
 *           E               reg_SHAMT
 *           F               reg_FUNCT
 *           G               jump_ADDR
 *           H               immediate_value
 *
 */
reg[0:5] op_code;
reg[0:4] reg_RS;
reg[0:4] reg_RT;
reg[0:4] reg_RD;
reg[0:4] reg_SHAMT;
reg[0:5] reg_FUNCT;
reg[0:25] jump_ADDR;
reg[0:15] immediate_value;
reg readRs;						// Whether the instruction actually uses Rs
reg readRt;						// Whether the insturction acutally uses Rt

reg[0:31] nextPC;


/******************************************************************
 *                 PARSE INSTRUCTION OPCODE
 *-----------------------------------------------------------------
 * Update whenever the instruction changes
 ******************************************************************/
always @( insn_in )
begin

	// Extract data from instruction
	op_code = insn_in[0:5];
	reg_RS = insn_in[6:10];
	reg_RT = insn_in[11:15];
	reg_RD = (insn_in[0:5] == 6'b000011) ? 5'b11111 : insn_in[16:20];		// JAL is hardcoded to set $31
	reg_SHAMT = (insn_in[0:5] == 6'b001111) ? 5'b10000 : insn_in[21:25];		// SHAMT is hardcoded for LUI
	reg_FUNCT = insn_in[26:31];
	jump_ADDR = insn_in[6:31];
	immediate_value = insn_in[16:31];
	nextPC = pc_in + 4;
	
	
	// Check whether a NOP or a valid instruction
	if( insn_in == 32'h00000000 ) begin
		$display("NOP\n");
		controlBitVector = `NOP_CONTROL_BITS;
		readRs = 0;
		readRt = 0;
	end else begin
	
		case( op_code )
		
			// SPECIAL opcode
			6'b000000:
			begin
				case( reg_FUNCT )
				
					6'b000000:				// SLL
					begin
						$display("SLL $%d, $%d, $%d\n", reg_RD, reg_RT, reg_SHAMT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00011, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 0;
						readRt = 1;
					end
					6'b000010:				// SRL
					begin
						$display("SRL $%d, $%d, $%d\n", reg_RD, reg_RT, reg_SHAMT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00100, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 0;
						readRt = 1;
					end
					6'b000011:				// SRA
					begin
						$display("SRA $%d, $%d, $%d\n", reg_RD, reg_RT, reg_SHAMT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00110, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 0;
						readRt = 1;
					end
					6'b001000:				// JR
					begin
						$display("JR $%d\n", reg_RS);			// TODO: What do with other values in insn?  What is 10-bit zeroes and "hint"?
						controlBitVector = { 1'b0, 1'b1, 2'b00, 5'b00000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b1 };
						readRs = 1;
						readRt = 0;
					end
					6'b100000:				// ADD
					begin
						$display("ADD $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00000, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100001:				// ADDU
					begin
						$display("ADDU $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00000, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100010:				// SUB
					begin
						$display("SUB $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b01011, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100011:				// SUBU
					begin
						$display("SUBU $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b01011, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100100:				// AND
					begin
						$display("AND $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00111, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100101:				// OR
					begin
						$display("OR $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b01000, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100110:				// XOR
					begin
						$display("XOR $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b01001, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b100111:				// NOR
					begin
						$display("NOR $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b01010, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b101010:				// SLT
					begin
						$display("SLT $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00001, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					6'b101011:				// SLTU
					begin
						$display("SLTU $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b01100, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					default:				// Error
					begin
						$display("Error decoding SPECIAL opcode: %b\n", reg_FUNCT);
						controlBitVector = `NOP_CONTROL_BITS;
						readRs = 0;
						readRt = 0;
					end
					
				endcase
			end
			
			// REGIMM opcode
			6'b000001:
			begin
				case( reg_RT )
				
					5'b00000:				// BLTZ
					begin
						$display("BLTZ $%d, %d\n", reg_RS, nextPC + { {14{immediate_value[0]}},immediate_value, 2'b00});
						controlBitVector = { 1'b1, 1'b0, 2'b00, 5'b00001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					5'b00001:				// BGEZ
					begin
						$display("BGEZ $%d, %d\n", reg_RS, nextPC + { {14{immediate_value[0]}},immediate_value, 2'b00});
						controlBitVector = { 1'b1, 1'b0, 2'b00, 5'b01101, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					default:				// Error
					begin
						$display("Error decoding REGIMM opcode\n");
						controlBitVector = `NOP_CONTROL_BITS;
						readRs = 0;
						readRt = 0;
					end
					
				endcase
			end
			
			// J
			6'b000010:
			begin
				$display("J 0x%h\n", {nextPC[0:3], jump_ADDR, 2'b00});		// TODO: Calculate jump address
				controlBitVector = { 1'b0, 1'b1, 2'b00, 5'b00000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 0;
				readRt = 0;
			end
			
			// JAL
			6'b000011:
			begin
				$display("JAL 0x%h\n", {nextPC[0:3], jump_ADDR, 2'b00});		// TODO: FIND CONTROL CODE FOR THIS
				controlBitVector = { 1'b0, 1'b1, 2'b00, 5'b00000, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b1, 1'b0 };
				readRs = 0;
				readRt = 0;
			end
			
			// BEQ
			6'b000100:
			begin
				$display("BEQ $%d, $%d, 0x%h\n", reg_RS, reg_RT, nextPC + { {14{immediate_value[0]}},immediate_value, 2'b00});
				controlBitVector = { 1'b1, 1'b0, 2'b00, 5'b01110, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 1;
			end
			
			// BNE
			6'b000101:
			begin
				$display("BNE $%d, $%d, 0x%h\n", reg_RS, reg_RT, nextPC + { {14{immediate_value[0]}},immediate_value, 2'b00});
				controlBitVector = { 1'b1, 1'b0, 2'b00, 5'b01111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 1;
			end
			
			// BLEZ
			6'b000110:
			begin
				$display("BLEZ $%d, 0x%h\n", reg_RS, nextPC + { {14{immediate_value[0]}},immediate_value, 2'b00});
				controlBitVector = { 1'b1, 1'b0, 2'b00, 5'b10000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 1;
			end
			
			// BGTZ
			6'b000111:
			begin
				$display("BGTZ $%d, 0x%h\n", reg_RS, nextPC + { {14{immediate_value[0]}},immediate_value, 2'b00});
				controlBitVector = { 1'b1, 1'b0, 2'b00, 5'b10001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 1;
			end
			
			// ADDIU
			6'b001001:
			begin
				$display("ADDIU $%d, $%d, %d\n", reg_RT, reg_RS, $signed(immediate_value));
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 0;
			end
			
			// SLTI
			6'b001010:
			begin
				$display("SLTI $%d, $%d, %d\n", reg_RT, reg_RS, immediate_value);
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00001, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 0;
			end
			
			// ORI
			6'b001101:
			begin
				$display("ORI $%d, $%d, 0x%h\n", reg_RT, reg_RS, immediate_value);
				controlBitVector = { 1'b0, 1'b0, 2'b10, 5'b01000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 0;
			end
			
			// LUI
			6'b001111:
			begin
				$display("LUI $%d, 0x%h\n", reg_RT, immediate_value);
				controlBitVector = { 1'b0, 1'b0, 2'b10, 5'b00011, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 0;
				readRt = 0;
			end
			
			// SPECIAL2
			6'b011100:
			begin
				case( reg_FUNCT )
					6'b000010:				// MUL
					begin
						$display("MUL $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
						controlBitVector = { 1'b0, 1'b0, 2'b00, 5'b00010, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0 };
						readRs = 1;
						readRt = 1;
					end
					default:				// Error
					begin
						$display("Error decoding SPECIAL2 opcode\n");
						controlBitVector = `NOP_CONTROL_BITS;
						readRs = 0;
						readRt = 0;
					end
				endcase
			end
			
			// LB
			6'b100000:
			begin
				$display("LB $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00000, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 2'b00, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 0;
			end
			
			// LW
			6'b100011:
			begin
				$display("LW $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00000, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 0;
			end
			
			// LBU
			6'b100100:
			begin
				$display("LBU $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00000, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 0;
			end
			
			// SB
			6'b101000:
			begin
				$display("SB $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00000, 1'b1, 1'b0, 1'b0, 1'b0 , 1'b0, 2'b00, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 1;
			end
			
			// SW
			6'b101011:
			begin
				$display("SW $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
				controlBitVector = { 1'b0, 1'b0, 2'b01, 5'b00000, 1'b1, 1'b0, 1'b0, 1'b0 , 1'b0, 2'b11, 1'b0, 1'b0 };
				readRs = 1;
				readRt = 1;
			end
			
			
			// Error: Could not parse instruction
			default :
			begin
				$display("ERROR: Opcode not recognized: %b\n", insn_in);
				controlBitVector = `NOP_CONTROL_BITS;
				readRs = 0;
				readRt = 0;
			end
		
		endcase
		
	end

end

endmodule
