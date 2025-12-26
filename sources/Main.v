`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2025 10:26:11 AM
// Design Name: 
// Module Name: Main
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

// Start of project: 11/03/2025
// End of project: 
module Main(
    input CLK, // 100 MHz Clock
    input [3:0] SW, // Processor clock control
    input CPU_RESETN, // Active Low Reset
    input BTNC, // Next clock (Single Step Mode only)
    input UART_TXD_IN,
    output UART_RXD_OUT,
    output [15:0] LED, // Address Bus
    output LED_R, LED_G, LED_B, // Status lights
    output [7:0] SEG, // Digit segments (active low)
    output [7:0] AN // Digit Anodes (active low)
);
    wire enable;
    wire reset = !CPU_RESETN;
    wire irq;
    wire nmi = 1'b0;
    wire [7:0] dataBus;
    wire [15:0] addressBus;
    wire writeEnable;
    wire IO_SEL, ROM_SEL, RAM_SEL;
    
    // 10 MHz Main Clock
    wire MCLK;
    MAIN_CLK mclk(
        .clk_in1(CLK),
        .clk_out1(MCLK)
    );
    
    assign LED = addressBus;
    
    // Colored LED codes:
    // BLUE = MEM WRITE
    // RED  = MEM READ
    // CYAN = INTERRUPT
    // YELLOW = RESET
    RGBLights rgb(.reset(reset), .INT(irq), .wr(writeEnable), .lights({LED_R, LED_G, LED_B}));
    
    // if SW[3] is off, then BTNC single steps the clock
    // if SW[3] is on, then the lower three switches control the speed (1-7)
    // Warning: the processor may lock up at high speeds
    ClockController cc(.clk(MCLK), .rst(1'b0), .mode(SW), .step(BTNC), .enable(enable));
    
    Processor CTI8(
        .clk(MCLK),
        .clk_en(enable),
        .rst(reset),
        .irq(irq),
        .nmi(nmi),
        .data(dataBus),
        .addr(addressBus),
        .wr(writeEnable)
    );
    
    // Terminal and Keyboard IO
    TerminalUART uart(
        .clk(MCLK),
        .rst(reset),
        .chipSelect(IO_SEL),
        .writeEnable(writeEnable),
        .data(dataBus),
        .address(addressBus[1:0]),
        .rx(UART_TXD_IN),
        .tx(UART_RXD_OUT),
        .irq(irq)
    );
    
    AddressDecoder ad(
        .address(addressBus),
        .chipSelect({IO_SEL, ROM_SEL, RAM_SEL})
    );
    
    // BLOCK MEMORY GENERATOR SPECS:
    // Single Port ROM
    // Width = 8 bit data
    // Depth = 15 bit address (32768)
    // Always Enabled
    // NO OUTPUT REGISTER (Total Port A Read Latency: 1 Clock Cycle)
    // Load Init File: TestProgram.coe
    // Fill Remaining Memory locations with $00
    ProgramROM ROM32K (
        .clk(MCLK),
        .chipSelect(ROM_SEL),
        .address(addressBus[14:0]),
        .data(dataBus)
    );
    
    // BLOCK MEMORY GENERATOR SPECS:
    // Single port RAM
    // Width = 8 bit data
    // Depth = 14 bit address (16384)
    // NO OUTPUT REGISTER (Total Port A Read Latency: 1 Clock Cycle)
    SystemMemory RAM16K (
        .clk(MCLK),
        .chipSelect(RAM_SEL),
        .writeEnable(writeEnable),
        .data(dataBus),
        .address(addressBus[13:0])
    );
    
    // Right four digits are the address bus in hex
    // Left two digits are the data bus in hex
    BusDisplay BD(
        .clk(MCLK),
        .address(addressBus),
        .data(dataBus),
        .seg(SEG),
        .an(AN)
    );
    
endmodule
