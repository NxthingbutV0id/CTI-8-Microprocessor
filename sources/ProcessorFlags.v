`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2025 12:24:51 PM
// Design Name: 
// Module Name: Flags
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


module ProcessorFlags(
    input clk, clk_en,
    inout [7:0] data,
    input writeEnable, 
    input outputEnable,
    input C_IN, Z_IN, B_IN, V_IN, N_IN, H_IN,              // Added H_IN from ALU
    input UC, UZ, UN, UV, UI, UD, UH,                      // UH replaces US
    output C_OUT, Z_OUT, N_OUT, V_OUT, 
    output I_OUT, D_OUT, H_OUT, B_OUT                      // H_OUT replaces S_OUT
);
    parameter 
        C = 0, // CARRY
        Z = 1, // ZERO
        I = 2, // DISABLE INTERRUPT
        D = 3, // DIRECT PAGE BANK ENABLE
        B = 4, // BREAK
        H = 5, // HALF CARRY
        V = 6, // OVERFLOW
        N = 7; // NEGATIVE
        
    localparam true = 1'b1;
    localparam false = 1'b0;
    
    wire [7:0] dataOut;
    wire [7:0] dataIn;
    assign dataIn = (!outputEnable && writeEnable) ? data : 8'h00;
    assign data = (outputEnable && !writeEnable) ? dataOut : 8'hZZ;
    
    reg CF, ZF, IF, DF, HF, VF, NF;
    
    initial begin
        CF = false; // Carry Disabled
        ZF = false; // Zero Disabled
        IF = true;  // Interrupts Disabled
        DF = false; // Direct Page Disabled
        HF = false; // Half Carry Disabled
        VF = false; // Overflow Disabled
        NF = false; // Negative Disabled
    end
    
    always @(posedge clk) begin
        if (clk_en) begin
            if (UC) CF <= (writeEnable) ? dataIn[C] : C_IN;
            if (UZ) ZF <= (writeEnable) ? dataIn[Z] : Z_IN;
            if (UI) IF <= dataIn[I];
            if (UD) DF <= dataIn[D];
            if (UH) HF <= (writeEnable) ? dataIn[H] : H_IN;
            if (UV) VF <= (writeEnable) ? dataIn[V] : V_IN;
            if (UN) NF <= (writeEnable) ? dataIn[N] : N_IN;
        end
    end
    
    assign B_OUT = !B_IN;
    assign dataOut = {NF, VF, HF, B_OUT, DF, IF, ZF, CF};
    assign {N_OUT, V_OUT, H_OUT, D_OUT, I_OUT, Z_OUT, C_OUT} = {NF, VF, HF, DF, IF, ZF, CF};
endmodule
