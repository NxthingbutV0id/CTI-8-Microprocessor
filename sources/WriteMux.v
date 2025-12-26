`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 10:18:02 PM
// Design Name: 
// Module Name: WriteMux
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


module WriteMux(input [3:0] wrSelect, output [15:0] wr);
    assign wr = 16'h0001 << wrSelect;
endmodule
