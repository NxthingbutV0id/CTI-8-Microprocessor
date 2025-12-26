`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 09:59:31 PM
// Design Name: 
// Module Name: Register
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

// Generic register module to connect to a data bus
module Register(input clk, clk_en, oe, wr, inout [7:0] dataBus, output [7:0] regOut);
    wire [7:0] dataIn;
    reg [7:0] data = 0;
    
    assign dataIn = (!oe) ? dataBus : 8'h00;
    assign regOut = data;
    assign dataBus = oe ? data : 8'hZZ;
    
    always @(posedge clk) if (clk_en) if (wr && !oe) data <= dataIn;
endmodule
