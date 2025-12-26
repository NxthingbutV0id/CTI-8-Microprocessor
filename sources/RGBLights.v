`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 05:08:41 PM
// Design Name: 
// Module Name: RGBLights
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


module RGBLights(
    input reset,
    input INT,
    input wr,
    output [2:0] lights
);
    wire a, b, R, G, B;
    nor NOR1(a, INT, wr);
    or OR1(R, a, reset);
    or OR2(G, INT, reset);
    not NOT1(B, R);
    
    assign lights = {R, G, B};
endmodule
