`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2025 08:26:16 AM
// Design Name: 
// Module Name: DecimalArith
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

// Adds and subtracts in BCD
module DecimalArith(
    input [3:0] sum,
    input Cin, // Carry In
    input Cdin, // Decimal Carry In
    input sub,
    output [3:0] decimal,
    output Cout, // Carry Out
    output Cdout // Decimal Carry Out
);
    reg [4:0] temp;
    always @(*) begin
        if (sub) temp = sum - (((sum > 9) || (sum == 9 && Cdin) || Cin) ? 0 : 6);
        else temp = sum + (((sum > 9) || (sum == 9 && Cdin) || Cin) ? 6 : 0) + Cdin;
    end
    
    assign decimal = temp[3:0];
    assign Cout = Cin | (temp[4] & !sub);
    assign Cdout = temp[4];
endmodule
