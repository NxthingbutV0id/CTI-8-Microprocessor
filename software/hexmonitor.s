UART_DATA   = $6000
UART_STATUS = $6001
UART_CTRL   = $6002

; Direct Page Storage
IN_PTR      = $10 ; Pointer to Input Buffer
ADDR_L      = $12 ; Current Address Low
ADDR_H      = $13 ; Current Address High
VAL_L       = $14 ; Current Parsed Value Low
VAL_H       = $15 ; Current Parsed Value High
MODE        = $16 ; 0=XAM, 1=STORE, 2=BLOCK
DIGIT_COUNT = $18 ; Counts hex digits parsed
VAL_EXP     = $19 ; Expected Value
VAL_GOT     = $1A ; Got Value
PTR_L       = $1B ; Pointer Low
PTR_H       = $1C ; Pointer High

BUFFER      = $0200

.org $8000

RESET:
    SEI                 ; Disable Interrupts
    CLD                 ; Direct Page disabled
    LDX #$FF
    TXS
    LDY #$00
    TYD
    LDA #$00
    STA UART_CTRL       ; Disable UART IRQ
    LDA #$5C            ; "\"
    JSR ECHO
PROMPT:
    JSR PRINT_NEWLINE
    
    ; --- GET LINE ---
    LDY #$00            ; Buffer Index
GET_CHAR:
    JSR UART_RX
    CMP #$08            ; Backspace
    BEQ HANDLE_BS
    CMP #$7F            ; Delete
    BEQ HANDLE_BS
    CMP #$0D            ; CR
    BEQ LINE_DONE
    CMP #$61            ; Lowercase 'a'
    BCC STORE_CHAR
    CMP #$7B            ; Lowercase 'z' + 1
    BCS STORE_CHAR
    SUB #$20            ; Convert to Uppercase
STORE_CHAR:
    CMP #$20            ; Check for space or valid chars
    BCC GET_CHAR        ; Ignore control codes < 32
    STA BUFFER, Y
    JSR ECHO
    INY
    BRA GET_CHAR        ; Loop (Limit 256 chars)

HANDLE_BS:
    CPY #$00
    BNE BS_NOT_EMPTY    ; Empty buffer, drop to next line
    JSR PRINT_NEWLINE
    BRA GET_CHAR
BS_NOT_EMPTY:
    DEY
    LDA #$08 ; Backspace
    JSR ECHO
    LDA #$20 ; Space
    JSR ECHO
    LDA #$08 ; Backspace
    JSR ECHO
    BRA GET_CHAR

LINE_DONE:
    JSR PRINT_NEWLINE
    
    LDA #$0D            ; Add CR to Buffer for parser
    STA BUFFER, Y
    
    ; --- PARSE LINE ---
    LDA #$00
    STA IN_PTR          ; Reset Buffer Pointer
    STA MODE            ; Default Mode = XAM
    
NEXT_TOKEN:
    LDA #$00
    STA VAL_L
    STA VAL_H
    STA DIGIT_COUNT

SKIP_SPACE:
    LDX IN_PTR
    LDA BUFFER, X
    INC IN_PTR
    
    CMP #$20            ; Space?
    BEQ SKIP_SPACE
    CMP #$2C            ; Comma?
    BEQ SKIP_SPACE
    CMP #$0D            ; CR (End of Line)
    BEQ PROMPT          ; Done parsing
    CMP #$2E            ; "." (Block Mode)
    BEQ SET_BLOCK
    CMP #$3A            ; ":" (Store Mode)
    BEQ SET_STORE
    CMP #$52            ; "R" (Run)
    BEQ DO_RUN
    CMP #$54            ; "T" (Test Mode)
    BEQ DO_TEST
    ; Check for Hex Digit
    JSR IS_HEX
    BCC INVALID_INPUT   ; Not hex, not delimiter -> Error
    
    ; --- PARSE NUMBER ---
    ; We already read the first digit in A. Back up PTR to re-read it.
    DEC IN_PTR
    
PARSE_LOOP:
    LDX IN_PTR
    LDA BUFFER, X
    JSR IS_HEX
    BCC TOKEN_DONE      ; Not a digit, token finished
    
    INC IN_PTR
    INC DIGIT_COUNT
    
    ; Shift VAL << 4
    LDY #$04
SHIFT_VAL:
    ASL VAL_L
    ROL VAL_H
    DEY
    BNE SHIFT_VAL
    
    ; Add Digit
    ORA VAL_L
    STA VAL_L
    JMP PARSE_LOOP

TOKEN_DONE:
    ; We have a value in VAL_H:VAL_L
    
    LDA MODE
    CMP #$00            ; XAM Mode?
    BEQ DO_XAM
    
    CMP #$01            ; STORE Mode?
    BEQ DO_STORE
    
    CMP #$02            ; BLOCK Mode?
    BEQ DO_BLOCK
    
    CMP #$03            ; TEST Mode?
    BEQ DO_TEST
    
    JMP INVALID_INPUT

; --- ACTIONS ---

DO_XAM:
    ; Set Address
    LDA VAL_L
    STA ADDR_L
    LDA VAL_H
    STA ADDR_H
    
    JSR PRINT_ADDR_DATA ; "AAAA: DD"
    JMP NEXT_TOKEN

DO_STORE:
    ; Store VAL_L to [ADDR]
    ; Echo removed for clean input
    
    LDA VAL_L           ; Get Byte to Write
    LDY #$00
    STA (ADDR_L), Y     ; Indirect Store
    
    ; Increment Address
    INC ADDR_L
    BNE NEXT_TOKEN
    INC ADDR_H
    JMP NEXT_TOKEN

DO_BLOCK:
    ; VAL is End Address. ADDR is Start Address.
    ; Ensure we start on a new line
    JSR PRINT_NEWLINE
BLOCK_LINE_START:
    ; Print Address Header "AAAA: "
    LDA ADDR_H
    JSR PRBYTE
    LDA ADDR_L
    JSR PRBYTE
    LDA #$3A    ; ':'
    JSR ECHO
    LDA #$20    ; ' '
    JSR ECHO
BLOCK_DATA_LOOP:
    ; Print Data
    LDY #$00
    LDA (ADDR_L), Y
    JSR PRBYTE
    LDA #$20    ; ' '
    JSR ECHO
    ; Check if done (ADDR == VAL)
    LDA ADDR_L
    CMP VAL_L
    BNE BLOCK_CHECK_ALIGN
    LDA ADDR_H
    CMP VAL_H
    BNE BLOCK_CHECK_ALIGN
    ; Done
    LDA #$00
    STA MODE            ; Reset to XAM
    JMP NEXT_TOKEN
BLOCK_CHECK_ALIGN:
    ; Increment Address
    INC ADDR_L
    BNE CHECK_MOD_8
    INC ADDR_H
CHECK_MOD_8:
    ; If ADDR_L % 8 == 0, Start New Line
    LDA ADDR_L
    AND #$07
    BEQ BLOCK_NEWLINE
    ; Else continue on same line
    JMP BLOCK_DATA_LOOP
BLOCK_NEWLINE:
    JSR PRINT_NEWLINE
    JMP BLOCK_LINE_START

DO_RUN:
    JMP (ADDR_L)        ; Jump Indirect to current address

DO_TEST:
    JMP TEST_CODE

SET_BLOCK:
    LDA #$02
    STA MODE
    JMP NEXT_TOKEN

SET_STORE:
    LDA #$01
    STA MODE
    JMP NEXT_TOKEN

INVALID_INPUT:
    LDA #$5C            ; "\"
    JSR ECHO
    JMP PROMPT

; --- SUBROUTINES ---

PRINT_ADDR_DATA:
    JSR PRINT_NEWLINE
    ; Print ADDR_H
    LDA ADDR_H
    JSR PRBYTE
    ; Print ADDR_L
    LDA ADDR_L
    JSR PRBYTE
    ; Print ": "
    LDA #$3A
    JSR ECHO
    LDA #$20
    JSR ECHO
    ; Read Data
    LDY #$00
    LDA (ADDR_L), Y
    JSR PRBYTE
    RTS

IS_HEX:
    ; Input A. Output Carry=1 if Hex, Carry=0 if not.
    ; Also converts ASCII '0'-'9', 'A'-'F' to 0-15 in A.
    CMP #$30            ; '0'
    BMI NOT_HEX_RET     ; If A < '0', Fail
    CMP #$3A            ; '9' + 1
    BMI IS_DIGIT        ; If A < ':', it is 0-9
    CMP #$41            ; 'A'
    BMI NOT_HEX_RET     ; If A < 'A' (and >= ':'), Fail
    CMP #$47            ; 'F' + 1
    BMI IS_ALPHA        ; If A < 'G', it is A-F
NOT_HEX_RET:
    CLC                 ; Not Hex
    RTS
IS_DIGIT:
    SUB #$30            ; '0'-'9' -> 0-9
    SEC                 ; Success
    RTS
IS_ALPHA:
    SUB #$37            ; 'A'-'F' -> 10-15
    SEC                 ; Success
    RTS

PRBYTE:
    PHA
    LSR
    LSR
    LSR
    LSR
    JSR PRHEX
    PLA
PRHEX:
    AND #$0F
    ORA #$30
    CMP #$3A
    BCC ECHO
    ADD #$07
UART_TX:
ECHO:
    PHA
TX_WAIT:
    LDA UART_STATUS
    AND #$02
    BNE TX_WAIT
    PLA
    STA UART_DATA
    RTS

UART_RX:
RX_WAIT:
    LDA UART_STATUS
    AND #$01
    BEQ RX_WAIT
    LDA UART_DATA
    RTS

TEST_CODE:
    JSR PRINT_NEWLINE
    JSR PRINT_INLINE
    .asciiz "RUNNING PROCESSOR TESTING SOFTWARE\r\n"

    ; ==========================================================================
    ; MEMORY TESTS
    ; ==========================================================================
    JSR PRINT_INLINE
    .asciiz "\r\nMEMORY TESTS:\r\n"

    ; --- DP0 (Standard Direct Page) ---
    JSR PRINT_INLINE
    .asciiz "    DP0 (0020):  "
    LDA #$55
    STA $20
    LDA $20
    LDX #$55
    JSR CHECK_RESULT

    ; --- ABS (Absolute Addressing) ---
    JSR PRINT_INLINE
    .asciiz "    ABS (0300):  "
    LDA #$AA
    STA $0300
    LDA $0300
    LDX #$AA
    JSR CHECK_RESULT

    ; --- ABS,X (Indexed) ---
    JSR PRINT_INLINE
    .asciiz "    ABS,X (0301):"
    LDX #$01
    LDA #$CC
    STA $0300, X        ; Should write to $0301
    LDA $0301
    LDX #$CC
    JSR CHECK_RESULT

    ; --- DP1 (Banked Direct Page - If Implemented) ---
    ; This tests if TYD and SED work to change the DP upper byte
    JSR PRINT_INLINE
    .asciiz "    DP1 (Bank):  "
    
    LDY #$04            ; We want DP to be at $0400
    TYD                 ; Transfer Y to D Register
    SED                 ; Enable DP Banking (D Flag = 1)
    
    LDA #$BB
    STA $20             ; Should write to $0420
    
    CLD                 ; Disable Banking (Back to Page 0)
    LDA $0420           ; Read Absolute from $0420
    LDX #$BB
    JSR CHECK_RESULT

    ; ==========================================================================
    ; ALU TESTS (ARITHMETIC)
    ; ==========================================================================
    JSR PRINT_INLINE
    .asciiz "\r\nALU TESTS:\r\n"
    
    ; --- ADD ---
    JSR PRINT_INLINE
    .asciiz "    ADD:         "
    LDA #$10
    ADD #$20
    LDX #$30
    JSR CHECK_RESULT

    ; --- ADC (C=0) ---
    JSR PRINT_INLINE
    .asciiz "    ADC(C=0):    "
    CLC
    LDA #$10
    ADC #$20
    LDX #$30
    JSR CHECK_RESULT

    ; --- ADC (C=1) ---
    JSR PRINT_INLINE
    .asciiz "    ADC(C=1):    "
    SEC
    LDA #$10
    ADC #$20
    LDX #$31
    JSR CHECK_RESULT

    ; --- SUB ---
    JSR PRINT_INLINE
    .asciiz "    SUB:         "
    LDA #$10
    SUB #$01
    LDX #$0F
    JSR CHECK_RESULT

    ; --- SBB (C=1 / No Borrow) ---
    JSR PRINT_INLINE
    .asciiz "    SBB(C=1):    "
    SEC                 ; Carry=1 means No Borrow
    LDA #$10
    SBB #$01
    LDX #$0F            ; 10 - 1 - 0 = 0F
    JSR CHECK_RESULT

    ; --- SBB (C=0 / Borrow) ---
    JSR PRINT_INLINE
    .asciiz "    SBB(C=0):    "
    CLC                 ; Carry=0 means Borrow
    LDA #$10
    SBB #$01
    LDX #$0E            ; 10 - 1 - 1 = 0E
    JSR CHECK_RESULT

    ; ==========================================================================
    ; ALU TESTS (LOGICAL)
    ; ==========================================================================

    ; --- AND ---
    JSR PRINT_INLINE
    .asciiz "    AND:         "
    LDA #$FF
    AND #$0F
    LDX #$0F
    JSR CHECK_RESULT

    ; --- ORA ---
    JSR PRINT_INLINE
    .asciiz "    ORA:         "
    LDA #$F0
    ORA #$0F
    LDX #$FF
    JSR CHECK_RESULT

    ; --- XOR ---
    JSR PRINT_INLINE
    .asciiz "    XOR:         "
    LDA #$AA
    XOR #$FF
    LDX #$55
    JSR CHECK_RESULT

    ; ==========================================================================
    ; ALU TESTS (SHIFT/ROTATE)
    ; ==========================================================================

    ; --- ASL ---
    JSR PRINT_INLINE
    .asciiz "    ASL:         "
    LDA #$01
    ASL
    LDX #$02
    JSR CHECK_RESULT

    ; --- LSR ---
    JSR PRINT_INLINE
    .asciiz "    LSR:         "
    LDA #$04
    LSR
    LDX #$02
    JSR CHECK_RESULT

    ; --- ROL (C=0) ---
    JSR PRINT_INLINE
    .asciiz "    ROL(C=0):    "
    CLC
    LDA #$01
    ROL                 ; 00000001 -> 00000010 (Carry 0 in)
    LDX #$02
    JSR CHECK_RESULT

    ; --- ROL (C=1) ---
    JSR PRINT_INLINE
    .asciiz "    ROL(C=1):    "
    SEC
    LDA #$00
    ROL                 ; 00000000 -> 00000001 (Carry 1 shifted in)
    LDX #$01
    JSR CHECK_RESULT

    JSR PRINT_INLINE
    .asciiz "    ROL2:        "
    CLC
    LDA #$80
    ROL
    ROL
    LDX #$01
    JSR CHECK_RESULT

    ; --- ROR (C=0) ---
    JSR PRINT_INLINE
    .asciiz "    ROR(C=0):    "
    CLC
    LDA #$02
    ROR                 ; 00000010 -> 00000001 (Carry 0 in)
    LDX #$01
    JSR CHECK_RESULT

    ; --- ROR (C=1) ---
    JSR PRINT_INLINE
    .asciiz "    ROR(C=1):    "
    SEC
    LDA #$00
    ROR                 ; 00000000 -> 10000000 (Carry 1 shifted in)
    LDX #$80
    JSR CHECK_RESULT

    JSR PRINT_INLINE
    .asciiz "    ROR2:        "
    CLC
    LDA #$01
    ROR
    ROR
    LDX #$80
    JSR CHECK_RESULT

    ; Decimal adjust tests
    JSR PRINT_INLINE
    .asciiz "    DAA:         "
    LDA #$07
    ADD #$06
    DAA
    LDX #$13
    JSR CHECK_RESULT

    JSR PRINT_INLINE
    .asciiz "    DAS:        "
    LDA #$23
    SUB #$05
    DAS
    LDX #$18
    JSR CHECK_RESULT

    ; ==========================================================================
    ; STACK TESTS
    ; ==========================================================================
    JSR PRINT_INLINE
    .asciiz "\r\nSTACK TESTS:\r\n"

    ; --- PUSH/PULL A ---
    JSR PRINT_INLINE
    .asciiz "    PUSH/PULL A: "
    LDA #$AA
    PHA
    LDA #$00
    PLA
    LDX #$AA
    JSR CHECK_RESULT

    ; --- PUSH/PULL X ---
    JSR PRINT_INLINE
    .asciiz "    PUSH/PULL X: "
    LDX #$BB
    PHX
    LDX #$00
    PLX
    CPX #$BB
    BNE STACK_X_FAIL
    LDA #$00            ; Dummy pass val
    LDX #$00
    JSR CHECK_RESULT    ; Pass
    JMP TEST_SP
STACK_X_FAIL:
    TXA                 ; Put bad value in A
    LDX #$BB            ; Expected
    JSR CHECK_RESULT    ; Fail

    ; --- SP MOVEMENT ---
TEST_SP:
    JSR PRINT_INLINE
    .asciiz "    SP MOVEMENT: "
    LDX #$FF
    TXS                 ; SP = FF
    LDA #$00
    PHA                 ; Push (SP should be FE)
    TSX                 ; Transfer SP to X
    TXA                 ; Move to A for check
    LDX #$FE            ; Expected $FE
    JSR CHECK_RESULT

    ; ==========================================================================
    ; MONITOR LOGIC TESTS
    ; ==========================================================================
    JSR PRINT_INLINE
    .asciiz "\r\nMONITOR LOGIC:\r\n"

    ; Note: These tests call the main IS_HEX subroutine.
    ; Ensure you have deleted the duplicate IS_HEX_TEST function 
    ; at the bottom of your file to avoid conflicts.

    ; --- IS_HEX('0') ---
    JSR PRINT_INLINE
    .asciiz "    IS_HEX('0'): "
    LDA #$30            ; Input '0'
    JSR IS_HEX          ; Convert
    LDX #$00            ; Expect Value $00
    JSR CHECK_RESULT

    ; --- IS_HEX('9') ---
    JSR PRINT_INLINE
    .asciiz "    IS_HEX('9'): "
    LDA #$39            ; Input '9'
    JSR IS_HEX
    LDX #$09            ; Expect Value $09
    JSR CHECK_RESULT

    ; --- IS_HEX('A') ---
    JSR PRINT_INLINE
    .asciiz "    IS_HEX('A'): "
    LDA #$41            ; Input 'A'
    JSR IS_HEX
    LDX #$0A            ; Expect Value $0A
    JSR CHECK_RESULT

    ; --- IS_HEX('F') ---
    JSR PRINT_INLINE
    .asciiz "    IS_HEX('F'): "
    LDA #$46            ; Input 'F'
    JSR IS_HEX
    LDX #$0F            ; Expect Value $0F
    JSR CHECK_RESULT

    ; --- IS_HEX('G') (Invalid Test) ---
    ; Optional: Check that G ($47) fails validation
    ; Note: CHECK_RESULT checks A, but IS_HEX indicates failure via Carry flag.
    ; If IS_HEX fails, it returns the original char ($47).
    JSR PRINT_INLINE
    .asciiz "    IS_HEX('G'): "
    LDA #$47            ; Input 'G'
    JSR IS_HEX
    LDX #$47            ; Expect original char (unchanged)
    JSR CHECK_RESULT

    JSR PRINT_INLINE
    .asciiz "FAKE TEST CHECK (SHOULD FAIL): "
    LDA #$00            ; Input 'G'
    JSR IS_HEX
    LDX #$3F            ; Expect original char (unchanged)
    JSR CHECK_RESULT

DONE_LOOP:
    JSR PRINT_NEWLINE
    JSR PRINT_INLINE
    .asciiz "\r\nTESTS COMPLETE.\r\n"
    JMP PROMPT

; --- GENERIC INLINE PRINT ---
PRINT_INLINE:
    PLA
    STA PTR_L
    PLA
    STA PTR_H
PR_LOOP:
    LDY #$00
    LDA (PTR_L), Y      ; Read character
    BEQ PR_EXIT         ; If NULL, we are done
    JSR UART_TX         ; Print it
    INC PTR_L
    BNE PR_LOOP
    INC PTR_H
    JMP PR_LOOP
PR_EXIT:
    INC PTR_L
    BNE PR_PUSH_RET
    INC PTR_H
PR_PUSH_RET:
    LDA PTR_H
    PHA
    LDA PTR_L
    PHA
    RTS

; --- CHECK RESULT (INVERTED LOGIC) ---
; This version forces a jump to PASS. If the jump fails, it prints ERROR.
CHECK_RESULT:
    STX VAL_EXP
    STA VAL_GOT
    
    CMP VAL_EXP     ; Compare A (Actual) with Memory (Expected)
    BEQ CHECK_PASS  ; Branch if EQUAL (Z=1) to the Pass routine
    
    ; --- FALL THROUGH TO ERROR ---
    ; If we are here, A != X (or the Branch instruction failed)
    JSR PRINT_INLINE
    .asciiz "FAIL (EXP:$"
    
    LDA VAL_EXP
    JSR PRBYTE
    
    JSR PRINT_INLINE
    .asciiz " GOT:$"
    
    LDA VAL_GOT
    JSR PRBYTE
    
    JSR PRINT_INLINE
    .asciiz ")\r\n"
    RTS

CHECK_PASS:
    JSR PRINT_INLINE
    .asciiz "PASS\r\n"
    RTS

PRINT_NEWLINE:
    LDA #$0D
    JSR ECHO
    LDA #$0A
    JSR ECHO
    RTS

.org $FFFA
    .word $0F00
    .word RESET
    .word $0000