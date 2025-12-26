`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 06:22:10 PM
// Design Name: 
// Module Name: DigitScan
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

// Controls which digit should be on (0-7), allows for all digits to be on at once
module DigitScan(input clk, output reg [2:0] digitIndex);
    reg [13:0] scanner = 0;
    always@(posedge clk) begin
        if (scanner < 12500) begin // 100 MHz / 12500 = 8 kHz
            scanner <= scanner + 1;
        end else begin
            scanner <= 0;
            digitIndex <= digitIndex + 1;
        end
    end
endmodule
