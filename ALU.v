`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:54:08 08/30/2011 
// Design Name: 
// Module Name:    alu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ALU( A, B, C, Opcode, Flags, Cin
    );
input [15:0] A, B;
input [7:0] Opcode;
input Cin;
output reg [15:0] C;
/* ZCFNL
 * 4 = Zero flag
 * 3 = carry flag
 * 2 = Overflow flag
 * 1 = Negative flag
 * 0 = Low flag
 */
output reg [4:0] Flags;

// opcode hi = 0000
parameter AND = 4'b0001;
parameter OR = 4'b0010;
parameter XOR = 4'b0011;
parameter NOT = 4'b0100;
parameter ADD = 4'b0101;
parameter ADDU = 4'b0110;
parameter ADDC = 4'b0111;
parameter ADDCU = 4'b1000;
parameter SUB = 4'b1001;
// 4'b1010
parameter CMP = 4'b1011;
parameter CMPU = 4'b1111;
// 4'b1100, 4'b1101, and 4'b1110

// opcodes 4'b0001-4'b0100 can be used (?)

// opcode hi = 1000
parameter LSHI = 4'b0000;		// can also be 0001
parameter LSH = 4'b0100;

// opcode hi = 1001 = SUBI
// ONLY assign 1001 to SUBI - the last 4 bits of opcode will be used for the immediate add operation

// opcode hi = 1011 = CMPI
// ONLY assign 1011 to CMPI - the last 4 bits of opcode will be used for the immediate add operation

/*
parameter ADDCUI = 8'b???? immHi;
parameter CMPUI = 8'b??? immHi;
parameter RSH = 8'b???
parameter RSHI = 8'b???? immHi;
parameter ALSH = 8'b???
parameter ARSH = 8'b???
*/

/* We will do: ADD, ADDI, ADDU, ADDUI, ADDC, ADDCU, ADDCUI, ADDCI, SUB, SUBI, CMP, CMPI, CMPU/I, AND,
OR, XOR, NOT, LSH, LSHI, RSH, RSHI, ALSH, ARSH, NOP/WAIT      */


always @(A, B, Opcode, Cin)
begin
	C = 16'bx;
	Flags = 5'bx;
	// check the first four bits of the opcode
	case (Opcode[7:4])
		4'b0000:
		begin
			case (Opcode[3:0])
				AND:
				begin
					C = A & B;
					
					Flags[4] = (C == 16'b0000_0000_0000_0000);
					
					// Set the carry(3), overflow(2), negative(1), and low(0) flags to 0
					Flags[3:0] = 4'b0000;
				end
					
				OR:
				begin
					C = A | B;
					
					Flags[4] = (C == 16'b0000_0000_0000_0000);
					
					Flags[3:0] = 4'b0000;
				end
					
				XOR:
				begin
					C = A ^ B;
					
					Flags[4] = (C == 16'b0000_0000_0000_0000);
						
					Flags[3:0] = 4'b0000;
				end
					
				NOT:
				begin
					C = ~A;
					
					Flags[4] = (C == 16'b0000_0000_0000_0000);
						
					Flags[3:0] = 4'b0000;
				end
					
				ADD:
				begin
					C = A + B;
					
					// Set the Zero flag (4)
					Flags[4] = (C == 16'b0000_0000_0000_0000);
						
					// Set the Overflow Flag (2)
					Flags[2] = ((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15]));

					// Set the Carry(3), negative(1), and low(0) flags to 0
					Flags[1:0] = 2'b00; Flags[3] = 1'b0;
				end
				
				ADDU:
				begin
					// The carry flag is set with the C assignment
					{Flags[3], C} = A + B;
					
					// Set the 0 flag(4)
					Flags[4] = (C == 16'b0000_0000_0000_0000);
					
					Flags[2] = ((A[15] | B[15]) & ~C[15]); // Check for overflow
						
					// The rest of the flags will be 0
					Flags[1:0] = 2'b00;
				end
					
				ADDC:
				begin
					{Flags[3], C} = A + B + Cin;
					
					// Set the Zero flag (4)
					Flags[4] = (C == 16'b0000_0000_0000_0000);
						
					// Set the Overflow Flag (2)
					Flags[2] = ((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])); 

					// Set the negative(1) and low(0) flags to 0
					Flags[1:0] = 2'b00; 
				end
					
				ADDCU:
				begin
					// The carry flag is set with the C assignment
					{Flags[3], C} = A + B + Cin;
					
					// Set the zero flag(4)
					Flags[4] = (C == 16'b0000_0000_0000_0000); 
					
					Flags[2] = ((A[15] | B[15]) & ~C[15]); // Check for overflow
						
					// The rest of the flags will be 0
					Flags[1:0] = 2'b00;
				end
				
				SUB:
				begin
					C = A - B;
					// Set the zero(4) flag
					Flags[4] = (C == 16'b0000_0000_0000_0000); 
					
					// Set the overflow flag (2)
					Flags[2] = ((~A[15] & B[15] & C[15]) | (A[15] & ~B[15] & ~C[15]));
					
					// Set the Carry(3), negative(1), and low(0) flags to 0
					Flags[1:0] = 2'b00; Flags[3] = 1'b0;
				end
				
				CMP:
				begin
					// Is this differenct from the explicit sign checks also coded below?
					// Does this method have redudant code?
					if( $signed(A) < $signed(B) ) 
						Flags[1:0] = 2'b11;
					else 
						Flags[1:0] = 2'b00;
						
					Flags[4] = ($signed(A) == $signed(B)); // set the zero flag
						
					C = 16'b0000_0000_0000_0000;
					Flags[3:2] = 2'b00;
				end
				
				CMPU:
				begin
					Flags[0] = (A < B);  // negative flag not set for unsigned operations
					Flags[3:1] = 3'b000;
					Flags[4] = (A == B);
					C = 16'b0000_0000_0000_0000;
				end
				
				default: 		// used for WAIT and NOP - they're the same thing
				begin
					// when there is no opcode to use
					C = 16'bx;
					Flags = 5'b00000;
				end
			endcase
		end
	
		4'b0101:
		begin
			// reserved for ADDI, add immediate, ONLY
			// that way, when this is called, ALU knows immediately that it just wants to do an add immediate
			// in immediate instructions, the low bit of Opcode is the immediate
			C = A + Opcode[7:0];
			
			// Set the Zero flag (4)
			Flags[4] = (C == 16'b0000_0000_0000_0000); 
				
			// Set the Overflow Flag (2)
			Flags[2] = ((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])); 

			// Set the Carry(3), negative(1), and low(0) flags to 0
			Flags[1:0] = 2'b00; Flags[3] = 1'b0;		
		end
		
		4'b0110:
		begin
			// for ADDUI, add unsigned immediate
			// just like above in ADDI, except for unsigned integers
			// reserved for ADDI, add immediate, ONLY
			// that way, when this is called, ALU knows immediately that it just wants to do an add immediate
			// in immediate instructions, the low bit of Opcode is the immediate

			// concatenate the last 4 bits of opcode with the last 4 bits of B in a temporary register
			// ** treat B as the immediate value.  We will take care of it elsewhere.

			C = A + {8'b0, Opcode[7:0]};
			
			// Set the Zero flag (4)
			Flags[4] =  (C == 16'b0000_0000_0000_0000); 
				
			Flags[2] = ((A[15] | B[15]) & ~C[15]); // Check for overflow
						
			// The rest of the flags will be 0
			Flags[1:0] = 2'b00;
		end
			
		4'b0111:
		begin
			// ADDCI, add with a carry and an immediate (?)
			// same as the previous two cases, except with a carry
			// reserved for ADDI, add immediate, ONLY
			// that way, when this is called, ALU knows immediately that it just wants to do an add immediate
			// concatenate the last 4 bits of opcode with the last 4 bits of B in a temporary register
			// ** treat B as the immediate value.  We will take care of it elsewhere.
			C = A + Opcode[7:0] + Cin;
			
			// Set the Zero flag (4)
			Flags[4] = (C == 16'b0000_0000_0000_0000); 
				
			// Set the Overflow Flag (2)
			Flags[2] = ((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])); 

			// Set the Carry(3), negative(1), and low(0) flags to 0
			Flags[1:0] = 2'b00; Flags[3] = 1'b0;
		end
		
		4'b1000:
		begin
			// opcode is for ALL shifts
			case (Opcode[3:0])
				LSHI:
				// Left shift of A by B bits
				begin
					C = A << Opcode[7:0];
					Flags[4] = (C == 16'b0000_0000_0000_0000);
			
					Flags[3:0] = 4'b0000;
				end
				LSH:
				begin
					// Left shift of A by 1 bit (no sign extension)
					C = A << 1;
					Flags[4] = (C == 16'b0000_0000_0000_0000);
				
					Flags [3:0] = 4'b0000;
				end
				
			default: 		// used for WAIT and NOP - they're the same thing
				begin
					// when there is no opcode to use
					C = 16'bx;
					Flags = 5'b00000;
				end	
			endcase
		end
		
		default: 		// used for WAIT and NOP - they're the same thing
				begin
					// when there is no opcode to use
					C = 16'bx;
					Flags = 5'b00000;
				end
	endcase
end

endmodule
