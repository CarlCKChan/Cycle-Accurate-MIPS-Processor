module ECE429_Decode( insn_in, pc_in );

input[0:31] insn_in;
input[0:31] pc_in;



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
reg signed[0:15] immediate_value;

reg[0:31] nextPC;

/******************************************************************
 *                 EXTRACT DATA FROM INSTRUCTION
 ******************************************************************/
/*
always @(insn_in) begin
	op_code = insn_in[0:5];
end

always @(insn_in) begin
	reg_RS = insn_in[6:10];
end

always @(insn_in) begin
	reg_RT = insn_in[11:15];
end

always @(insn_in) begin
	reg_RD = insn_in[16:20];
end

always @(insn_in) begin
	reg_SHAMT = insn_in[21:25];
end

always @(insn_in) begin
	reg_FUNCT = insn_in[26:31];
end

always @(insn_in) begin
	jump_ADDR = insn_in[6:31];
end

always @(insn_in) begin
	immediate_value = insn_in[16:31];
end

// Calculate the next P (for jumps)
always @(pc_in) begin
	nextPC = pc_in + 4;
end
*/


/******************************************************************
 *                 PARSE INSTRUCTION OPCODE
 *-----------------------------------------------------------------
 * Update whenever the instruction changes
 ******************************************************************/
always @( insn_in )
begin

	op_code = insn_in[0:5];
	reg_RS = insn_in[6:10];
	reg_RT = insn_in[11:15];
	reg_RD = insn_in[16:20];
	reg_SHAMT = insn_in[21:25];
	reg_FUNCT = insn_in[26:31];
	jump_ADDR = insn_in[6:31];
	immediate_value = insn_in[16:31];
	nextPC = pc_in + 4;
	
	
	// Check whether a NOP or a valid instruction
	if( insn_in == 32'h00000000 ) begin
		$display("NOP\n");
	end else begin
	
		case( op_code )
		
			// SPECIAL opcode
			6'b000000:
			begin
				case( reg_FUNCT )
				
					6'b000000:				// SLL
					begin
						$display("SLL $%d, $%d, $%d\n", reg_RD, reg_RT, reg_SHAMT);
					end
					6'b000010:				// SRL
					begin
						$display("SRL $%d, $%d, $%d\n", reg_RD, reg_RT, reg_SHAMT);
					end
					6'b000011:				// SRA
					begin
						$display("SRA $%d, $%d, $%d\n", reg_RD, reg_RT, reg_SHAMT);
					end
					6'b001000:				// JR
					begin
						$display("JR $%d\n", reg_RS);			// TODO: What do with other values in insn?  What is 10-bit zeroes and "hint"?
					end
					6'b100000:				// ADD
					begin
						$display("ADD $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100001:				// ADDU
					begin
						$display("ADDU $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100010:				// SUB
					begin
						$display("SUB $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100011:				// SUBU
					begin
						$display("SUBU $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100100:				// AND
					begin
						$display("AND $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100101:				// OR
					begin
						$display("OR $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100110:				// XOR
					begin
						$display("XOR $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b100111:				// NOR
					begin
						$display("NOR $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b101010:				// SLT
					begin
						$display("SLT $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					6'b101011:				// SLTU
					begin
						$display("SLTU $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					default:				// Error
					begin
						$display("Error decoding SPECIAL opcode: %b\n", reg_FUNCT);
					end
					
				endcase
			end
			
			// REGIMM opcode
			6'b000001:
			begin
				case( reg_RT )
				
					5'b00000:				// BLTZ
					begin
						$display("BLTZ $%d, %d\n", reg_RS, {immediate_value, 2'b00});
					end
					5'b00001:				// BGEZ
					begin
						$display("BGEZ $%d, %d\n", reg_RS, {immediate_value, 2'b00});
					end
					default:				// Error
					begin
						$display("Error decoding REGIMM opcode\n");
					end
					
				endcase
			end
			
			// J
			6'b000010:
			begin
				$display("J 0x%h\n", {nextPC[0:3], jump_ADDR, 2'b00});		// TODO: Calculate jump address
			end
			
			// JAL
			6'b000011:
			begin
				$display("JAL 0x%h\n", {nextPC[0:3], jump_ADDR, 2'b00});		// TODO: Calculate jump address
			end
			
			// BEQ
			6'b000100:
			begin
				$display("BEQ $%d, $%d, 0x%h\n", reg_RS, reg_RT, nextPC + $signed({immediate_value, 2'b00}));
			end
			
			// BNE
			6'b000101:
			begin
				$display("BNE $%d, $%d, 0x%h\n", reg_RS, reg_RT, nextPC + $signed({immediate_value, 2'b00}));
			end
			
			// BLEZ
			6'b000110:
			begin
				$display("BLEZ $%d, 0x%h\n", reg_RS, nextPC + $signed({immediate_value, 2'b00}));
			end
			
			// BGTZ
			6'b000110:
			begin
				$display("BGTZ $%d, 0x%h\n", reg_RS, nextPC + $signed({immediate_value, 2'b00}));
			end
			
			// ADDIU
			6'b001001:
			begin
				$display("ADDIU $%d, $%d, %d\n", reg_RT, reg_RS, immediate_value);
			end
			
			// SLTI
			6'b001010:
			begin
				$display("SLTI $%d, $%d, %d\n", reg_RT, reg_RS, immediate_value);
			end
			
			// ORI
			6'b001101:
			begin
				$display("ORI $%d, $%d, 0x%h\n", reg_RT, reg_RS, immediate_value);
			end
			
			// LUI
			6'b001111:
			begin
				$display("LUI $%d, 0x%h\n", reg_RT, immediate_value);
			end
			
			// SPECIAL2
			6'b011100:
			begin
				case( reg_FUNCT )
					6'b000010:				// MUL
					begin
						$display("MUL $%d, $%d, $%d\n", reg_RD, reg_RS, reg_RT);
					end
					default:				// Error
					begin
						$display("Error decoding SPECIAL2 opcode\n");
					end
				endcase
			end
			
			// LB
			6'b100000:
			begin
				$display("LB $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
			end
			
			// LW
			6'b100011:
			begin
				$display("LW $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
			end
			
			// LBU
			6'b100100:
			begin
				$display("LBU $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
			end
			
			// SB
			6'b101000:
			begin
				$display("SB $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
			end
			
			// SW
			6'b101011:
			begin
				$display("SW $%d, %d($%d)\n", reg_RT, immediate_value, reg_RS);
			end
			
			
			// Error: Could not parse instruction
			default :
			begin
				$display("ERROR: Opcode not recognized: %b\n", insn_in);
			end
		
		endcase
		
	end

end



endmodule
