`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2025 10:45:01 AM
// Design Name: 
// Module Name: Processor
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


module Processor(   
    input clk,              // 100 MHz Clock
    input clk_en,           // Clock Enable
    input rst,              // Reset
    input irq,              // Interrupt request
    input nmi,              // Non-maskable Interrupt
    inout [7:0] data,       // Data IO
    output reg [15:0] addr, // Address Out
    output wr               // Write Enable
);
    localparam // Address Select
        PCAS = 2'b00, // {PCH, PCL}
        EAAS = 2'b01, // {EAH, EAL}
        DPAS = 2'b10, // {DP, EAL}
        STAS = 2'b11; // {8'h01, SP}
    
    // MUX SIGNALS
    localparam // 0 = NONE
        PCL     = 4'h1, // Program Counter Low (R/W)
        PCH     = 4'h2, // Program Counter High (R/W)
        EAL     = 4'h3, // Effective Address Low (R/W)
        EAH     = 4'h4, // Effective Address High (R/W)
        RAM     = 4'h5, // Memory Data Register (R/W)
        ACC_RW  = 4'h6, // Accumulator (R/W)
        X_RW    = 4'h7, // Index Register X (R/W)
        Y_RW    = 4'h8, // Index Register Y (R/W)
        SP_RW   = 4'h9, // Stack Pointer (R/W)
        A_ALU   = 4'hA, // ALU input A (R/W)
        B_ALU   = 4'hB, // ALU input B (R/W)
        F_RW    = 4'hC, // Flags Register (R/W)
        D_RW    = 4'hD, // Direct Page Register (R/W)
        IR_W    = 4'hE, // Instruction Register (WO)
        ALU_R   = 4'hE, // ALU Output (RO)
        CONST_R = 4'hF; // Constant Output (RO)
    
    // Internal Bus
    wire [7:0] dataBus;
    wire [7:0] F; // {n, v, h, b, d, i, z, c}
    wire flag;
    wire Cout;
    wire Zout = dataBus == 0;
    wire Vout;
    wire Hout;
    
    wire [3:0] oeSel;
    wire [3:0] wrSel;
    wire [3:0] const;
    wire [3:0] flagSel;
    wire [1:0] addrSel;
    wire [1:0] nextState;
    wire [3:0] state; 
    wire [7:0] updateF;
    wire Cin, incPC, incEA, offsetPC, indexEA, enSP, dirSP, intHold;
    wire [15:0] writeEnable, outputEnable;
    wire incPCH, intr;
    wire [7:0] SP, D, aluA, aluB, IR, ACC, X, Y;
    wire [15:0] PC, EA;
    wire c, z, i, d, b, h, v, n;
    
    // Registers and Counters
    ProgramCounter PROGRAM_COUNTER(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[PCL] | outputEnable[PCH]),
        .wr(writeEnable[PCL] | writeEnable[PCH]),
        .LHB(outputEnable[PCH] | writeEnable[PCH]),
        .incEnable(incPC),
        .offsetEnable(offsetPC),
        .data(dataBus),
        .addressOut(PC)
    );
    
    EffectiveAddressRegister EAR(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[EAL] | outputEnable[EAH]),
        .wr(writeEnable[EAL] | writeEnable[EAH]),
        .LHB(outputEnable[EAH] | writeEnable[EAH]),
        .incEnable(incEA),
        .addIndex(indexEA),
        .data(dataBus),
        .addressOut(EA)
    );
    
    RAMBuffer rb(
        .oe(outputEnable[RAM]),
        .wr(writeEnable[RAM]),
        .internalDataBus(dataBus),
        .externalDataBus(data)
    );
    
    Register ACCUMULATOR(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[ACC_RW]),
        .wr(writeEnable[ACC_RW]),
        .dataBus(dataBus),
        .regOut(ACC)
    );
    
    Register INDEX_X(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[X_RW]),
        .wr(writeEnable[X_RW]),
        .dataBus(dataBus),
        .regOut(X)
    );
    
    Register INDEX_Y(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[Y_RW]),
        .wr(writeEnable[Y_RW]),
        .dataBus(dataBus),
        .regOut(Y)
    );
    
    Counter STACK_POINTER(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[SP_RW]),
        .wr(writeEnable[SP_RW]),
        .dir(dirSP),
        .en(enSP),
        .dataBus(dataBus),
        .addrOut(SP)
    );
    
    Register ALU_INPUT_A(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[A_ALU]),
        .wr(writeEnable[A_ALU]),
        .dataBus(dataBus),
        .regOut(aluA)
    );
    
    Register ALU_INPUT_B(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[B_ALU]),
        .wr(writeEnable[B_ALU]),
        .dataBus(dataBus),
        .regOut(aluB)
    );
    
    ProcessorFlags pf(
        .clk(clk),
        .clk_en(clk_en),
        .data(dataBus),
        .writeEnable(writeEnable[F_RW]),
        .outputEnable(outputEnable[F_RW]),
        .C_IN(Cout),
        .Z_IN(Zout),
        .B_IN(intr),
        .N_IN(dataBus[7]),
        .V_IN(Vout),
        .H_IN(Hout),
        .UC(updateF[0]),
        .UZ(updateF[1]),
        .UI(updateF[2]),
        .UD(updateF[3]),
        .UH(updateF[5]),
        .UV(updateF[6]),
        .UN(updateF[7]),
        .C_OUT(c),
        .Z_OUT(z),
        .N_OUT(n),
        .V_OUT(v),
        .I_OUT(i),
        .D_OUT(d),
        .H_OUT(h),
        .B_OUT(b)
    );
    
    assign F = {n, v, h, b, d, i, z, c};
    
    Register DIRECT_PAGE(
        .clk(clk),
        .clk_en(clk_en),
        .oe(outputEnable[D_RW]),
        .wr(writeEnable[D_RW]),
        .dataBus(dataBus),
        .regOut(D)
    );
    
    InstructionRegister INSTRUCTION_REGISTER(
        .clk(clk),
        .clk_en(clk_en),
        .wr(writeEnable[IR_W]),
        .dataIn(dataBus),
        .regOut(IR)
    );
    
    ALU ARITHMETIC_LOGIC_UNIT(
        .A($signed(aluA)),
        .B($signed(aluB)),
        .carryIn(Cin),
        .halfCarry(h),
        .opcode(const),
        .outputEnable(outputEnable[ALU_R]),
        .result(dataBus),
        .C(Cout),
        .V(Vout),
        .H(Hout)
    );
    
    Constant CONST(
        .const(const),
        .oe(outputEnable[CONST_R]),
        .dataBus(dataBus)
    );
    
    WriteMux wm(.wrSelect(wrSel), .wr(writeEnable));
    
    ReadMux rm(.oeSelect(oeSel), .oe(outputEnable));
    
    StateMachine sm(
        .clk(clk),
        .clk_en(clk_en),
        .nextState(nextState),
        .state(state)
    );
    
    // Due to dumb circular logic constraints, we have to do this.
    wire [7:0] safe_instruction = (state == 4'h0) ? 8'h00 : IR;
    
    ControlUnit cu(
        .clk(clk),
        .clk_en(clk_en),
        .state(state),
        .instruction(safe_instruction),
        .flags({rst, nmi, irq, n, v, i, z, c}),
        .controlWord({intr, dirSP, enSP, indexEA, incEA, offsetPC, incPC, Cin, updateF, addrSel, nextState, const, wrSel, oeSel})
    );
    
    assign wr = writeEnable[RAM];
    
    always @(*) begin
        case (addrSel)
            PCAS: addr = PC;
            EAAS: addr = EA;
            STAS: addr = {8'h01, SP};
            DPAS: addr = { (d ? D : 8'h00), EA[7:0] };
        endcase
    end
endmodule
