`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2025 06:21:40 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Arithmetic Logic Unit V1
module ALU(
    input signed [7:0] A,
    input signed [7:0] B,
    input carryIn,
    input halfCarry,
    input [3:0] opcode,
    input outputEnable,
    output signed [7:0] result,
    output H, // Half-Carry Flag
    output C, // Carry Flag
    output V  // Overflow Flag
);
    localparam // ALU operations
        ALU_ADD  = 4'h0, // Add with carry
        ALU_SUB  = 4'h1, // Subtract with borrow
        ALU_AND  = 4'h2, // Bitwise AND
        ALU_OR   = 4'h3, // Bitwise OR
        ALU_XOR  = 4'h4, // Bitwise XOR
        ALU_SHL  = 4'h5, // Shift Left A
        ALU_SHR  = 4'h6, // Shift Right A
        ALU_CLRB = 4'h7, // Clear Bit in A
        ALU_SETB = 4'h8, // Set Bit in A
        ALU_INC  = 4'h9, // Increment A
        ALU_DEC  = 4'hA, // Decrement A
        ALU_NOT  = 4'hB, // Invert A
        ALU_DAA  = 4'hC, // Decimal adjust A after addition
        ALU_DAS  = 4'hD; // Decimal adjust A after subtraction
    
    reg [8:0] temp;
    wire [4:0] nibbleSum = {1'b0, A[3:0]} + {1'b0, B[3:0]} + {4'b0, carryIn};
    wire [7:0] Bdec = (8'b1 << B[2:0]);
    
    always @(*) begin
        case (opcode)
            ALU_ADD:  temp = {1'b0, A} + {1'b0,  B} + {8'b0, carryIn};
            ALU_SUB:  temp = {1'b0, A} + {1'b0, ~B} + {8'b0, carryIn};
            ALU_AND:  temp = {1'b0, A & B};
            ALU_OR:   temp = {1'b0, A | B};
            ALU_XOR:  temp = {1'b0, A ^ B};
            ALU_SHR:  temp = {A[0], carryIn, A[7:1]};
            ALU_SHL:  temp = {A, carryIn};
            ALU_CLRB: temp = {1'b0, A & ~Bdec};
            ALU_SETB: temp = {1'b0, A | Bdec};
            ALU_INC:  temp = {1'b0, A} + 9'b000000001;
            ALU_NOT:  temp = {1'b0, ~A};
            ALU_DEC:  temp = {1'b0, A} + 9'b011111111;
            ALU_DAA: begin
                temp = {1'b0, A};
                if ((A[3:0] > 9) || halfCarry) temp = temp + 6;
                if ((A[7:4] > 9) || carryIn || (temp[7:4] > 9)) begin // Check carryIn (C flag) or if previous add caused overflow
                    temp = temp + 9'h060;
                    temp[8] = 1'b1; // Set Carry Output
                end
            end
            ALU_DAS: begin
                temp = {1'b0, A};
                if ((A[3:0] > 9) || !halfCarry) temp = temp - 6;
                if ((A[7:4] > 9) || !carryIn) begin
                    temp = temp - 9'h060;
                    temp[8] = 1'b0; // Clear Carry (Borrow)
                end
            end
            default:  temp = 0;
        endcase
    end
    
    assign C = temp[8];
    assign H = (opcode == ALU_ADD) ? nibbleSum[4] : (opcode == ALU_SUB) ? ~nibbleSum[4] : 0;
    assign V = (opcode == ALU_ADD || opcode == ALU_SUB) ? (A[7] ^ temp[7]) & (B[7] ^ temp[7]) : 0;
    assign result = (outputEnable) ? temp[7:0] : 8'hZZ;
endmodule