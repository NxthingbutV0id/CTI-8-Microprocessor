`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 10:08:40 PM
// Design Name: 
// Module Name: Counter
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

// Counter Register, used for the stack pointer
module Counter(
    input clk, clk_en, oe, wr, dir, en,
    inout [7:0] dataBus,
    output [7:0] addrOut
);
    wire [7:0] dataIn;
    reg [7:0] CNT = 8'hFF;
    assign dataIn = (!oe) ? dataBus : 8'h00;
    assign dataBus = (oe) ? CNT[7:0] : 8'hZZ;
    assign addrOut = CNT;
    
    always @(posedge clk) begin
        if (clk_en) begin
            if (wr) CNT <= {dataIn};
            else if (en) CNT <= (dir) ? CNT - 1 : CNT + 1;
        end
    end
endmodule
