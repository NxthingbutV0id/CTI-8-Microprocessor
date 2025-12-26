`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 10:10:56 AM
// Design Name: 
// Module Name: InterruptLogic
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

// RESET: 
// Stops executing the current instruction 
// Set the PC to the value located at $FFFC (low byte) and $FFFD (high byte)

// INTERRUPT REQUEST: 
// Finish the current instruction 
// Push the PC and Flags to the stack
// Load PC with the value located at $FFFE (low byte) and $FFFF (high byte)
// disable interrupts from firing until either a CLI instruction or RTI
// If the IRQ is still high after an RTI, an interrupt will fire immediatly

// NON-MASKABLE INTERRUPT
// Finish the current instruction
// Push the PC and flags to the stack
// Load PC with the value located at $FFFA (low byte) and $FFFB (high byte)
// disable interrupts from firing until either a CLI instruction or RTI
// the interrupt will only fire once on the rising edge of NMI
module InterruptLogic(
    input clk, clk_en, intHold, iFlag, rst, irq, nmi,
    input [3:0] state,
    output reg NMI,
    output INT, WAK, RST
);
    reg irq_latched = 0;
    reg nmi_prev = 0;
    reg intHold_prev = 0;
    initial NMI = 0;
    
    // 1. Immediate Reset (Fixes Cycle 0 crash)
    // This causes the button to be a little finichy to use
    // Set the clock to single step mode
    // Hold reset
    // Press BTNC until you see $FFFC/$FFFD on the address bus
    // If you see $FFFE/$FFFF, that is the inturrupt vector and you didn't hold the button long enough, try again
    assign RST = rst;

    always @(posedge clk) begin
        if (clk_en) begin
            intHold_prev <= intHold;
            nmi_prev <= nmi;

            // 2. Fix NMI Double-Triggering
            // Detect NMI edge (Set Flag)
            if (nmi && !nmi_prev) begin
                NMI <= 1'b1;
            end
            
            // Clear Flag on ENTRY to Interrupt (Rising Edge of intHold)
            if (intHold && !intHold_prev) begin
                 NMI <= 1'b0;
                 irq_latched <= 1'b0;
            end

            // Latch IRQ (Level Sensitive)
            if (!intHold && irq && ~iFlag) begin
                 irq_latched <= 1'b1;
            end
        end
    end
    
    assign INT = RST | NMI | irq_latched;
    assign WAK = INT | (irq & ~iFlag);
endmodule
