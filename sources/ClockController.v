`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 08:23:57 PM
// Design Name: 
// Module Name: ClockController
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


module ClockController(
    input clk,          // 10 MHz System Clock
    input rst,
    input [3:0] mode,   // Speed selection
    input step,         // Single step button
    output reg enable   // 1-cycle pulse
);
    // Speed Selection Modes
    localparam MODE_STEP   = 3'b000;
    localparam MODE_10HZ   = 3'b001;
    localparam MODE_100HZ  = 3'b010;
    localparam MODE_1KHZ   = 3'b011;
    localparam MODE_10KHZ  = 3'b100;
    localparam MODE_100KHZ = 3'b101;
    localparam MODE_1MHZ   = 3'b110;
    localparam MODE_TURBO  = 3'b111; // 10MHz

    // --- Prescaler Chain ---
    // Instead of one giant counter, we use small counters that enable the next one.
    // This creates a precise "Tick" at each frequency.
    
    // 10MHz -> 1MHz (Divide by 10)
    reg [3:0] cnt_1m;
    wire tick_1m = (cnt_1m == 9);
    always @(posedge clk) if (rst || tick_1m) cnt_1m <= 0; else cnt_1m <= cnt_1m + 1;

    // 1MHz -> 100kHz
    reg [3:0] cnt_100k;
    wire tick_100k = (cnt_100k == 9) && tick_1m;
    always @(posedge clk) if (rst) cnt_100k <= 0; else if (tick_1m) cnt_100k <= (tick_100k) ? 0 : cnt_100k + 1;

    // 100kHz -> 10kHz
    reg [3:0] cnt_10k;
    wire tick_10k = (cnt_10k == 9) && tick_100k;
    always @(posedge clk) if (rst) cnt_10k <= 0; else if (tick_100k) cnt_10k <= (tick_10k) ? 0 : cnt_10k + 1;

    // 10kHz -> 1kHz
    reg [3:0] cnt_1k;
    wire tick_1k = (cnt_1k == 9) && tick_10k;
    always @(posedge clk) if (rst) cnt_1k <= 0; else if (tick_10k) cnt_1k <= (tick_1k) ? 0 : cnt_1k + 1;

    // 1kHz -> 100Hz
    reg [3:0] cnt_100;
    wire tick_100 = (cnt_100 == 9) && tick_1k;
    always @(posedge clk) if (rst) cnt_100 <= 0; else if (tick_1k) cnt_100 <= (tick_100) ? 0 : cnt_100 + 1;

    // 100Hz -> 10Hz
    reg [3:0] cnt_10;
    wire tick_10 = (cnt_10 == 9) && tick_100;
    always @(posedge clk) if (rst) cnt_10 <= 0; else if (tick_100) cnt_10 <= (tick_10) ? 0 : cnt_10 + 1;


    // --- Edge Detector for Single Step ---
    reg step_prev;
    wire step_rise = step && !step_prev;
    always @(posedge clk) step_prev <= step;

    // --- Output Mux ---
    always @(posedge clk) begin
        if (rst) enable <= 0;
        else if (mode[3]) begin
            // Automatic Modes
            case (mode[2:0])
                MODE_10HZ:   enable <= tick_10;  // Stable
                MODE_100HZ:  enable <= tick_100; // Stable
                MODE_1KHZ:   enable <= tick_1k;  // Stable
                MODE_10KHZ:  enable <= tick_10k; // Stable
                MODE_100KHZ: enable <= tick_100k;// Possibly unstable
                MODE_1MHZ:   enable <= tick_1m;  // Possibly unstable
                MODE_TURBO:  enable <= 1'b1;     // Unstable
                default:     enable <= 0;
            endcase
        end else begin
            // Manual Step Mode
            enable <= step_rise;
        end
    end
endmodule
