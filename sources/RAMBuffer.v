`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2025 01:12:10 PM
// Design Name: 
// Module Name: RAMBuffer
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


module RAMBuffer(
    input oe,
    input wr,
    inout [7:0] internalDataBus,
    inout [7:0] externalDataBus
);
    assign internalDataBus = (oe && !wr) ? externalDataBus : 8'hZZ;
    assign externalDataBus = (!oe && wr) ? internalDataBus : 8'hZZ;
endmodule
