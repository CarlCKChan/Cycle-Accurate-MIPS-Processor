// Define the offsets for the bits in the control bit vector
`define BR_OFFSET		0
`define JP_OFFSET		`BR_OFFSET+1

`define ALUINB_BEGIN_OFFSET	`JP_OFFSET+1
`define ALUINB_LEN_BITS		2
`define ALUINB_END_OFFSET	`ALUINB_BEGIN_OFFSET+(`ALUINB_LEN_BITS-1)

`define ALUOP_BEGIN_OFFSET	`ALUINB_END_OFFSET+1
`define ALUOP_LEN_BITS		5
`define ALUOP_END_OFFSET	`ALUOP_BEGIN_OFFSET+(`ALUOP_LEN_BITS-1)

`define DMWE_OFFSET		`ALUOP_END_OFFSET+1
`define RWE_OFFSET		`DMWE_OFFSET+1
`define RDST_OFFSET		`RWE_OFFSET+1
`define RWD_OFFSET		`RDST_OFFSET+1
`define BSX_OFFSET		`RWD_OFFSET+1		// If should sign-extend byte read from memory

`define MEMAS_BEGIN_OFFSET	`BSX_OFFSET+1		// Maps to access size for data memory operations (load/store)
`define MEMAS_LEN_BITS		2
`define MEMAS_END_OFFSET	`MEMAS_BEGIN_OFFSET+(`MEMAS_LEN_BITS-1)

`define JALOP_OFFSET		`MEMAS_END_OFFSET+1

`define CONTROL_BITS_END	`JALOP_OFFSET		// The last index in the control bit vector

`define NOP_CONTROL_BITS	17'b00000000000000000	// Control bits for a NOP

/*
 * For the control vector, the bits:
 *		BR		1 <- branch
 *
 *		JP		1 <- jump
 *
 *		ALUinB		0 <- Normal instructions
 *				1 <- signed immediate, load, store (use sign extended immediate)
 *				2 <- Unsigned immediate
 *
 *		ALUop		0 <- add
 *				1 <- compare (<) signed
 *				2 <- multiply
 *				3 <- shift left logical
 *				4 <- shift right logical
 *				5 <- shift left arithmetic
 *				6 <- shift right arithmetic
 *				7 <- AND
 *				8 <- OR
 *				9 <- XOR
 *				10 <- NOR
 *				11 <- subtract
 *				12 <- compare (<) unsigned
 *				13 <- compare (>=)
 *				14 <- compare (==)
 *				15 <- compare (!=)
 *				16 <- compare (<=)
 *				17 <- compare (>)
 *
 *		DMwe		1 <- store
 *
 *		Rwe		0 <- not register op or load
 *				1 <- register op or load (ex. lw, lui, ori)
 *
 *		Rdst		0 <- immediate (use rt address as rd address)
 *				1 <- else (use rd address as rd address)
 *
 *		Rwd		0 <- not a load
 *				1 <- load (use value from memory)
 *
 *		Bsx		0 <- For LW and LBU (don't do anything to value from memory)
 *				1 <- For LB (sign-extend the byte read from memory)
 *
 *		MEMas		11 <- Word
 *				10 <- Half-Word
 *				Else <- Byte
 *
 *		JALop		0 <- not JAL (give normal values to ALU)
 *				1 <- JAL (set ALU inputs: A=PC, B=8)
 */