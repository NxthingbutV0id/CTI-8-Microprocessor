grammar Assembly;
options { caseInsensitive=true; }

program: line+ EOF;
line: labelDef? (assignment | directive | instruction)? COMMENT? NEWLINE;
assignment: IDENTIFIER EQUALS expr;
labelDef: IDENTIFIER COLON;
directive: ORG_DIR expr | WORD_DIR expr (COMMA expr)*;
instruction: opcode operand?;
operand: (immediate | indexedX | indexedY | indexedIndirect | indirectIndexed | indirect | absRel | accumulator);
immediate: HASH expr;
indexedX: expr (COMMA | PLUS) X;
indexedY: expr (COMMA | PLUS) Y;
indexedIndirect: LPAREN expr (COMMA | PLUS) X RPAREN;
indirectIndexed: LPAREN expr RPAREN (COMMA | PLUS) Y;
indirect: LPAREN expr RPAREN;
absRel: expr;
accumulator: A; // Not used: If an instruction has no operands, it is implied, UNLESS the opcode is DEC, INC, ASL, LSR, ROL, or ROR, then it uses the accumulator.

expr: term | expr PLUS term | expr MINUS term;
term: number | identifier;
number: HEX | BIN | DECIMAL;
identifier: IDENTIFIER;


opcode
    : NOP | HLT | WAI
    | ADD | ADC | SUB | SBB
    | AND | ORA | XOR | CMP | CPY | CPX
    | LDA | STA | LDX | STX | LDY | STY | STZ
    | INC | DEC | ASL | LSR | ROL | ROR | INX | DEX | INY | DEY
    | JMP | JSR | RTS | RTI | BRK
    | BNE | BEQ | BCC | BCS | BMI | BPL | BVC | BVS | BRA
    | CLC | SEC | CLI | SEI | CLV | CLD | SED
    | PHA | PLA | PHX | PLX | PHY | PLY | PHF | PLF
    | TAX | TXA | TAY | TYA | TSX | TXS | TDY | TYD
    | BIT
    ;

ORG_DIR: '.org';
WORD_DIR: '.word';

X: 'X';
Y: 'Y';
A: 'A';
COMMA: ',';
COLON: ':';
EQUALS: '=';
PLUS: '+';
MINUS: '-';
HASH: '#';
LPAREN: '(';
RPAREN: ')';

NOP: 'NOP'; // No Operation
HLT: 'HLT'; // Halt
WAI: 'WAI'; // Wait for Interrupt
ADD: 'ADD'; // Addition to Accumulator
ADC: 'ADC'; // Add with Carry to Accumulator
SUB: 'SUB'; // Subtract from Accumulator
SBB: 'SBB'; // Subtract with Borrow from Accumulator
AND: 'AND'; // Logical AND with Accumulator
ORA: 'ORA'; // Logical OR with Accumulator
XOR: 'XOR'; // Logical Exclusive OR with Accumulator
CMP: 'CMP'; // Compare Accumulator
CPY: 'CPY'; // Compare Y
CPX: 'CPX'; // Compare X
LDA: 'LDA'; // Load Accumulator
STA: 'STA'; // Store Accumulator
LDX: 'LDX'; // Load X
STX: 'STX'; // Store X
LDY: 'LDY'; // Load Y
STY: 'STY'; // Store Y
STZ: 'STZ'; // Store Zero
INC: 'INC'; // Increment
DEC: 'DEC'; // Decrement
ASL: 'ASL'; // Arithmetic Shift Left
LSR: 'LSR'; // Logical Shift Right
ROL: 'ROL'; // Rotate Left
ROR: 'ROR'; // Rotate Right
INX: 'INX'; // Increment X
DEX: 'DEX'; // Decrement X
INY: 'INY'; // Increment Y
DEY: 'DEY'; // Decrement Y
JMP: 'JMP'; // Jump
JSR: 'JSR'; // Jump to Subroutine
RTS: 'RTS'; // Return from Subroutine
RTI: 'RTI'; // Return from Interrupt
BRK: 'BRK'; // Software Interrupt
BNE: 'BNE'; // Branch if Not Equal
BEQ: 'BEQ'; // Branch if Equal
BCC: 'BCC'; // Branch if Carry Clear
BCS: 'BCS'; // Branch if Carry Set
BMI: 'BMI'; // Branch if Minus
BPL: 'BPL'; // Branch if Plus
BVC: 'BVC'; // Branch if Overflow Clear
BVS: 'BVS'; // Branch if Overflow Set
BRA: 'BRA'; // Branch Always
CLC: 'CLC'; // Clear Carry Flag
SEC: 'SEC'; // Set Carry Flag
CLI: 'CLI'; // Enable Interrupts
SEI: 'SEI'; // Disable Interrupts
CLV: 'CLV'; // Clear Overflow Flag
CLD: 'CLD'; // Disable Decimal Mode
SED: 'SED'; // Enable Decimal Mode
PHA: 'PHA'; // Push Accumulator onto Stack
PLA: 'PLA'; // Pull Accumulator from Stack
PHX: 'PHX'; // Push X onto Stack
PLX: 'PLX'; // Pull X from Stack
PHY: 'PHY'; // Push Y onto Stack
PLY: 'PLY'; // Pull Y from Stack
PHF: 'PHF'; // Push Flags onto Stack
PLF: 'PLF'; // Pull Flags from Stack
TAX: 'TAX'; // Transfer Accumulator to X
TXA: 'TXA'; // Transfer X to Accumulator
TAY: 'TAY'; // Transfer Accumulator to Y
TYA: 'TYA'; // Transfer Y to Accumulator
TSX: 'TSX'; // Transfer Stack Pointer to X
TXS: 'TXS'; // Transfer X to Stack Pointer
TDY: 'TDY'; // Transfer Stack Pointer to Y
TYD: 'TYD'; // Transfer Y to Stack Pointer
BIT: 'BIT'; // Bit Test with Accumulator

IDENTIFIER: [a-z_@+-][a-z0-9_@+-]*;
HEX: '$' [0-9a-f]+;
BIN: '%' [01]+;
DECIMAL: [0-9]+;
NEWLINE: [\r\n]+;
WS: [ \t]+ -> skip;
COMMENT: (';') ~[\r\n]* -> skip;