`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 08:00:26 PM
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCounter(
    input clk, clk_en, oe, wr, LHB, incEnable, offsetEnable,
    inout [7:0] data,
    output [15:0] addressOut
);
    reg [15:0] PC = 16'hFE00;
    wire [7:0] dataIn, dataOut;
    wire [15:0] offset = {{8{dataIn[7]}}, dataIn};
    
    assign dataOut = (LHB) ? PC[15:8] : PC[7:0];
    assign dataIn = (!oe) ? data : 8'h00;
    assign data = (oe) ? dataOut : 8'hZZ;
    
    always @(posedge clk) begin
        if (clk_en) begin
            if (wr) begin
                if (LHB) PC <= {dataIn, PC[7:0]};
                else PC <= {PC[15:8], dataIn};
            end else if (incEnable) PC <= PC + 1;
            else if (offsetEnable) PC <= PC + offset;
        end
    end
    
    assign addressOut = PC;
endmodule
