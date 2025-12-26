`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 08:00:26 PM
// Design Name: 
// Module Name: EffectiveAddressRegister
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


module EffectiveAddressRegister(
    input clk, clk_en, oe, wr, LHB, incEnable, addIndex,
    inout [7:0] data,
    output [15:0] addressOut
);
    reg [15:0] EA = 16'hFFFC; // Reset Vector
    wire [7:0] dataIn, dataOut;
    wire [15:0] index = {8'h00, dataIn};
    
    assign dataOut = (LHB) ? EA[15:8] : EA[7:0];
    assign dataIn = (!oe) ? data : 8'h00;
    assign data = (oe) ? dataOut : 8'hZZ;
    
    always @(posedge clk) begin
        if (clk_en) begin
            if (wr) begin
                if (LHB) EA <= {dataIn, EA[7:0]};
                else EA <= {EA[15:8], dataIn};
            end else if (incEnable) EA <= EA + 1;
            else if (addIndex) EA <= EA + index;
        end
    end
    
    assign addressOut = EA;
endmodule
