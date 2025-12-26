`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2025 01:32:50 PM
// Design Name: 
// Module Name: ControlUnitTB
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


module ControlUnitTB;
    // Inputs
    reg clk;
    reg [19:0] data;
    wire [7:0] instruction = data[11:4];
    wire [3:0] state = data[3:0];
    wire [7:0] flags = data[19:12];
    
    // Output
    wire [31:0] controlWord;
    
    integer file;
    
    // Instantiate the Unit Under Test (UUT)
    ControlUnit uut (
        .clk(clk),
        .clk_en(1'b0),
        .instruction(instruction),
        .state(state),
        .flags(flags),
        .controlWord(controlWord)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100ns period
    end
    
    // Test all combinations
    initial begin
        // Open file for writing
        file = $fopen("control_rom.hex", "w");
        
        // Iterate through all combinations
        for (data = 0; data < 1048576; data = data + 1) begin
            #10; // Wait for one clock cycle
            $fwrite(file, "%08h\n", controlWord);  // Write 32-bit hex value
        end
        
        $fclose(file);
        $display("\nTest completed! ROM data written to control_rom.hex");
        $finish;
    end
endmodule
