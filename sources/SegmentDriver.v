`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 05:08:34 PM
// Design Name: 
// Module Name: SegmentDriver
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


// Drives the logic for the segments
module SegmentDriver(input [3:0] num, output [7:0] segment);
    wire w = num[3];
    wire x = num[2];
    wire y = num[1];
    wire z = num[0];
    
    // Truth Table:
    // Number | Segments (1 = OFF, 0 = ON)
    //   wxyz | ABCDEFG
    //   0000 | 0000001
    //   0001 | 1001111
    //   0010 | 0010010
    //   0011 | 0000110
    //   0100 | 1001100
    //   0101 | 0100100
    //   0110 | 0100000
    //   0111 | 0001111
    //   1000 | 0000000
    //   1001 | 0000100
    //   1010 | 0001000
    //   1011 | 1100000
    //   1100 | 0110001
    //   1101 | 1000010
    //   1110 | 0110000
    //   1111 | 0111000
    
    wire g1, g2, g3, g4, g7, g8, g10, g11, g12, g13, g14, g15, g17, g18, g19, g20, g21, g22, g23, g24, g25, g26, g27, g28, g29, g30, g31, g32, g33, g34, g35, g36, w_, x_, y_, z_;
    not NOT_W(w_, w);
    not NOT_X(x_, x);
    not NOT_Y(y_, y);
    not NOT_Z(z_, z);
    or OR1(g1, w, x);
    or OR2(g2, y, x);
    nand NAND1(g3, w, g2);
    and AND1(g4, g3, z);
    and AND2(g7, y_, x, w_);
    or OR3(g8, g7, g4);
    or OR4(g10, g8, x_, z);
    and AND3(g11, g10, g1); 
    nor NOR1(g12, g11, y);
    and AND4(g13, g8, x, y);
    or OR5(g14, g13, g12);
    nand NAND2(g15, g14, g8);
    or OR6(g17, g8, z_);
    or OR7(g18, g17, y);
    or OR8(g19, g14, g1);
    nand NAND3(g20, g15, g19, g18);
    and AND5(g21, g20, g14);
    not NOT1(g22, g20);
    and AND6(g23, g22, y, x_);
    nor NOR2(g24, g23, g8);
    nor NOR3(g25, g24, z);
    and AND7(g26, x, y, z);
    or OR9(g27, g26, g25, g21);
    nand NAND4(g28, g27, y_);
    or OR10(g29, g27, g17);
    nand NAND5(g30, g28, g29);
    or OR11(g31, x_, g27);
    nand NAND6(g32, g31, g17);
    and AND8(g33, g32, g22);
    nor NOR4(g34, g22, z);
    and AND9(g35, g22, w, x);
    or OR12(g36, g35, g34);
    
    assign segment[0] = g30;
    assign segment[1] = g33;
    assign segment[2] = g36;
    assign segment[3] = g27;
    assign segment[4] = g8;
    assign segment[5] = g20;
    assign segment[6] = g14;
    assign segment[7] = 1;
endmodule
