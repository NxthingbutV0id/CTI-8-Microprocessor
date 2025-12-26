`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 01:14:23 PM
// Design Name: 
// Module Name: BusDisplay
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


module BusDisplay(
    input clk,
    input [15:0] address,
    input [7:0] data,
    output [7:0] seg,
    output [7:0] an
    );
    wire [2:0] index;
    reg [3:0] digit;
    DigitScan ds(.clk(clk), .digitIndex(index));
    SegmentDriver sd(.num(digit),  .segment(seg));
    
    assign an = ~(8'b1 << index) | 8'b00110000;
    
    always @(*) begin
        case (index)
            3'b000: digit = address[3:0];
            3'b001: digit = address[7:4];
            3'b010: digit = address[11:8];
            3'b011: digit = address[15:12];
            3'b110: digit = data[3:0];
            3'b111: digit = data[7:4];
            default: digit = 0;
        endcase
    end
endmodule
