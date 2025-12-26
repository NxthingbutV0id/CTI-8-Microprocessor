`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 10:18:02 PM
// Design Name: 
// Module Name: ReadMux
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


module ReadMux(input [3:0] oeSelect, output [15:0] oe);
    assign oe = 16'h0001 << oeSelect;
endmodule
