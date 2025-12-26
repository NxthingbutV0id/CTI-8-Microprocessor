`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 04:49:36 PM
// Design Name: 
// Module Name: RegisterTB
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


module register_tb;
    reg clk;
    reg oe;
    reg wr;
    wire [7:0] dataBus;
    wire [7:0] regOut;
    
    reg [7:0] dataBus_drive;
    reg dataBus_oe;
    
    assign dataBus = dataBus_oe ? dataBus_drive : 8'hZZ;
    
    Register uut (
        .clk(~clk),
        .oe(oe),
        .wr(wr),
        .dataBus(dataBus),
        .regOut(regOut)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $display("========================================");
        $display("Register Testbench");
        $display("========================================");
        
        clk = 0;
        oe = 0;
        wr = 0;
        dataBus_drive = 8'h00;
        dataBus_oe = 0;
        
        repeat(2) @(posedge clk);
        
        // Test 1: Write to register
        $display("\n--- Test 1: Write $42 to register ---");
        dataBus_drive = 8'h42;
        dataBus_oe = 1;
        wr = 1;
        @(posedge clk);
        wr = 0;
        dataBus_oe = 0;
        @(posedge clk);
        $display("regOut = %02h (expected 42)", regOut);
        
        // Test 2: Write another value
        $display("\n--- Test 2: Write $AA to register ---");
        dataBus_drive = 8'hAA;
        dataBus_oe = 1;
        wr = 1;
        @(posedge clk);
        wr = 0;
        dataBus_oe = 0;
        @(posedge clk);
        if (regOut != 8'hAA) $display("regOut = %02h (expected AA)", regOut);
        else $display("Test 2: PASS");
        
        // Test 3: Output enable
        $display("\n--- Test 3: Output enable ---");
        oe = 1;
        @(posedge clk);
        $display("dataBus = %02h (expected AA)", dataBus);
        $display("regOut = %02h (expected AA)", regOut);
        oe = 0;
        @(posedge clk);
        $display("dataBus = %02h (expected ZZ)", dataBus);
        
        // Test 4: Hold value without write
        $display("\n--- Test 4: Hold value ---");
        repeat(5) @(posedge clk);
        $display("regOut = %02h (expected AA - should hold)", regOut);
        
        $display("\n========================================");
        $display("Register Test Complete");
        $display("========================================");
        $finish;
    end
    
    initial begin
        $dumpfile("register_tb.vcd");
        $dumpvars(0, register_tb);
    end
endmodule
