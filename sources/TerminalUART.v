`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 01:47:16 PM
// Design Name: 
// Module Name: TerminalUART
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


module TerminalUART(
    input clk,
    input rst,
    input chipSelect,
    input writeEnable,
    inout [7:0] data,
    input [1:0] address,
    input rx,
    output tx,
    output irq
);

    // -------------------------------------------------------------------------
    // 1. Parameter Calculations
    // -------------------------------------------------------------------------
    localparam CLKS_PER_BIT = 87;

    // -------------------------------------------------------------------------
    // 2. Internal Signals & Registers
    // -------------------------------------------------------------------------
    
    // Bus Interface Signals
    reg [7:0] data_out_buffer = 0;
    reg interrupt_enable = 0;

    // TX Signals
    reg [7:0] tx_byte_latch = 0;
    reg       tx_start = 0;
    wire      tx_busy;
    wire      tx_serial_out;

    // RX Signals
    wire [7:0] rx_byte_out;
    wire       rx_done_tick;
    reg [7:0]  rx_buffer = 0;
    reg        rx_data_valid = 0;

    // -------------------------------------------------------------------------
    // 3. Memory Map Logic (Your original logic)
    // -------------------------------------------------------------------------
    wire addr_is_data    = (address == 2'b00);
    wire addr_is_status  = (address == 2'b01);
    wire addr_is_control = (address == 2'b10);

    // TRI-STATE BUFFER CONTROL
    assign data = (chipSelect && !writeEnable) ? data_out_buffer : 8'bz;

    // Add a new register to track if we've handled the current write pulse
    reg write_handled = 0;

    // WRITE LOGIC (Processor -> UART)
    always @(posedge clk) begin
        if (rst) begin
            tx_start <= 1'b0;
            tx_byte_latch <= 8'b0;
            interrupt_enable <= 1'b0;
            write_handled <= 1'b0; // Reset the handler
        end else begin
            // Auto-clear the start pulse
            tx_start <= 1'b0;

            if (chipSelect && writeEnable) begin
                // Only act if we haven't handled this specific write pulse yet
                if (!write_handled) begin
                    
                    // Write to DATA (TX)
                    if (addr_is_data && !tx_busy) begin
                        tx_byte_latch <= data;
                        tx_start <= 1'b1; 
                        write_handled <= 1'b1; // MARK AS HANDLED!
                    end
                    
                    // Write to CONTROL
                    if (addr_is_control) begin
                        interrupt_enable <= data[0];
                        write_handled <= 1'b1; // Mark as handled
                    end
                end
            end else begin
                // The Processor has finally dropped the write signal.
                // We can now reset our handler and wait for the NEXT write.
                write_handled <= 1'b0;
            end
        end
    end

    // READ LOGIC (UART -> Processor)
    always @(*) begin
        data_out_buffer = 8'b0;
        if (chipSelect && !writeEnable) begin
            if (addr_is_data) begin
                data_out_buffer = rx_buffer;
            end else if (addr_is_status) begin
                // Status: [0: RX_Ready, 1: TX_Busy, 7-2: Reserved]
                data_out_buffer = {6'b0, tx_busy, rx_data_valid};
            end
        end
    end

    // RX BUFFER MANAGEMENT
    always @(posedge clk) begin
        if (rst) begin
            rx_buffer <= 8'b0;
            rx_data_valid <= 1'b0;
        end else begin
            // 1. New Byte Received from UART Line
            if (rx_done_tick) begin
                rx_buffer <= rx_byte_out;
                rx_data_valid <= 1'b1;
            end

            // 2. Processor Reads the Data Register
            if (chipSelect && !writeEnable && addr_is_data) begin
                rx_data_valid <= 1'b0;
            end
        end
    end

    // INTERRUPT GENERATION
    assign irq = rx_data_valid & interrupt_enable;
    assign tx = tx_serial_out;

    // I DID NOT CREATE THE MODULES BELOW
    // I was having issues with my own UART implementation so I just gave up and found one online.
    // Link to the original code is in the modules.
    TXuart tx_inst (
        .i_Clock(clk),
        .i_Tx_DV(tx_start),        // Mapped 'tx_start' to 'Data Valid'
        .i_Tx_Byte(tx_byte_latch), // Mapped byte latch
        .o_Tx_Active(tx_busy),     // Mapped 'Active' to 'Busy'
        .o_Tx_Serial(tx_serial_out),
        .o_Tx_Done()               // Unused in your logic
    );

    RXuart rx_inst (
        .i_Clock(clk),
        .i_Rx_Serial(rx),
        .o_Rx_DV(rx_done_tick),    // Mapped 'Data Valid' to 'Done Tick'
        .o_Rx_Byte(rx_byte_out)
    );

endmodule
