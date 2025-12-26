`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:57:21 AM
// Design Name: 
// Module Name: ProcessorTB
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

// The official Test Bench for the processor

module ProcessorTB;
    localparam
        // Control Flow
        NOP       = 8'h00, // No Operations
        WAI       = 8'hFE, // Wait for Interrupt
        HLT       = 8'hFF, // Halt (Requires reset)
        // Add to Accumulator
        ADD_DP    = 8'h01,
        ADD_ABS   = 8'h05,
        ADD_ABSX  = 8'h09,
        ADD_ABSY  = 8'h0D,
        ADD_DPXI  = 8'h11,
        ADD_DPIY  = 8'h15,
        ADD_DPX   = 8'h19,
        ADD_IMM   = 8'h1D,
        // Add to Accumulator with carry
        ADC_DP    = 8'h21,
        ADC_ABS   = 8'h25,
        ADC_ABSX  = 8'h29,
        ADC_ABSY  = 8'h2D,
        ADC_DPXI  = 8'h31,
        ADC_DPIY  = 8'h35,
        ADC_DPX   = 8'h39,
        ADC_IMM   = 8'h3D,
        // Subtract from Accumulator
        SUB_DP    = 8'h41,
        SUB_ABS   = 8'h45,
        SUB_ABSX  = 8'h49,
        SUB_ABSY  = 8'h4D,
        SUB_DPXI  = 8'h51,
        SUB_DPIY  = 8'h55,
        SUB_DPX   = 8'h59,
        SUB_IMM   = 8'h5D,
        // Subtract from Accumulator with borrow
        SBB_DP    = 8'h61,
        SBB_ABS   = 8'h65,
        SBB_ABSX  = 8'h69,
        SBB_ABSY  = 8'h6D,
        SBB_DPXI  = 8'h71,
        SBB_DPIY  = 8'h75,
        SBB_DPX   = 8'h79,
        SBB_IMM   = 8'h7D,
        // Bitwise AND with Accumulator
        AND_DP    = 8'h81,
        AND_ABS   = 8'h85,
        AND_ABSX  = 8'h89,
        AND_ABSY  = 8'h8D,
        AND_DPXI  = 8'h91,
        AND_DPIY  = 8'h95,
        AND_DPX   = 8'h99,
        AND_IMM   = 8'h9D,
        // Bitwise OR with Accumulator
        ORA_DP    = 8'hA1,
        ORA_ABS   = 8'hA5,
        ORA_ABSX  = 8'hA9,
        ORA_ABSY  = 8'hAD,
        ORA_DPXI  = 8'hB1,
        ORA_DPIY  = 8'hB5,
        ORA_DPX   = 8'hB9,
        ORA_IMM   = 8'hBD,
        // Bitwise XOR with Accumulator
        XOR_DP    = 8'hC1,
        XOR_ABS   = 8'hC5,
        XOR_ABSX  = 8'hC9,
        XOR_ABSY  = 8'hCD,
        XOR_DPXI  = 8'hD1,
        XOR_DPIY  = 8'hD5,
        XOR_DPX   = 8'hD9,
        XOR_IMM   = 8'hDD,
        // Compare to
        CMP_DP    = 8'hE1,
        CMP_ABS   = 8'hE5,
        CMP_ABSX  = 8'hE9,
        CMP_ABSY  = 8'hED,
        CMP_DPXI  = 8'hF1,
        CMP_DPIY  = 8'hF5,
        CMP_DPX   = 8'hF9,
        CMP_IMM   = 8'hFD,
        CPX_DP    = 8'hC6,
        CPX_ABS   = 8'hD6,
        CPX_IMM   = 8'hDE,
        CPY_DP    = 8'hE6,
        CPY_ABS   = 8'hF6,
        CPY_IMM   = 8'hFE,
        // Store to memory
        STA_DP    = 8'h03,
        STA_ABS   = 8'h07,
        STA_ABSX  = 8'h0B,
        STA_ABSY  = 8'h0F,
        STA_DPXI  = 8'h13,
        STA_DPIY  = 8'h17,
        STA_DPX   = 8'h1B,
        STA_DPI   = 8'h1F,
        STX_DP    = 8'h43,
        STX_ABS   = 8'h47,
        STX_DPY   = 8'h5B,
        STY_DP    = 8'h83,
        STY_ABS   = 8'h87,
        STY_DPX   = 8'h9B,
        STZ_DP    = 8'hC3,
        STZ_ABS   = 8'hC7,
        STZ_ABSX  = 8'hCB,
        STZ_DPX   = 8'hDB,
        // Load from memory
        LDA_DP    = 8'h23,
        LDA_ABS   = 8'h27,
        LDA_ABSX  = 8'h2B,
        LDA_ABSY  = 8'h2F,
        LDA_DPXI  = 8'h33,
        LDA_DPIY  = 8'h37,
        LDA_DPX   = 8'h3B,
        LDA_IMM   = 8'h3F,
        LDX_DP    = 8'h63,
        LDX_ABS   = 8'h67,
        LDX_ABSY  = 8'h6F,
        LDX_DPY   = 8'h7B,
        LDX_IMM   = 8'h7F,
        LDY_DP    = 8'hA3,
        LDY_ABS   = 8'hA7,
        LDY_ABSX  = 8'hAF,
        LDY_DPX   = 8'hBB,
        LDY_IMM   = 8'hBF,
        // Arithmetic Shift Left
        ASL_DP    = 8'h06,
        ASL_DPX   = 8'h0E,
        ASL_ABS   = 8'h16,
        ASL_A     = 8'h1E,
        // Rotate Left
        ROL_DP    = 8'h26,
        ROL_DPX   = 8'h2E,
        ROL_ABS   = 8'h36,
        ROL_A     = 8'h3E,
        // Logical Shift Right
        LSR_DP    = 8'h46,
        LSR_DPX   = 8'h4E,
        LSR_ABS   = 8'h56,
        LSR_A     = 8'h5E,
        // Rotate Right
        ROR_DP    = 8'h66,
        ROR_DPX   = 8'h6E,
        ROR_ABS   = 8'h76,
        ROR_A     = 8'h7E,
        // Decrement
        DEC_DP    = 8'h86,
        DEC_DPX   = 8'h8E,
        DEC_ABS   = 8'h96,
        DEC_A     = 8'h9E,
        DEX       = 8'h1C,
        DEY       = 8'h3C,
        // Increment
        INC_DP    = 8'hA6,
        INC_DPX   = 8'hAE,
        INC_ABS   = 8'hB6,
        INC_A     = 8'hBE,
        INX       = 8'h5C,
        INY       = 8'h7C,
        // Stack
        PHA       = 8'h08,
        PLA       = 8'h28,
        PHX       = 8'h48,
        PLX       = 8'h68,
        PHY       = 8'h88,
        PLY       = 8'hA8,
        PHF       = 8'hC8,
        PLF       = 8'hE8,
        // Transfer
        TAX       = 8'h0C,
        TXA       = 8'h2C,
        TAY       = 8'h4C,
        TYA       = 8'h6C,
        TSX       = 8'h8C,
        TXS       = 8'hAC,
        TDY       = 8'hCC,
        TYD       = 8'hEC,
        // Branch
        BPL_REL   = 8'h10,
        BMI_REL   = 8'h30,
        BVC_REL   = 8'h50,
        BVS_REL   = 8'h70,
        BCC_REL   = 8'h90,
        BCS_REL   = 8'hB0,
        BNE_REL   = 8'hD0,
        BEQ_REL   = 8'hF0,
        BRA_REL   = 8'h20,
        // Jump
        JMP_ABS   = 8'h40,
        JMP_ABSI  = 8'h80,
        JMP_ABSXI = 8'hC0,
        BRK       = 8'hFC,
        JSR_ABS   = 8'hDC,
        RTI       = 8'hBC,
        RTS       = 8'h9C,
        // Clear/Set Flags
        CLC       = 8'h18,
        SEC       = 8'h38,
        CLI       = 8'h58,
        SEI       = 8'h78,
        CLV       = 8'h98,
        CLD       = 8'hD8,
        SED       = 8'hF8;

  // Clock and Reset
  reg clk;
  reg rst;
  reg irq;
  reg nmi;
  
  // Bus signals
  wire [15:0] addr;
  wire [7:0] data;
  reg [7:0] data_drive;
  reg data_oe;
  wire wr;
  
  // Memory array (64KB)
  reg [7:0] memory [0:65535];
  
  // Test variables
  integer i;
  integer test_num;
  integer cycle_count;
  
  // Bidirectional data bus handling
  assign data = data_oe ? data_drive : 8'hZZ;
  
  // Instantiate the processor
  Processor uut (
    .clk(clk),
    .clk_en(1'b1),
    .rst(rst),
    .irq(irq),
    .nmi(nmi),
    .data(data),
    .addr(addr),
    .wr(wr)
  );
  
  // Clock generation (10MHz = 100ns period)
  always #50 clk = ~clk;
  
  // Memory model - provides data when processor is reading
  always @(*) begin
    if (!wr) begin
      // Processor is reading
      data_drive = memory[addr];
      data_oe = 1'b1;
    end else begin
      data_oe = 1'b0;
      data_drive = 8'h00;
    end
  end
  
  // Memory write on rising edge when wr is high
  always @(posedge clk) begin
    if (wr) begin
      memory[addr] <= data;
    end
    if (wr === 1'bX) $display("Write Enable line is null...");
  end
  
  // Initialize memory with test program
  task load_program;
    begin
      // Clear memory
      for (i = 0; i < 65536; i = i + 1)
        memory[i] = 8'h00;
      
      // Load reset vector (address of start routine)
      memory[16'hFFFC] = 8'h00;  // Low byte of reset vector
      memory[16'hFFFD] = 8'h02;  // High byte of reset vector (start at $0200)
      
      // Load IRQ vector
      memory[16'hFFFE] = 8'h00;  // Low byte of IRQ vector
      memory[16'hFFFF] = 8'h03;  // High byte of IRQ vector (start at $0300)
      
      // Load NMI vector
      memory[16'hFFFA] = 8'h00;  // Low byte of NMI vector
      memory[16'hFFFB] = 8'h04;  // High byte of NMI vector (start at $0400)
      
      // Main test program at $0200
      i = 16'h0200;
      
      // Test 1: Load and store operations
      memory[i] = LDA_IMM;  i = i + 1;  // LDA #$42
      memory[i] = 8'h42;    i = i + 1;
      memory[i] = STA_DP;   i = i + 1;  // STA $10
      memory[i] = 8'h10;    i = i + 1;
      
      // Test 2: Load X and Y registers
      memory[i] = LDX_IMM;  i = i + 1;  // LDX #$AA
      memory[i] = 8'hAA;    i = i + 1;
      memory[i] = LDY_IMM;  i = i + 1;  // LDY #$55
      memory[i] = 8'h55;    i = i + 1;
      
      // Test 3: Store X and Y
      memory[i] = STX_DP;   i = i + 1;  // STX $11
      memory[i] = 8'h11;    i = i + 1;
      memory[i] = STY_DP;   i = i + 1;  // STY $12
      memory[i] = 8'h12;    i = i + 1;
      
      // Test 4: Transfer instructions
      memory[i] = LDA_IMM;  i = i + 1;  // LDA #$33
      memory[i] = 8'h33;    i = i + 1;
      memory[i] = TAX;      i = i + 1;  // TAX
      memory[i] = TAY;      i = i + 1;  // TAY
      
      // Test 5: Arithmetic
      memory[i] = LDA_IMM;  i = i + 1;  // LDA #$10
      memory[i] = 8'h10;    i = i + 1;
      memory[i] = ADD_IMM;  i = i + 1;  // ADD #$05
      memory[i] = 8'h05;    i = i + 1;
      memory[i] = STA_DP;   i = i + 1;  // STA $13 (should be $15)
      memory[i] = 8'h13;    i = i + 1;
      
      // Test 6: Increment/Decrement
      memory[i] = INX;      i = i + 1;  // INX
      memory[i] = INY;      i = i + 1;  // INY
      memory[i] = DEX;      i = i + 1;  // DEX
      
      // Test 7: Stack operations
      memory[i] = PHA;      i = i + 1;  // PHA
      memory[i] = LDA_IMM;  i = i + 1;  // LDA #$FF
      memory[i] = 8'hFF;    i = i + 1;
      memory[i] = PLA;      i = i + 1;  // PLA (should restore previous A)
      
      memory[i] = CLI;      i = i + 1; // Enable interrupts
      
      // Test 8: Infinite loop
      memory[i] = JMP_ABS;  i = i + 1;  // JMP $0200+offset (to here)
      memory[i] = (i-1) & 8'hFF;    i = i + 1;  // Low byte
      memory[i] = ((i-2) >> 8) & 8'hFF; i = i + 1;  // High byte
      
      // IRQ handler at $0300
      i = 16'h0300;
      memory[i] = LDA_IMM;  i = i + 1;  // LDA #$FF
      memory[i] = 8'hFF;    i = i + 1;
      memory[i] = STA_DP;   i = i + 1;  // STA $20 (mark IRQ occurred)
      memory[i] = 8'h20;    i = i + 1;
      memory[i] = RTI;      i = i + 1;  // RTI
      
      // NMI handler at $0400
      i = 16'h0400;
      memory[i] = LDA_IMM;  i = i + 1;  // LDA #$EE
      memory[i] = 8'hEE;    i = i + 1;
      memory[i] = STA_DP;   i = i + 1;  // STA $30 (mark NMI occurred)
      memory[i] = 8'h30;    i = i + 1;
      memory[i] = RTI;      i = i + 1;  // RTI
      
      $display("Test program loaded into memory");
      $display("  Reset vector: $%04h", {memory[16'hFFFD], memory[16'hFFFC]});
      $display("  IRQ vector:   $%04h", {memory[16'hFFFF], memory[16'hFFFE]});
      $display("  NMI vector:   $%04h", {memory[16'hFFFB], memory[16'hFFFA]});
    end
  endtask
  
  // Reset task (active high)
  task reset_processor;
    begin
      $display(" === Asserting Reset ===");
      rst = 1;
      irq = 0;
      nmi = 0;
      repeat(10) @(posedge clk);
      printStatus();
      rst = 0;
      $display("=== Reset Released ===");
      repeat(5) @(posedge clk);
    end
  endtask
  
  // Task to trigger IRQ (active high)
  task trigger_irq;
    begin
      $display("=== Triggering IRQ ===");
      irq = 1;
      repeat(5) @(posedge clk);
      irq = 0;
      $display("=== IRQ Released ===");
    end
  endtask
  
  // Task to trigger NMI (active high)
  task trigger_nmi;
    begin
      $display("=== Triggering NMI ===");
      nmi = 1;
      repeat(3) @(posedge clk);
      nmi = 0;
      $display("=== NMI Released ===");
    end
  endtask
  
  task printStatus();
    begin
        $display("[C:%03d] $%04H (%s) | %s | data=$%02H internal=$%02H | IR=$%02H (safe IR: $%02H) | const=$%h oeSel=$%h wrSel=$%h | SP=$%02H | STATE=T%H F=%08b (INT: %b, RST: %b, NMI: %b) |", 
            cycle_count, 
            addr, 
            (uut.addrSel[1] ? (uut.addrSel[0] ? "SP" : "DP") : (uut.addrSel[0] ? "EA" : "PC")), 
            ((wr) ? "W" : "r"),
            data, 
            uut.dataBus,
            uut.IR, 
            uut.safe_instruction,
            uut.const,
            uut.oeSel,
            uut.wrSel,
            uut.STACK_POINTER.CNT, 
            uut.state,
            uut.F, 
            uut.cu.INT, 
            uut.cu.RST, 
            uut.cu.NMI
        );
    end
  endtask
  
  // Monitor processor state
  always @(posedge clk) begin
      cycle_count <= cycle_count + 1;
      printStatus();
  end
  
  // Main test sequence
  initial begin
    // Initialize
    clk = 0;
    rst = 0;
    irq = 0;
    nmi = 0;
    data_oe = 0;
    data_drive = 8'h00;
    test_num = 0;
    cycle_count = 0;
    
    $display("========================================");
    $display("8-bit Custom Processor Testbench");
    $display("Clock: 10MHz (100ns period)");
    $display("========================================");
    
    // Load test program
    load_program();
    
    // Test 1: Basic Reset and Execution
    test_num = 1;
    $display("\n=== Test %0d: Reset and Basic Execution ===", test_num);
    reset_processor();
    
    // Run for some cycles to let program execute
    repeat(200) @(posedge clk);
    
    // Check results
    $display("\n--- After Basic Execution ---");
    $display("  PC    = $%04H", uut.PROGRAM_COUNTER.PC);
    $display("  A     = $%02H", uut.ACCUMULATOR.data);
    $display("  X     = $%02H (expected $33)", uut.INDEX_X.data);
    $display("  Y     = $%02H (expected $34)", uut.INDEX_Y.data);
    $display("  SP    = $%02H", uut.STACK_POINTER.CNT);
    $display("  State = $%H", uut.state);
    $display("  Flags = %08b", uut.F);
    $display("  Mem[$10] = $%02H (expected $42)", memory[16'h0010]);
    $display("  Mem[$11] = $%02H (expected $AA)", memory[16'h0011]);
    $display("  Mem[$12] = $%02H (expected $55)", memory[16'h0012]);
    $display("  Mem[$13] = $%02H (expected $15)", memory[16'h0013]);
    
    // Test 2: IRQ Test
    test_num = 2;
    $display("\n=== Test %0d: IRQ Interrupt ===", test_num);
    trigger_irq();
    repeat(100) @(posedge clk);
    $display("  Mem[$20] = $%02H (should be $FF if IRQ handler ran)", memory[16'h0020]);
    
    // Test 3: NMI Test
    test_num = 3;
    $display("\n=== Test %0d: NMI Interrupt ===", test_num);
    trigger_nmi();
    repeat(100) @(posedge clk);
    $display("  Mem[$30] = $%02H (should be $EE if NMI handler ran)", memory[16'h0030]);
    
    // Test 4: Continue execution
    test_num = 4;
    $display("\n=== Test %0d: Continue Execution ===", test_num);
    repeat(100) @(posedge clk);
    
    $display("\n========================================");
    $display("Testbench Complete - %0d cycles executed", cycle_count);
    $display("========================================");
    
    // Summary
    $display("\n=== Test Summary ===");
    $display("Load/Store Test:   %s", (memory[16'h0010] == 8'h42) ? "PASS" : "FAIL");
    $display("Index Reg Test:    %s", (memory[16'h0011] == 8'hAA && memory[16'h0012] == 8'h55) ? "PASS" : "FAIL");
    $display("Arithmetic Test:   %s", (memory[16'h0013] == 8'h15) ? "PASS" : "FAIL");
    $display("IRQ Handler Test:  %s", (memory[16'h0020] == 8'hFF) ? "PASS" : "FAIL");
    $display("NMI Handler Test:  %s", (memory[16'h0030] == 8'hEE) ? "PASS" : "FAIL");
    
    $finish;
  end
  
  // Timeout watchdog
  initial begin
    #100000;  // 100us timeout
    $display("\n!!! ERROR: Testbench timeout after 100us !!!");
    $display("Cycle count: %0d", cycle_count);
    $finish;
  end
  
  // Generate VCD file for waveform viewing
  initial begin
    $dumpfile("ProcessorTB.vcd");
    $dumpvars(0, ProcessorTB);
    // Monitor specific memory locations
    for (i = 16'h0010; i <= 16'h0013; i = i + 1)
      $dumpvars(0, memory[i]);
    $dumpvars(0, memory[16'h0020]);
    $dumpvars(0, memory[16'h0030]);
  end

endmodule
