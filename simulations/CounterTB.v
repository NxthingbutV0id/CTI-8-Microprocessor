`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 04:49:36 PM
// Design Name: 
// Module Name: CounterTB
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

module counter_tb;
    reg clk;
    reg oe;
    reg wr;
    reg dir;
    reg en;
    wire [7:0] dataBus;
    wire [7:0] addrOut;
    wire ov;
    
    reg [7:0] dataBus_drive;
    reg dataBus_oe;
    
    assign dataBus = dataBus_oe ? dataBus_drive : 8'hZZ;
    
    Counter uut (
        .clk(~clk),
        .oe(oe),
        .wr(wr),
        .dir(dir),
        .en(en),
        .dataBus(dataBus),
        .addrOut(addrOut),
        .ov(ov)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $display("========================================");
        $display("Counter Testbench");
        $display("========================================");
        
        clk = 0;
        oe = 0;
        wr = 0;
        dir = 0;
        en = 0;
        dataBus_drive = 8'h00;
        dataBus_oe = 0;
        
        repeat(2) @(posedge clk);
        
        // Test 1: Write initial value
        $display("\n--- Test 1: Write $10 to counter ---");
        dataBus_drive = 8'h10;
        dataBus_oe = 1;
        wr = 1;
        @(posedge clk);
        wr = 0;
        dataBus_oe = 0;
        @(posedge clk);
        if (addrOut != 8'h10) $display("Test 1: FAILED addrOut = $%02H (expected $10)", addrOut);
        else $display("Test 1: PASSED");
        
        // Test 2: Increment (dir=0)
        $display("\n--- Test 2: Increment counter ---");
        dir = 0;
        en = 1;
        repeat(5) begin
            @(posedge clk);
            $display("Cycle: addrOut = %02h, ov = %b", addrOut, ov);
        end
        en = 0;
        
        // Test 3: Write $FE and test overflow
        $display("\n--- Test 3: Test overflow at $FF ---");
        dataBus_drive = 8'hFE;
        dataBus_oe = 1;
        wr = 1;
        @(posedge clk);
        wr = 0;
        dataBus_oe = 0;
        @(posedge clk);
        if (addrOut != 8'hFE) $display("Test 3: FAILED addrOut = $%02h (expected $FE)", addrOut);

        dir = 0;
        en = 1;
        @(posedge clk);
        if (addrOut != 8'hFF && ov != 0) $display("Test 3: FAILED After inc: addrOut = $%02h, ov = %b (expected $FF, 0)", addrOut, ov);
        @(posedge clk);
        if (addrOut != 8'h00 && ov != 1) $display("Test 3: FAILED After inc: addrOut = $%02h, ov = %b (expected $00, 1)", addrOut, ov);
        @(posedge clk);
        if (addrOut != 8'h01 && ov != 0) $display("Test 3: FAILED After inc: addrOut = $%02h, ov = %b (expected $01, 0)", addrOut, ov);
        en = 0;
        
        // Test 4: Decrement (dir=1)
        $display("\n--- Test 4: Decrement counter ---");
        dataBus_drive = 8'h05;
        dataBus_oe = 1;
        wr = 1;
        @(posedge clk);
        wr = 0;
        dataBus_oe = 0;
        @(posedge clk);
        
        dir = 1;
        en = 1;
        repeat(8) begin
            @(posedge clk);
            $display("Cycle: addrOut = $%02h, ov = %b", addrOut, ov);
        end
        en = 0;
        
        // Test 5: Output enable
        $display("\n--- Test 5: Output enable ---");
        oe = 1;
        @(posedge clk);
        if (dataBus != addrOut) $display("Test 5: FAILED dataBus = $%02h (expected $%02h)", dataBus, addrOut);
        else $display("Test 5: PASSED");
        oe = 0;
        
        $display("\n========================================");
        $display("Counter Test Complete");
        $display("========================================");
        $finish;
    end
    
    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);
    end
endmodule