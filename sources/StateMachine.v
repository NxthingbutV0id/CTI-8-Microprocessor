`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2025 05:37:44 PM
// Design Name: 
// Module Name: StateMachine
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

module StateMachine(
    input clk, clk_en,
    input [1:0] nextState,
    output reg [3:0] state
);
    
localparam // State Control
    ENDS = 2'b00, // Execution Finished, Goto Fetch
    NEXT = 2'b01; // Goto the next State
    //HOLD = 2'b11; // Hold current state
    
    initial begin
        state = 4'h0;
    end
    // Note: States can go up to 15, but are only defined up to 10, the rest are considered NOP's and will eventually hit 0 for the next instruction
    always @(posedge clk) begin
        if (clk_en) begin
            case (nextState)
                ENDS: state <= 0; 
                NEXT: state <= state + 1;
                //HOLD: state <= state;
                default: state <= 0;
            endcase
            
            if (state == 4'hF) $display("ERROR: STATE MACHINE BROKE");
        end
    end
endmodule
