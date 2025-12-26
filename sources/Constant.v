`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 07:57:08 PM
// Design Name: 
// Module Name: Constant
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

// 4 bit signed number into 8 bit signed number
module Constant(input [3:0] const, input oe, output [7:0] dataBus);
    assign dataBus = (oe) ? {{4{const[3]}}, const} : 8'hZZ;
endmodule
