`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 01:11:40 PM
// Design Name: 
// Module Name: InstructionRegister
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


module InstructionRegister(
    input clk,
    input clk_en,
    input wr,
    input [7:0] dataIn,
    output reg [7:0] regOut
);
    initial regOut = 8'h00;

    always @(posedge clk) begin
        if (clk_en) begin
            if (wr) regOut <= dataIn;
        end
    end
endmodule
