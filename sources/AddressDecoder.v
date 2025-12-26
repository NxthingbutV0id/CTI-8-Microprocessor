`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 11:37:50 PM
// Design Name: 
// Module Name: AddressDecoder
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


module AddressDecoder(
    input [15:0] address,
    output reg [2:0] chipSelect
);
    // MEMORY MAP:
    // $0000 - $3FFF = Work RAM
    // $6000 - $6001 = UART
    // $8000 - $FFFF = Program ROM
    parameter // Memory Mapping controller
        RAM = 2'b00,
        ROM = 2'b01,
        UART = 2'b10;
    
    always @(*) begin
        if (address <= 16'h3FFF) chipSelect = 3'b1 << RAM;
        else if (address >= 16'h6000 && address <= 16'h600F) chipSelect = 3'b1 << UART;
        else if (address > 16'h7FFF) chipSelect = 3'b1 << ROM;
    end
endmodule
