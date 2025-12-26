`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 10:56:37 AM
// Design Name: 
// Module Name: SystemMemory
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


module SystemMemory(
    input clk,
    input chipSelect,
    input writeEnable,
    inout [7:0] data,
    input [13:0] address
);
    wire [7:0] dataIn = (chipSelect & writeEnable) ? data : 8'h00;
    wire [7:0] dataOut;
    assign data = (chipSelect & !writeEnable) ? dataOut : 8'hZZ;
    
    // 16 kB work ram
    SYS_RAM ram(
        .clka(clk),
        .wea(writeEnable),
        .addra(address),
        .dina(dataIn),
        .douta(dataOut)
    );
endmodule
