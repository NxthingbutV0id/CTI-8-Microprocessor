`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 10:56:37 AM
// Design Name: 
// Module Name: ProgramROM
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


module ProgramROM(
    input clk,
    input chipSelect,
    input [14:0] address,
    output [7:0] data
);
    wire [7:0] dataOut;
    assign data = (chipSelect) ? dataOut : 8'hZZ;
    
    // 32 kB program
    // Program.coe is what is loaded into here.
    PROGRAM_ROM rom(
        .clka(clk),
        .addra(address),
        .douta(dataOut)
    );
endmodule
