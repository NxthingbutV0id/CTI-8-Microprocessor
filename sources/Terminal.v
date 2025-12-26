`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 07:25:24 PM
// Design Name: 
// Module Name: Terminal
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


module Terminal(
    input clk,
    input cpuRST,
    input chipSelect,
    input writeEnable,
    inout [7:0] data,
    input [15:0] address,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);
    assign data = 8'hZZ;
    wire [7:0] dataIn = data;
    
    wire [10:0] hCount;
    wire [10:0] vCount;
    wire [11:0] pixelIn;
    wire [11:0] pixelOut;

    Monitor vga(
        .clk      (clk),
        .cpuRST   (cpuRST),
        .pixelIn  (pixelIn),
        .hCount   (hCount),
        .vCount   (vCount),
        .pixelOut (pixelOut),
        .hSync    (VGA_HS),
        .vSync    (VGA_VS)
    );

    // Map Monitor's 12-bit pixel output to the 4:4:4 physical VGA pins
    assign VGA_R = pixelOut[11:8];
    assign VGA_G = pixelOut[7:4];
    assign VGA_B = pixelOut[3:0];
    
    localparam integer CHAR_W      = 8;    // pixels per character (X)
    localparam integer CHAR_H      = 8;    // pixels per character (Y)
    localparam integer TEXT_COLS   = 1024 / CHAR_W;  // 1024 / 8
    localparam integer TEXT_ROWS   = 768 / CHAR_H;   // 768 / 16
    localparam integer TEXT_DEPTH  = TEXT_COLS * TEXT_ROWS; // 12288 characters
    localparam integer TEXT_AWIDTH = 13;   // enough for 0..8191
    
    // ASCII code for each cell
    reg [7:0] textRAM [0:TEXT_DEPTH-1];
    // Clear video RAM to spaces on configuration
    integer i;
    initial begin
        for (i = 0; i < TEXT_DEPTH; i = i + 1) begin
            textRAM[i] = 8'h20; // space character
        end
    end

    // CPU write into textRAM.
    // Address decoder must ensure that 'chipSelect' is high only when
    // the CPU accesses the terminal's region.
    wire we = chipSelect & writeEnable;
    wire [12:0] cellSel = address[12:0];  // low 13 bits select cell

    always @(posedge clk) begin
        if (!cpuRST) begin
            // optional synchronous clear; most of the work is done in 'initial'
        end else if (we) begin
            if (cellSel < TEXT_DEPTH)
                textRAM[cellSel] <= dataIn;
        end
    end

    // -------------------------------------------------------------------------
    // Character generator: convert (hCount, vCount) into a pixel color
    // -------------------------------------------------------------------------
    // Visible region that actually maps to character cells
    localparam integer H_VISIBLE = 1024;
    localparam integer V_VISIBLE = 768;

    wire displayActive = (hCount < H_VISIBLE) && (vCount < V_VISIBLE);

    // Position of the current pixel inside the character grid
    wire [6:0] charCol = hCount[9:3]; // divide by 8 (0..127)
    wire [5:0] charRow = vCount[9:4]; // divide by 16 (0..47)

    wire [12:0] textIndex = {charRow, charCol}; // row*128 + col

    // Pixel position inside the current character cell
    wire [3:0] glyphRow = vCount[3:0];                // 0..15
    wire [2:0] glyphCol = 3'd7 - hCount[2:0];         // 7..0 (MSB on the left)

    // Look up the glyph bits for this character / scanline
    wire [7:0] glyphBits;
    wire [7:0] charCode = (displayActive && (textIndex < TEXT_DEPTH)) ?
                          textRAM[textIndex] : 8'h20;

    CharacterROM font(
        .charCode (charCode),
        .row      (glyphRow),
        .glyph    (glyphBits)
    );

    wire pixelOn = displayActive && glyphBits[glyphCol];

    // Simple monochrome output: white text on black background
    assign pixelIn = pixelOn ? 12'hFFF : 12'h000;

endmodule
