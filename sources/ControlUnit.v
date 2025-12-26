`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 02:33:33 PM
// Design Name: 
// Module Name: ControlUnit
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


module ControlUnit(
    input clk, clk_en,
    input [7:0] instruction,
    input [3:0] state,
    input [7:0] flags,
    output [31:0] controlWord
);
    // ADDRESSING MODES:
    //  DP      = Direct Page 
    //  DPX     = Direct Page indexed with X
    //  DPY     = Direct Page indexed with Y
    //  ABS     = Absolute
    //  ABSI    = Absolute indirect
    //  ABSX    = Absolute indexed with X
    //  ABSXI   = Absolute indexed with X, indirect
    //  ABSY    = Absolute indexed with Y
    //  DPXI    = Direct Page indexed with X, indirect
    //  DPIY    = Direct Page indirect, indexed with Y
    //  IMM     = Immediate
    //  A       = Accumulator
    //  REL     = Relative
    //
    // If no addressing mode specified, then it is implied.
    // OPCODES:
    localparam
        NOP       = 8'h00, // No Operations
        WAI       = 8'hDF, // Wait for Interrupt
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
        LDY_ABSX  = 8'hAB,
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
        SED       = 8'hF8,
        // Bit Test
        BIT_DP    = 8'hE3,
        BIT_ABS   = 8'hE7,
        BIT_ABSX  = 8'hEB,
        BIT_DPX   = 8'hFB,
        BIT_IMM   = 8'h1F,
        // Decimal Adjust after Addition/Subtraction
        DAA       = 8'hCE,
        DAS       = 8'hEE;

    // MUX SIGNALS
    localparam
        NONE  = 4'h0,
        PCL   = 4'h1, // Program Counter Low (R/W)
        PCH   = 4'h2, // Program Counter High (R/W)
        EAL   = 4'h3, // Effective Address Low (R/W)
        EAH   = 4'h4, // Effective Address High (R/W)
        RAM   = 4'h5, // Memory Data Register (R/W)
        ACC   = 4'h6, // Accumulator (R/W)
        X     = 4'h7, // Index Register X (R/W)
        Y     = 4'h8, // Index Register Y (R/W)
        SP    = 4'h9, // Stack Pointer (R/W)
        A_ALU = 4'hA, // ALU input A (R/W)
        B_ALU = 4'hB, // ALU input B (R/W)
        F     = 4'hC, // Flags Register (R/W)
        D     = 4'hD, // Direct Page Register (R/W)
        IR    = 4'hE, // Instruction Register (WO)
        ALU   = 4'hE, // ALU Output (RO)
        CONST = 4'hF; // Constant Output (RO)
    
    localparam // Flags
        NULL               = 8'b00000000,
        CARRY              = 8'b00000001,
        ZERO               = 8'b00000010,
        DISABLE_INTERRUPT  = 8'b00000100,
        ENABLE_DIRECT_PAGE = 8'b00001000,
        HALF_CARRY         = 8'b00100000,
        OVERFLOW           = 8'b01000000,
        NEGATIVE           = 8'b10000000,
        ALL                = 8'b11111111,
        NZ                 = 8'b10000010,
        NV                 = 8'b11000000,
        NZC                = 8'b10000011,
        NZV                = 8'b11000010,
        NZVC               = 8'b11000011,
        NZVCH              = 8'b11100011;
    
    localparam // Address Select
        PC = 2'b00, // {PCH, PCL}
        EA = 2'b01, // {EAH, EAL}
        DP = 2'b10, // {DP, EAL}
        ST = 2'b11; // {8'h01, SP}
    
    localparam // Timing States
        FETCH  = 4'h0,
        T1     = 4'h1,
        T2     = 4'h2,
        T3     = 4'h3,
        T4     = 4'h4,
        T5     = 4'h5,
        T6     = 4'h6,
        T7     = 4'h7,
        T8     = 4'h8,
        T9     = 4'h9,
        T10    = 4'hA;
    
    localparam // State Control
        ENDS = 2'b00, // Execution Finished, Goto Fetch
        NEXT = 2'b01, // Goto the next State
        HOLD = 2'b11; // Hold current state
        
    localparam // ALU operations
        ALU_ADD  = 4'h0, // Add with carry
        ALU_SUB  = 4'h1, // Subtract with borrow
        ALU_AND  = 4'h2, // Bitwise AND
        ALU_OR   = 4'h3, // Bitwise OR
        ALU_XOR  = 4'h4, // Bitwise XOR
        ALU_SHL  = 4'h5, // Shift Left A
        ALU_SHR  = 4'h6, // Shift Right A
        ALU_CLRB = 4'h7, // Clear Bit
        ALU_SETB = 4'h8, // Set Bit
        ALU_INC  = 4'h9, // Increment A
        ALU_DEC  = 4'hA, // Decrement A
        ALU_NOT  = 4'hB, // Invert A
        ALU_DAA  = 4'hC, // Decimal adjust A after addition
        ALU_DAS  = 4'hD; // Decimal adjust A after subtraction
    
    reg [3:0] oeSel;     // Which register outputs data onto bus
    reg [3:0] wrSel;     // Which register Reads data from bus
    reg [3:0] const;     // Also used as the ALU OPCODE
    reg [1:0] addrSel;   // If I read from memory, what is the pointer
    reg [1:0] nextState; // What happends next
    reg [7:0] updateF;   // Which flag to update
    reg Cin;             // Carry In to the ALU
    reg incPC;           // Increment Program Counter
    reg offsetPC;        // add 8 bit signed offset to Program Counter (Branch)
    reg incEA;           // Increment Effective Address
    reg indexEA;         // Add 8 bit unsigned index to Effective Address
    reg enSP;            // Enable Stack Pointer
    reg dirSP;           // Stack Pointer Increment/Decrement Direction
    reg intHold;         // Allow/disallow interrupts from firing
    reg intHold_next;
    reg isHalted, isHalted_next;
    reg isWaiting, isWaiting_next;
    
    wire CF     = flags[0]; // Carry Flag
    wire ZF     = flags[1]; // Zero Flag
    wire IF     = flags[2]; // Interrupt Enable Flag
    wire VF     = flags[3]; // Overflow Flag
    wire NF     = flags[4]; // Negative Flag
    wire IRQ_IN = flags[5]; // Interrupt Request
    wire NMI_IN = flags[6]; // Non-maskable Interrupt
    wire RST_IN = flags[7]; // Reset
    wire RST, NMI, INT, WAK;// Other signals
    
    InterruptLogic il(
        .clk(clk), 
        .clk_en(clk_en),
        .intHold(intHold), 
        .iFlag(IF), 
        .rst(RST_IN), 
        .irq(IRQ_IN), 
        .nmi(NMI_IN),
        .state(state),
        .RST(RST), 
        .NMI(NMI),
        .INT(INT), 
        .WAK(WAK)
    );
    // Verilog should have booleans actually defined...
    localparam true = 1'b1, false = 1'b0;
    
    // --- HELPER TASKS ---
    task resetControls; // Reset controls to default
        begin
            oeSel = NONE;
            wrSel = NONE;
            addrSel = PC;
            updateF = NULL;
            nextState = NEXT;
            Cin = false;
            incPC = false;
            offsetPC = false;
            incEA = false;
            indexEA = false;
            enSP = false;
            intHold_next = intHold;
            const = 0;
            dirSP = 0;
            isHalted_next = isHalted;
            isWaiting_next = isWaiting;
        end
    endtask
    
    // Transfer [src] to [dst]
    task transfer(input [3:0] src, dst); begin oeSel = src; wrSel = dst; end endtask
    
    // ALU Operation
    task ALUOP(input [3:0] operation, dst, input carry, input [7:0] flagsToUpdate);
        begin
            const = operation;
            oeSel = ALU;
            wrSel = dst;
            Cin = carry;
            updateF = flagsToUpdate;
        end
    endtask
    
    // Read from memory (Auto increment PC)
    task memRead(input [1:0] addr, input [3:0] dst); begin addrSel = addr; transfer(RAM, dst); incPC = (addr == PC); end endtask
    
    // Write to memory
    task memWrite(input [1:0] addr, input [3:0] src); begin addrSel = addr; transfer(src, RAM); end endtask
    
    // ----- ADDRESSING MODES ----- //
    // Read Direct Page byte and store in EAL
    task am_DP; begin if (state == T1) memRead(PC, EAL); end endtask
    
    // Read the next two bytes and store in EA (little endian)
    task am_ABS; 
        begin 
            case (state) 
                T1: memRead(PC, EAL); 
                T2: memRead(PC, EAH); 
            endcase 
        end 
    endtask
    
    // Read byte and add the index register to it.
    task am_DP_INDEXED(input [3:0] indexRegister);
        begin
            case (state)
                T1: memRead(PC, EAL);
                T2: begin
                    indexEA = true;
                    oeSel = indexRegister;
                end
            endcase
        end
    endtask
    
    // Read two bytes, add index to low byte, if carry out, increment high byte
    task am_ABS_INDEXED(input [3:0] indexRegister);
        begin
            case (state)
                T1: memRead(PC, EAL);
                T2: memRead(PC, EAH);
                T3: begin
                    indexEA = true;
                    oeSel = indexRegister;
                end
            endcase
        end
    endtask
    
    // Read one byte, add X to it, read the next two bytes from DP and store in EA
    task am_DPXI;
        begin
            case (state)
                T1, T2: am_DP_INDEXED(X);
                T3: begin
                    memRead(DP, A_ALU);
                    incEA = true;
                end
                T4: memRead(DP, EAH);
                T5: transfer(A_ALU, EAL);
            endcase
        end
    endtask
    
    task am_DPIY;
        begin
            case (state)
                T1: memRead(PC, EAL);
                T2: begin
                    memRead(DP, B_ALU);
                    incEA = true;
                end
                T3: memRead(DP, EAH);
                T4: transfer(B_ALU, EAL);
                T5: begin
                    indexEA = true;
                    oeSel = Y;
                end
            endcase
        end
    endtask
    
    task am_ABS_INDIRECT;
        begin
            case (state)
                T1, T2: am_ABS;
                T3: begin
                    memRead(EA, A_ALU);
                    incEA = true;
                end
                T4: memRead(EA, EAH);
                T5: transfer(A_ALU, EAL);
            endcase
        end
    endtask
    
    task FlagSet(input [7:0] flagsToUpdate, input val);
        begin
            oeSel = CONST;
            wrSel = F;
            const = (val) ? 4'hF : 4'h0;
            updateF = flagsToUpdate;
        end
    endtask
    
    task BREAK; // For BRK, IRQ, NMI, and RST
        begin
            intHold_next = true;
            case (state)
                T1: begin
                    $display("BREAK EXECUTING");
                    if (!RST) begin
                        memWrite(ST, PCH);
                        enSP = true;
                        dirSP = true;
                    end
                end
                T2: begin
                    if (!RST) begin
                        memWrite(ST, PCL);
                        enSP = true;
                        dirSP = true;
                    end
                end
                T3: begin
                    if (!RST) begin
                        memWrite(ST, F);
                        enSP = true;
                        dirSP = true;
                    end
                end
                T4: FlagSet(DISABLE_INTERRUPT, true);
                T5: begin
                    transfer(CONST, EAH);
                    const = 4'hF;
                end
                T6: begin
                    transfer(CONST, EAL);
                    const = (RST) ? 4'hC : 4'hE; // EAL = $FE
                end
                T7: begin
                    if (NMI) begin
                        transfer(CONST, EAL);
                        const = 4'hA; // Overwrite EAL = $FA
                    end
                end
                T8: begin 
                    memRead(EA, PCL);
                    incEA = true;
                end
                T9: begin 
                    memRead(EA, PCH);
                    nextState = ENDS;
                    intHold_next = false;
                end
                default: nextState = ENDS;
            endcase
        end
    endtask
    
    task FetchInstruction; 
        begin
            if (isHalted && !RST) begin
                transfer(CONST, IR);
                const = 4'h0; // Inject NOP
            end else
            // 1. Handle Interrupts (Top Priority)
            if (INT) begin
                transfer(CONST, IR);
                const = 4'hC; // Inject BRK
                intHold_next = true;
                // Clear wait state if we were waiting
                isWaiting_next = false; 
            end 
            // 3. Handle WAIT (Spin until Wake)
            else if (isWaiting) begin
                if (WAK) begin
                    // Wake up! Fetch next instruction normally
                    isWaiting_next = false;
                    memRead(PC, IR); // This sets incPC = true
                end else begin
                    // Keep sleeping: Re-fetch same instruction, DO NOT increment PC
                    addrSel = PC;
                    transfer(RAM, IR);
                end
            end
            // 4. Normal Fetch
            else begin
                //$display("Normal Fetch");
                memRead(PC, IR);
            end
        end 
    endtask
    
    task EXEC_ALU(input [3:0] op, input c, input [6:0] flgs);
        begin
            ALUOP(op, ACC, c, flgs);
            nextState = ENDS;
        end
    endtask
    
    task READY_ALU_FROM_DP;
        begin
            case (state)
                T1: transfer(ACC, A_ALU);
                T2: memRead(PC, EAL);
                T3: memRead(DP, B_ALU);
            endcase
        end
    endtask
    
    task READY_ALU_FROM_DPX;
        begin
            case (state)
                T1, T2: am_DP_INDEXED(X);
                T3: transfer(ACC, A_ALU);
                T4: memRead(DP, B_ALU);
            endcase
        end
    endtask
    
    task READY_ALU_FROM_ABS;
        begin
            case (state)
                T1, T2: am_ABS;
                T3: memRead(EA, B_ALU);
                T4: transfer(ACC, A_ALU);
            endcase
        end
    endtask
    
    task READY_ALU_FROM_ABS_INDEX(input [3:0] indexReg);
        begin
            case (state)
                T1, T2, T3: am_ABS_INDEXED(indexReg);
                T4: memRead(EA, B_ALU);
                T5: transfer(ACC, A_ALU);
            endcase
        end
    endtask
    
    task READY_ALU_FROM_DPXI;
        begin
            case (state)
                T1, T2, T3, T4, T5: am_DPXI;
                T6: memRead(EA, B_ALU);
                T7: transfer(ACC, A_ALU);
            endcase
        end
    endtask
    
    task READY_ALU_FROM_DPIY;
        begin
            case (state)
                T1, T2, T3, T4, T5: am_DPIY;
                T6: memRead(EA, B_ALU);
                T7: transfer(ACC, A_ALU);
            endcase
        end
    endtask
    
    task ALU_OPERATION_G1;
        begin
            case (instruction[7:5])
                3'b000: EXEC_ALU(ALU_ADD, 1'b0, NZVCH); // ADD
                3'b001: EXEC_ALU(ALU_ADD, CF, NZVCH);   // ADC
                3'b010: EXEC_ALU(ALU_SUB, 1'b1, NZVCH); // SUB
                3'b011: EXEC_ALU(ALU_SUB, CF, NZVCH);  // SBB
                3'b100: EXEC_ALU(ALU_AND, 1'b0, NZ);   // AND
                3'b101: EXEC_ALU(ALU_OR, 1'b0, NZ);    // ORA
                3'b110: EXEC_ALU(ALU_XOR, 1'b0, NZ);   // XOR
                3'b111: begin                          // CMP
                    ALUOP(ALU_SUB, NONE, 1'b1, NZC);
                    nextState = ENDS;
                end
            endcase
        end
    endtask

    task DO_BRANCH;
        begin
            case (state) // T1 Loads offset into B
                T1: memRead(PC, B_ALU);
                T2: begin
                    oeSel = B_ALU;
                    offsetPC = true;
                    nextState = ENDS;
                end
            endcase
        end
    endtask

    task BRANCH_ON_FLAG(input [3:0] flag, input value);
        begin
            if (flag == value) DO_BRANCH;
            else begin
                incPC = true; // Skip offset
                nextState = ENDS;
            end
        end
    endtask
    
    always @(*) begin
        resetControls();
        
        case (state)
            FETCH: FetchInstruction;
            default:begin
                case (instruction)
                    NOP: nextState = ENDS;
                    HLT: begin 
                        isHalted_next = true;
                        nextState = ENDS;
                    end
                    WAI: begin
                        isWaiting_next = !WAK;
                        nextState = ENDS;
                    end
                    CLC, SEC, CLD, SED, CLV, CLI, SEI: begin // Set and Clear Flags
                        case (instruction)
                            CLC: FlagSet(CARRY, false);
                            SEC: FlagSet(CARRY, true);
                            CLI: FlagSet(DISABLE_INTERRUPT, false);
                            SEI: FlagSet(DISABLE_INTERRUPT, true);
                            CLV: begin
                                oeSel = CONST;
                                wrSel = F;
                                const = 4'h0;
                                updateF = OVERFLOW | HALF_CARRY;
                            end
                            CLD: FlagSet(ENABLE_DIRECT_PAGE, false);
                            SED: FlagSet(ENABLE_DIRECT_PAGE, true);
                        endcase
                        nextState = ENDS;
                    end
                    TAX, TXA, TAY, TYA, TSX, TXS, TDY, TYD: begin // Transfer Registers
                        if (instruction != TXS && instruction != TYD) updateF = NZ;
                        case (instruction[7:5])
                            3'b000: transfer(ACC, X);
                            3'b001: transfer(X, ACC);
                            3'b010: transfer(ACC, Y);
                            3'b011: transfer(Y, ACC);
                            3'b100: transfer(SP, X);
                            3'b101: transfer(X, SP);
                            3'b110: transfer(D, Y);
                            3'b111: transfer(Y, D);
                        endcase
                        nextState = ENDS;
                    end
                    ADD_DP, ADC_DP, SUB_DP, SBB_DP, AND_DP, ORA_DP, XOR_DP, CMP_DP: begin // ALU with direct page
                        case (state)
                            T1, T2, T3: READY_ALU_FROM_DP;
                            T4: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_DPX, ADC_DPX, SUB_DPX, SBB_DPX, AND_DPX, ORA_DPX, XOR_DPX, CMP_DPX: begin // ALU with direct page indexed with X
                        case (state)
                            T1, T2, T3, T4: READY_ALU_FROM_DPX;
                            T5: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_ABS, ADC_ABS, SUB_ABS, SBB_ABS, AND_ABS, ORA_ABS, XOR_ABS, CMP_ABS: begin // ALU with absolute
                        case (state)
                            T1, T2, T3, T4: READY_ALU_FROM_ABS;
                            T5: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_ABSX, ADC_ABSX, SUB_ABSX, SBB_ABSX, AND_ABSX, ORA_ABSX, XOR_ABSX, CMP_ABSX: begin // ALU with absolute indexed with X
                        case (state)
                            T1, T2, T3, T4, T5: READY_ALU_FROM_ABS_INDEX(X);
                            T6: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_ABSY, ADC_ABSY, SUB_ABSY, SBB_ABSY, AND_ABSY, ORA_ABSY, XOR_ABSY, CMP_ABSY: begin // ALU with absolute indexed with Y
                        case (state)
                            T1, T2, T3, T4, T5: READY_ALU_FROM_ABS_INDEX(Y);
                            T6: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_DPXI, ADC_DPXI, SUB_DPXI, SBB_DPXI, AND_DPXI, ORA_DPXI, XOR_DPXI, CMP_DPXI: begin // ALU with direct page indexed with X, indirect
                        case (state)
                            T1, T2, T3, T4, T5, T6, T7: READY_ALU_FROM_DPXI;
                            T8: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_DPIY, ADC_DPIY, SUB_DPIY, SBB_DPIY, AND_DPIY, ORA_DPIY, XOR_DPIY, CMP_DPIY: begin // ALU with direct page indirect, indexed with Y 
                        case (state)
                            T1, T2, T3, T4, T5, T6, T7: READY_ALU_FROM_DPIY;
                            T8: ALU_OPERATION_G1;
                        endcase
                    end
                    ADD_IMM, ADC_IMM, SUB_IMM, SBB_IMM, AND_IMM, ORA_IMM, XOR_IMM, CMP_IMM: begin // ALU with Immediate Value
                        case (state)
                            T1: memRead(PC, B_ALU);
                            T2: transfer(ACC, A_ALU);
                            T3: ALU_OPERATION_G1;
                        endcase
                    end
                    LDA_DP, LDX_DP, LDY_DP, STA_DP, STX_DP, STY_DP, STZ_DP: begin
                        case (state)
                            T1: am_DP;
                            T2: begin
                                if (instruction[5]) begin
                                    updateF = NZ;
                                    case (instruction[7:6])
                                        2'b00: memRead(DP, ACC);
                                        2'b01: memRead(DP, X);
                                        2'b10: memRead(DP, Y);
                                    endcase
                                end else begin
                                    case (instruction[7:6])
                                        2'b00: memWrite(DP, ACC);
                                        2'b01: memWrite(DP, X);
                                        2'b10: memWrite(DP, Y);
                                        2'b11: begin
                                            const = 0;
                                            memWrite(DP, CONST);
                                        end
                                    endcase
                                end
                                nextState = ENDS;
                            end
                        endcase
                    end
                    LDA_ABS, LDX_ABS, LDY_ABS, STA_ABS, STX_ABS, STY_ABS, STZ_ABS: begin
                        case (state)
                            T1, T2: am_ABS;
                            T3: begin
                                if (instruction[5]) begin
                                    updateF = NZ;
                                    case (instruction[7:6])
                                        2'b00: memRead(EA, ACC);
                                        2'b01: memRead(EA, X);
                                        2'b10: memRead(EA, Y);
                                    endcase
                                end else begin
                                    case (instruction[7:6])
                                        2'b00: memWrite(EA, ACC);
                                        2'b01: memWrite(EA, X);
                                        2'b10: memWrite(EA, Y);
                                        2'b11: begin
                                            const = 0;
                                            memWrite(EA, CONST);
                                        end
                                    endcase
                                end
                                nextState = ENDS;
                            end
                        endcase
                    end
                    LDA_ABSX, LDA_ABSY, LDY_ABSX, LDX_ABSY, STA_ABSX, STA_ABSY, STZ_ABSX: begin
                        case (state)
                            T1, T2, T3: begin
                                case (instruction)
                                    LDA_ABSX, LDY_ABSX, STA_ABSX, STZ_ABSX: am_ABS_INDEXED(X);
                                    LDA_ABSY, LDX_ABSY, STA_ABSY: am_ABS_INDEXED(Y);
                                endcase
                            end
                            T4: begin
                                if (instruction[5]) begin
                                    updateF = NZ;
                                    case (instruction[7:6])
                                        2'b00: memRead(EA, ACC);
                                        2'b01: memRead(EA, X);
                                        2'b10: memRead(EA, Y);
                                    endcase
                                end else begin
                                    case (instruction[7:6])
                                        2'b00: memWrite(EA, ACC);
                                        2'b01: memWrite(EA, X);
                                        2'b10: memWrite(EA, Y);
                                        2'b11: begin
                                            const = 0;
                                            memWrite(EA, CONST);
                                        end
                                    endcase
                                end
                                nextState = ENDS;
                            end
                        endcase
                    end
                    LDA_DPXI, LDA_DPIY, STA_DPXI, STA_DPIY: begin
                        case (state)
                            T1, T2, T3, T4, T5: begin
                                case (instruction)
                                    LDA_DPXI, STA_DPXI: am_DPXI;
                                    LDA_DPIY, STA_DPIY: am_DPIY;
                                endcase
                            end
                            T6: begin
                                if (instruction[5]) begin
                                    updateF = NZ;
                                    memRead(EA, ACC);
                                end else begin
                                    memWrite(EA, ACC);
                                end
                                nextState = ENDS;
                            end
                        endcase
                    end
                    STA_DPX, LDA_DPX, STX_DPY, LDX_DPY, STY_DPX, LDY_DPX, STZ_DPX: begin
                        case (state)
                            T1, T2: begin
                                case (instruction)
                                    LDA_DPX, STA_DPX, STZ_DPX: am_DP_INDEXED(X);
                                    LDX_DPY, STY_DPX, LDY_DPX: am_DP_INDEXED(Y);
                                endcase
                            end
                            T3: begin
                                if (instruction[5]) begin
                                    updateF = NZ;
                                    case (instruction[7:6])
                                        2'b00: memRead(DP, ACC);
                                        2'b01: memRead(DP, X);
                                        2'b10: memRead(DP, Y);
                                    endcase
                                end else begin
                                    case (instruction[7:6])
                                        2'b00: memWrite(DP, ACC);
                                        2'b01: memWrite(DP, X);
                                        2'b10: memWrite(DP, Y);
                                        2'b11: begin
                                            const = 0;
                                            memWrite(DP, CONST);
                                        end
                                    endcase
                                end
                                nextState = ENDS;
                            end
                        endcase
                    end
                    LDA_IMM, LDX_IMM, LDY_IMM: begin
                        case (state)
                            T1: begin
                                case (instruction)
                                    LDA_IMM: memRead(PC, ACC);
                                    LDX_IMM: memRead(PC, X);
                                    LDY_IMM: memRead(PC, Y);
                                endcase
                            end
                            T2: begin
                                updateF = NZ;
                                // Drive the register onto the bus to update flags
                                // src and dst are the same just to expose value to the bus
                                case (instruction)
                                    LDA_IMM: transfer(ACC, NONE);
                                    LDX_IMM: transfer(X, NONE);
                                    LDY_IMM: transfer(Y, NONE);
                                endcase
                                nextState = ENDS;
                            end
                        endcase
                    end
                    ASL_A, ROL_A, LSR_A, ROR_A, DEC_A, INC_A, INX, INY, DEX, DEY: begin
                        case (state)
                            T1: begin
                                case (instruction)
                                    INX, DEX: transfer(X, A_ALU);
                                    INY, DEY: transfer(Y, A_ALU);
                                    default: transfer(ACC, A_ALU);
                                endcase
                            end
                            T2: begin
                                case (instruction)
                                    ASL_A: ALUOP(ALU_SHL, ACC, false, NZC);
                                    ROL_A: ALUOP(ALU_SHL, ACC, CF, NZC);
                                    LSR_A: ALUOP(ALU_SHR, ACC, false, NZC);
                                    ROR_A: ALUOP(ALU_SHR, ACC, CF, NZC);
                                    DEC_A: ALUOP(ALU_DEC, ACC, false, NZ);
                                    INC_A: ALUOP(ALU_INC, ACC, false, NZ);
                                    INX: ALUOP(ALU_INC, X, false, NZ);
                                    INY: ALUOP(ALU_INC, Y, false, NZ);
                                    DEX: ALUOP(ALU_DEC, X, false, NZ);
                                    DEY: ALUOP(ALU_DEC, Y, false, NZ);
                                endcase
                                nextState = ENDS;
                            end
                        endcase
                    end
                    ASL_DP, LSR_DP, ROL_DP, ROR_DP, INC_DP, DEC_DP: begin
                        case (state)
                            T1: am_DP;
                            T2: memRead(DP, A_ALU);
                            T3: begin
                                case (instruction)
                                    ASL_DP: ALUOP(ALU_SHL, B_ALU, false, NZC);
                                    ROL_DP: ALUOP(ALU_SHL, B_ALU, CF, NZC);
                                    LSR_DP: ALUOP(ALU_SHR, B_ALU, false, NZC);
                                    ROR_DP: ALUOP(ALU_SHR, B_ALU, CF, NZC);
                                    DEC_DP: ALUOP(ALU_DEC, B_ALU, false, NZ);
                                    INC_DP: ALUOP(ALU_INC, B_ALU, false, NZ);
                                endcase
                            end
                            T4: begin
                                memWrite(DP, B_ALU);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    ASL_DPX, LSR_DPX, ROL_DPX, ROR_DPX, INC_DPX, DEC_DPX: begin
                        case (state)
                            T1, T2: am_DP_INDEXED(X);
                            T3: memRead(DP, A_ALU);
                            T4: begin  // Could posibly write  directly  from  ALU to  RAM?
                                case (instruction)
                                    ASL_DPX: ALUOP(ALU_SHL, B_ALU, false, NZC);
                                    ROL_DPX: ALUOP(ALU_SHL, B_ALU, CF, NZC);
                                    LSR_DPX: ALUOP(ALU_SHR, B_ALU, false, NZC);
                                    ROR_DPX: ALUOP(ALU_SHR, B_ALU, CF, NZC);
                                    DEC_DPX: ALUOP(ALU_DEC, B_ALU, false, NZ);
                                    INC_DPX: ALUOP(ALU_INC, B_ALU, false, NZ);
                                endcase
                            end
                            T5: begin
                                memWrite(DP, B_ALU);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    ASL_ABS, LSR_ABS, ROL_ABS, ROR_ABS, INC_ABS, DEC_ABS: begin
                        case (state)
                            T1, T2: am_ABS;
                            T3: memRead(EA, A_ALU);
                            T4: begin
                                case (instruction)
                                    ASL_ABS: ALUOP(ALU_SHL, B_ALU, false, NZC);
                                    ROL_ABS: ALUOP(ALU_SHL, B_ALU, CF, NZC);
                                    LSR_ABS: ALUOP(ALU_SHR, B_ALU, false, NZC);
                                    ROR_ABS: ALUOP(ALU_SHR, B_ALU, CF, NZC);
                                    DEC_ABS: ALUOP(ALU_DEC, B_ALU, false, NZ);
                                    INC_ABS: ALUOP(ALU_INC, B_ALU, false, NZ);
                                endcase
                            end
                            T5: begin
                                memWrite(EA, B_ALU);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    CPX_DP, CPY_DP: begin
                        case (state)
                            T1: am_DP;
                            T2: transfer((instruction == CPX_DP) ? X : Y, A_ALU);
                            T3: memRead(DP, B_ALU);
                            T4: begin
                                ALUOP(ALU_SUB, NONE, 1'b1, NZC);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    CPX_ABS, CPY_ABS: begin
                        case (state)
                            T1, T2: am_ABS;
                            T3: transfer((instruction == CPX_ABS) ? X : Y, A_ALU);
                            T4: memRead(EA, B_ALU);
                            T5: begin
                                ALUOP(ALU_SUB, NONE, 1'b1, NZC);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    CPX_IMM, CPY_IMM: begin
                        case (state)
                            T1: memRead(PC, B_ALU);
                            T2: transfer((instruction == CPX_IMM) ? X : Y, A_ALU);
                            T3: begin
                                ALUOP(ALU_SUB, NONE, 1'b1, NZC);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    BRA_REL, BPL_REL, BMI_REL, BVC_REL, BVS_REL, BCC_REL, BCS_REL, BNE_REL, BEQ_REL: begin
                        case (instruction)
                            BRA_REL: DO_BRANCH;
                            BPL_REL, BMI_REL: BRANCH_ON_FLAG(NF, instruction[5]);
                            BVC_REL, BVS_REL: BRANCH_ON_FLAG(VF, instruction[5]);
                            BCC_REL, BCS_REL: BRANCH_ON_FLAG(CF, instruction[5]);
                            BNE_REL, BEQ_REL: BRANCH_ON_FLAG(ZF, instruction[5]);
                        endcase
                    end
                    JMP_ABS: begin
                        case (state)
                            T1: memRead(PC, EAL); 
                            T2: memRead(PC, PCH);
                            T3: begin
                                transfer(EAL, PCL);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    JMP_ABSI: begin
                        case (state)
                            T1, T2: am_ABS;
                            T3: begin
                                memRead(EA, PCL);
                                incEA = true;
                            end
                            T4: begin
                                memRead(EA, PCH);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    JMP_ABSXI: begin
                        case (state)
                            T1, T2, T3: am_ABS_INDEXED(X);
                            T4: begin
                                memRead(EA, PCL);
                                incEA = true;
                            end
                            T5: begin
                                memRead(EA, PCH);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    JSR_ABS: begin
                        case (state)
                            T1, T2: am_ABS;
                            T3: begin
                                memWrite(ST, PCH);
                                enSP = true;
                                dirSP = true;
                            end
                            T4: begin
                                memWrite(ST, PCL);
                                enSP = true;
                                dirSP = true;
                            end
                            T5: transfer(EAL, PCL);
                            T6: begin
                                transfer(EAH, PCH);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    RTS: begin
                        case (state)
                            T1: begin
                                enSP = true;
                                dirSP = false;
                            end
                            T2: begin
                                memRead(ST, PCL);
                                enSP = true;
                                dirSP = false;
                            end
                            T3: begin
                                memRead(ST, PCH);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    BRK: BREAK;
                    RTI: begin
                        case (state)
                            T1: begin
                                enSP = true;
                                dirSP = false;
                            end
                            T2: begin
                                memRead(ST, F);
                                updateF = ALL;
                                enSP = true;
                                dirSP = false;
                            end
                            T3: begin
                                memRead(ST, PCL);
                                enSP = true;
                                dirSP = false;
                            end
                            T4: begin
                                memRead(ST, PCH);
                                nextState = ENDS;
                            end
                        endcase
                    end
                    PHA, PHF, PHX, PHY: begin // Push Onto Stack
                        case (state)
                            T1: begin
                                case (instruction)
                                    PHA: begin
                                        memWrite(ST, ACC);
                                        enSP = true;
                                        dirSP = true;
                                    end
                                    PHX: begin
                                        memWrite(ST, X);
                                        enSP = true;
                                        dirSP = true;
                                    end
                                    PHY: begin
                                        memWrite(ST, Y);
                                        enSP = true;
                                        dirSP = true;
                                    end
                                    PHF: begin
                                        memWrite(ST, F);
                                        enSP = true;
                                        dirSP = true;
                                    end
                                endcase
                                nextState = ENDS;
                            end
                        endcase
                    end
                    PLA, PLF, PLX, PLY: begin // Pull off of Stack
                        case (state)
                            T1: begin
                                enSP = true;
                                dirSP = false; 
                            end
                            T2: begin
                                case (instruction)
                                    PLA: memRead(ST, ACC);
                                    PLX: memRead(ST, X);
                                    PLY: memRead(ST, Y);
                                    PLF: memRead(ST, F);
                                endcase
                                case (instruction)
                                    PLA, PLX, PLY: updateF = NZ;
                                    PLF: updateF = ALL;
                                endcase
                                nextState = ENDS;
                            end
                        endcase
                    end
                    BIT_DP: begin
                        case (state)
                            T1: am_DP;
                            T2: memRead(DP, B_ALU);
                            T3: transfer(ACC, A_ALU);
                            T4: ALUOP(ALU_AND, NONE, false, ZERO);
                            T5: begin
                                transfer(B_ALU, F);
                                updateF = NV;
                            end
                        endcase
                    end
                    BIT_ABS: begin
                        case (state)
                            T1, T2: am_ABS;
                            T3: memRead(EA, B_ALU);
                            T4: transfer(ACC, A_ALU);
                            T5: ALUOP(ALU_AND, NONE, false, ZERO);
                            T6: begin
                                transfer(B_ALU, F);
                                updateF = NV;
                            end
                        endcase
                    end
                    BIT_ABSX: begin
                        case (state)
                            T1, T2, T3: am_ABS_INDEXED(X);
                            T4: memRead(EA, B_ALU);
                            T5: transfer(ACC, A_ALU);
                            T6: ALUOP(ALU_AND, NONE, false, ZERO);
                            T7: begin
                                transfer(B_ALU, F);
                                updateF = NV;
                            end
                        endcase
                    end
                    BIT_DPX: begin
                        case (state)
                            T1, T2: am_DP_INDEXED(X);
                            T3: memRead(DP, B_ALU);
                            T4: transfer(ACC, A_ALU);
                            T5: ALUOP(ALU_AND, NONE, false, ZERO);
                            T6: begin
                                transfer(B_ALU, F);
                                updateF = NV;
                            end
                        endcase
                    end
                    BIT_IMM: begin
                        case (state)
                            T1: memRead(PC, B_ALU);
                            T2: transfer(ACC, A_ALU);
                            T3: ALUOP(ALU_AND, NONE, false, ZERO);
                            T4: begin
                                transfer(B_ALU, F);
                                updateF = NV;
                            end
                        endcase
                    end
                    DAA: begin
                        case (state)
                            T1: transfer(ACC, A_ALU);
                            T2: begin
                                ALUOP(ALU_DAA, ACC, CF, NZC); 
                                nextState = ENDS;
                            end
                        endcase
                    end
                    DAS: begin
                        case (state)
                            T1: transfer(ACC, A_ALU);
                            T2: begin
                                ALUOP(ALU_DAS, ACC, CF, NZC); 
                                nextState = ENDS;
                            end
                        endcase
                    end
                    default: nextState = ENDS;//$display("Error: Unknown Opcode ($%02H)", instruction);
                endcase
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (clk_en) begin
            intHold <= intHold_next;
            isHalted <= isHalted_next;   // <--- Add this
            isWaiting <= isWaiting_next; // <--- Add this
        end
        // Synchronous Reset for Halted state
        if (flags[7]) begin // flags[7] is RST_IN
             isHalted <= 0;
             isWaiting <= 0;
        end
    end
    
    // --- BIT INDEXES ---
    //                     31,    30,   29,      28,    27,       26,    25,  24,   23:16,   15:14,     13:12,  11:8,   7:4,   3:0
    assign controlWord = {INT, dirSP, enSP, indexEA, incEA, offsetPC, incPC, Cin, updateF, addrSel, nextState, const, wrSel, oeSel};
endmodule
