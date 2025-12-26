# CTI-8 Microprocessor
My final project for CEC 330. An 8-bit CISC CPU inspired by the 65C02 and SPC700 written in Verilog using Vivado (2018.3)

## Includes
- The processor
- An assembler (Including Grammar and the list of Opcodes)
- An example program in assembly and the compiled .coe file
- 32 kB of program ROM ($8000-$FFFF)
- 16 kB of RAM ($0000-$3FFF)
- Keyboard and Terminal UART ($6000-$6002)

Note: Generated IP's such as the clock and memory are not included. Comments include how to generate them.

## Stats
- 8-bit Accumulator
- 16-bit Address Space
- Two 8-bit Index Registers (X and Y)
- 16-bit Program Counter
- Stack Pointer
- Direct Page
- 70 unique instructions, 182 valid opcodes
- 8-bit flags register

### Processor Flags
- Bit 0: Carry (C)
- Bit 1: Zero (Z)
- Bit 2: Interrupt Disable (I)
- Bit 3: Direct Page Enable (D)
- Bit 4: Unused
- Bit 5: Half Carry (H)
- Bit 6: Overflow (V)
- Bit 7: Negative (N)

## Block diagram of the architecture
<img width="2820" height="1760" alt="CTI-8 Processor (1)" src="https://github.com/user-attachments/assets/eba6a2ff-77c5-4729-b555-d1556d2b0473" />

### Known issues
- NMI does not work (However, nothing can trigger a NMI in this project)
