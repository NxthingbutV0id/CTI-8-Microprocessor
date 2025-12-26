import sys
import os
import re
import argparse

# --- Constants & Definitions ---

# Addressing Modes
ADDR_IMP = 'IMP'   # Implied
ADDR_IMM = 'IMM'   # Immediate #$00
ADDR_REL = 'REL'   # Relative (Branch)
ADDR_DP = 'DP'     # Direct Page $00
ADDR_DPX = 'DPX'   # Direct Page, X $00,X
ADDR_DPY = 'DPY'   # Direct Page, Y $00,Y
ADDR_ABS = 'ABS'   # Absolute $0000
ADDR_ABSX = 'ABSX' # Absolute, X $0000,X
ADDR_ABSY = 'ABSY' # Absolute, Y $0000,Y
ADDR_IND = 'IND'   # Indirect ($0000) - JMP only usually
ADDR_DPXI = 'DPXI' # Indexed Indirect ($00,X)
ADDR_DPIY = 'DPIY' # Indirect Indexed ($00),Y
ADDR_ABSI = 'ABSI' # Absolute Indirect ($0000) - JMP
ADDR_ABSXI = 'ABSXI' # Absolute Indexed Indirect ($0000,X) - JMP

OPCODES = {}

INVERSE_BRANCH = {
    'BNE': 'BEQ', 'BEQ': 'BNE',
    'BCC': 'BCS', 'BCS': 'BCC',
    'BMI': 'BPL', 'BPL': 'BMI',
    'BVC': 'BVS', 'BVS': 'BVC',
}

def load_opcodes(filepath):
    global OPCODES
    if not os.path.exists(filepath):
        print(f"Error: Opcode mapping file not found at {filepath}")
        sys.exit(1)
        
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('ADDRESSING') or line.startswith('If') or line.startswith('OPCODES'):
                continue
            
            if '=' in line:
                parts = line.split('=')
                key = parts[0].strip()
                val_str = parts[1].strip()
                
                if val_str.startswith('$'):
                    try:
                        opcode_val = int(val_str[1:], 16)
                    except ValueError:
                        continue
                else:
                    continue 
                
                if '_' in key:
                    mnemonic = key
                    mode = ADDR_IMP
                    suffixes = {
                        '_DP': ADDR_DP, '_DPX': ADDR_DPX, '_DPY': ADDR_DPY,
                        '_ABS': ADDR_ABS, '_ABSX': ADDR_ABSX, '_ABSY': ADDR_ABSY,
                        '_IMM': ADDR_IMM, '_REL': ADDR_REL,
                        '_DPXI': ADDR_DPXI, '_DPIY': ADDR_DPIY,
                        '_ABSI': ADDR_ABSI, '_ABSXI': ADDR_ABSXI,
                        '_A': ADDR_IMP 
                    }
                    found_suffix = False
                    for suffix, m in suffixes.items():
                        if key.endswith(suffix):
                            mnemonic = key[:-len(suffix)]
                            mode = m
                            found_suffix = True
                            break
                    if not found_suffix:
                        mnemonic = key
                        mode = ADDR_IMP
                else:
                    mnemonic = key
                    mode = ADDR_IMP
                
                if mnemonic not in OPCODES:
                    OPCODES[mnemonic] = {}
                OPCODES[mnemonic][mode] = opcode_val

class Instruction:
    def __init__(self, label, mnemonic, operand, line_num):
        self.label = label
        self.mnemonic = mnemonic
        self.operand = operand
        self.line_num = line_num
        self.address = 0
        self.length = 0
        self.mode = None
        self.is_expanded = False # If True, this branch is expanded to Inverse + JMP

class Assembler:
    def __init__(self):
        self.instructions = [] # List of Instruction objects
        self.labels = {} # Label -> Address
        self.constants = {} # Name -> Value
        self.memory = {} # Address -> Byte
        self.pc = 0x8000 
        
    def parse_line(self, line):
        if ';' in line:
            line = line.split(';', 1)[0]
        line = line.strip()
        if not line:
            return None, None, None, None
            
        label = None
        # Check for label, but ignore if inside quotes
        if ':' in line:
            in_quote = False
            found_colon = False
            colon_idx = -1
            for i, char in enumerate(line):
                if char == '"':
                    in_quote = not in_quote
                elif char == ':' and not in_quote:
                    found_colon = True
                    colon_idx = i
                    break
            
            if found_colon:
                label = line[:colon_idx].strip()
                line = line[colon_idx+1:].strip()
            
        if not line:
            return label, None, None, None
            
        # Check for assignment, but ignore if inside quotes (for .asciiz)
        # Also, if we already have a label, the assignment name is the mnemonic? 
        # No, usually assignments are "NAME = VALUE". 
        # If we have "LABEL: NAME = VALUE", then LABEL is the label, NAME is the mnemonic (sort of), = is operand?
        # But here we have ".asciiz ... = ...".
        
        is_assignment = False
        if '=' in line:
            # Check if = is inside quotes
            in_quote = False
            found_eq = False
            for char in line:
                if char == '"':
                    in_quote = not in_quote
                elif char == '=' and not in_quote:
                    found_eq = True
                    break
            
            if found_eq:
                parts = line.split('=')
                name = parts[0].strip()
                val = parts[1].strip()
                # If we already had a label from ':', then 'name' is actually the instruction/variable being assigned?
                # But usually assignments don't have a colon label.
                # If they do, e.g. "LBL: VAR = 10", then label is LBL.
                # But the current return signature is label, mnemonic, operand.
                # For assignment, mnemonic is '='.
                # If we return name as label, we lose LBL.
                # If label is set, we should probably keep it.
                if label:
                    # Treat "VAR = 10" as mnemonic="VAR", operand="= 10"? 
                    # Or mnemonic="=", operand="10", and label is "LBL"?
                    # But the assembler expects mnemonic "=" to handle assignment.
                    # The assignment handling in resolve_addresses uses instr.label as the name to assign to.
                    # So "VAR = 10" -> label="VAR", mnemonic="=", operand="10".
                    # If we have "LBL: VAR = 10", that's ambiguous or invalid in this simple assembler.
                    # We will assume assignments don't have colon labels, OR we ignore the colon label if it's an assignment.
                    # BUT, for .asciiz "...", we MUST NOT treat it as assignment.
                    pass 
                else:
                    return name, '=', val, None
            
        parts = line.split(None, 1)
        mnemonic = parts[0].upper()
        operand = parts[1].strip() if len(parts) > 1 else None
        
        return label, mnemonic, operand, None

    def evaluate(self, expr):
        if expr is None: return 0
        
        def parse_term(term):
            term = term.strip()
            if not term: return 0
            if term == 'X' or term == 'Y' or term == 'A': return 0 
            
            if term.startswith('$'):
                try: return int(term[1:], 16)
                except ValueError: return 0
            elif term.startswith('%'):
                try: return int(term[1:], 2)
                except ValueError: return 0
            elif term.isdigit():
                return int(term)
            elif term in self.constants:
                return self.constants[term]
            elif term in self.labels:
                return self.labels[term]
            else:
                return None 

        tokens = re.split(r'([+\-])', expr)
        total = 0
        current_op = '+'
        for token in tokens:
            token = token.strip()
            if not token: continue
            if token in ('+', '-'):
                current_op = token
            else:
                val = parse_term(token)
                if val is None: return None
                if current_op == '+': total += val
                elif current_op == '-': total -= val
        return total

    def get_mode(self, mnemonic, operand):
        if operand is None: return ADDR_IMP, 1
        if operand.startswith('#'): return ADDR_IMM, 2
        if operand.startswith('('):
            if ', X)' in operand.upper() or ',X)' in operand.upper():
                if mnemonic == 'JMP': return ADDR_ABSXI, 3
                return ADDR_DPXI, 2
            elif '), Y' in operand.upper() or '),Y' in operand.upper():
                return ADDR_DPIY, 2
            elif operand.endswith(')'):
                if mnemonic == 'JMP': return ADDR_ABSI, 3
                return ADDR_IND, 3 
        
        if ', X' in operand.upper() or ',X' in operand.upper():
            val = self.evaluate(operand.split(',')[0])
            if val is not None and val <= 0xFF: return ADDR_DPX, 2
            return ADDR_ABSX, 3
        if ', Y' in operand.upper() or ',Y' in operand.upper():
            val = self.evaluate(operand.split(',')[0])
            if val is not None and val <= 0xFF: return ADDR_DPY, 2
            return ADDR_ABSY, 3
            
        if mnemonic in ['BNE', 'BEQ', 'BCC', 'BCS', 'BMI', 'BPL', 'BVC', 'BVS', 'BRA']:
            return ADDR_REL, 2
            
        val = self.evaluate(operand)
        if val is not None and val <= 0xFF: return ADDR_DP, 2
        return ADDR_ABS, 3

    def parse_file(self, filepath):
        with open(filepath, 'r') as f:
            lines = f.readlines()
        
        for i, line in enumerate(lines):
            label, mnemonic, operand, _ = self.parse_line(line)
            if label or mnemonic:
                self.instructions.append(Instruction(label, mnemonic, operand, i+1))

    def resolve_addresses(self):
        self.pc = 0x8000
        self.labels = {} # Reset labels
        
        # First pass to set constants and initial labels
        # We need to do this because get_mode might depend on constants
        for instr in self.instructions:
            if instr.label:
                self.labels[instr.label] = self.pc
            
            if not instr.mnemonic:
                continue
                
            if instr.mnemonic == '=':
                val = self.evaluate(instr.operand)
                if val is not None:
                    self.constants[instr.label] = val
                else:
                    print(f"Error: Invalid expression for constant {instr.label}")
                continue
                
            if instr.mnemonic.startswith('.'):
                if instr.mnemonic.upper() == '.ORG':
                    val = self.evaluate(instr.operand)
                    if val is not None:
                        self.pc = val
                elif instr.mnemonic.upper() == '.WORD':
                    instr.address = self.pc
                    self.pc += 2
                elif instr.mnemonic.upper() == '.ASCIIZ':
                    instr.address = self.pc
                    # Calculate length: sum of string lengths + 1 for null terminator
                    # We need to parse the operand to get the exact bytes length
                    data = self.parse_asciiz_operand(instr.operand)
                    instr.length = len(data)
                    self.pc += instr.length
                continue
            
            # Instruction
            if instr.is_expanded:
                # Expanded branch: Inverse (2) + JMP (3) = 5 bytes
                # Or BRA -> JMP (3 bytes)
                if instr.mnemonic == 'BRA':
                    instr.length = 3
                else:
                    instr.length = 5
            else:
                instr.mode, instr.length = self.get_mode(instr.mnemonic, instr.operand)
            
            instr.address = self.pc
            instr.address = self.pc
            self.pc += instr.length

    def parse_asciiz_operand(self, operand):
        """
        Parses a .asciiz operand string like '"Hello", " World"'
        Returns a list of bytes including the trailing zero.
        Supports escape sequences: \\r, \\n, \\t, \\", \\\\
        """
        if not operand:
            return [0]
            
        data = []
        in_string = False
        escape = False
        
        for char in operand:
            if in_string:
                if escape:
                    if char == 'r': data.append(0x0D)
                    elif char == 'n': data.append(0x0A)
                    elif char == 't': data.append(0x09)
                    elif char == '"': data.append(0x22)
                    elif char == '\\': data.append(0x5C)
                    else: data.append(ord(char)) # Unknown escape, just take char
                    escape = False
                elif char == '\\':
                    escape = True
                elif char == '"':
                    in_string = False
                else:
                    data.append(ord(char))
            else:
                if char == '"':
                    in_string = True
            
        data.append(0) # Null terminator
        return data

    def relax_branches(self):
        changed = False
        for instr in self.instructions:
            if instr.mnemonic in ['BNE', 'BEQ', 'BCC', 'BCS', 'BMI', 'BPL', 'BVC', 'BVS', 'BRA']:
                if instr.is_expanded:
                    continue
                
                # Check range
                target = self.evaluate(instr.operand)
                if target is None: continue # Can't check yet
                
                offset = target - (instr.address + 2)
                if offset < -128 or offset > 127:
                    # Needs expansion
                    instr.is_expanded = True
                    changed = True
        return changed

    def assemble(self):
        # Iterative relaxation
        max_iters = 20
        for _ in range(max_iters):
            self.resolve_addresses()
            if not self.relax_branches():
                break
        else:
            print("Error: Branch relaxation did not converge.")
            sys.exit(1)
            
        # Generate Code
        self.memory = {}
        for instr in self.instructions:
            if not instr.mnemonic or instr.mnemonic == '=':
                continue
                
            self.pc = instr.address
            
            if instr.mnemonic.startswith('.'):
                if instr.mnemonic.upper() == '.WORD':
                    val = self.evaluate(instr.operand)
                    print(f".WORD ${val:04X} at ${self.pc:04X}") # PC is zero?
                    if val is None: 
                        print(f"Error: Invalid operand '{clean_operand}'")
                        sys.exit(1)
                    self.memory[self.pc] = val & 0xFF
                    self.memory[self.pc + 1] = (val >> 8) & 0xFF
                elif instr.mnemonic.upper() == '.ASCIIZ':
                    data = self.parse_asciiz_operand(instr.operand)
                    for i, byte in enumerate(data):
                        self.memory[self.pc + i] = byte
                continue
                
            # Instruction
            if instr.is_expanded:
                target = self.evaluate(instr.operand)
                if instr.mnemonic == 'BRA':
                    # BRA -> JMP Absolute
                    opcode_val = OPCODES['JMP'][ADDR_ABS]
                    self.memory[self.pc] = opcode_val
                    self.memory[self.pc + 1] = target & 0xFF
                    self.memory[self.pc + 2] = (target >> 8) & 0xFF
                else:
                    # Conditional -> Inverse Branch + JMP
                    inverse_mnemonic = INVERSE_BRANCH[instr.mnemonic]
                    inverse_opcode = OPCODES[inverse_mnemonic][ADDR_REL]
                    
                    # Inverse branch skips the JMP (3 bytes)
                    # Offset = +3
                    self.memory[self.pc] = inverse_opcode
                    self.memory[self.pc + 1] = 3
                    
                    # JMP Target
                    jmp_opcode = OPCODES['JMP'][ADDR_ABS]
                    self.memory[self.pc + 2] = jmp_opcode
                    self.memory[self.pc + 3] = target & 0xFF
                    self.memory[self.pc + 4] = (target >> 8) & 0xFF
            else:
                if instr.mnemonic not in OPCODES:
                    print(f"Error: Unknown mnemonic '{instr.mnemonic}' at line {instr.line_num}")
                    sys.exit(1)
                    
                # Re-check mode just in case (though resolve_addresses did it)
                # We trust resolve_addresses mode unless it was unknown then
                if instr.mode is None:
                     instr.mode, _ = self.get_mode(instr.mnemonic, instr.operand)
                     
                opcode_val = OPCODES[instr.mnemonic][instr.mode]
                self.memory[self.pc] = opcode_val
                
                if instr.length > 1:
                    clean_operand = instr.operand.split(',')[0].replace('(', '').replace(')', '').replace('#', '')
                    val = self.evaluate(clean_operand)
                    if val is None:
                        print(f"Error: Invalid operand '{clean_operand}'")
                        sys.exit(1)
                    if instr.mode == ADDR_REL:
                        offset = val - (self.pc + 2)
                        self.memory[self.pc + 1] = offset & 0xFF
                    elif instr.length == 2:
                        self.memory[self.pc + 1] = val & 0xFF
                    elif instr.length == 3:
                        self.memory[self.pc + 1] = val & 0xFF
                        self.memory[self.pc + 2] = (val >> 8) & 0xFF

    def write_coe(self, output_path):
        with open(output_path, 'w') as f:
            f.write("memory_initialization_radix=16;\n")
            f.write("memory_initialization_vector=")
            lines = []
            for addr in range(0x8000, 0x10000):
                byte = self.memory.get(addr, 0x00)
                lines.append(f"{byte:02X}")
            content = ",".join(lines)
            f.write(content + ";")

    def hexdump(self):
        WIDTH = 16
        state = 'NORMAL'
        machine_code = []
        for j in range(0x8000, 0x10000):
            machine_code.append(self.memory.get(j, 0x00))
        
        for i in range(0, len(machine_code), WIDTH):
            chunk = machine_code[i : i + WIDTH]
            current_address = i + 0x8000
            
            # Check if the current row consists entirely of zeros
            is_zero_row = all(b == 0 for b in chunk)
            

            if not is_zero_row:
                # Always print non-zero rows
                self._print_row(current_address, chunk)
                state = 'NORMAL'    
            else:
                # It is a zero row
                if state == 'NORMAL':
                    self._print_row(current_address, chunk)
                    state = 'ZERO_ROW_PRINTED'
                    
                elif state == 'ZERO_ROW_PRINTED':
                    print(f"{current_address:04X}: *")
                    state = 'STAR_PRINTED'
                    
                elif state == 'STAR_PRINTED':
                    pass

    def _print_row(self, address, chunk):
        hex_bytes = " ".join(f"{b:02X}" for b in chunk)
        print(f"{address:04X}: {hex_bytes}")

if __name__ == "__main__":
    #parser = argparse.ArgumentParser(description="Custom Assembler")
    #parser.add_argument("input", help="Input .s file")
    #parser.add_argument("output", help="Output .coe file")
    #parser.add_argument("--opcodes", help="Opcode mapping file", default="extra/OpcodeMapping.txt")

    # Edit input and output files here
    input_file = r"extra\wozmon.s"
    output_file = r"extra\wozmon.coe"


    opcodes_file = r"extra\OpcodeMapping.txt"
    
    #args = parser.parse_args()
    
    load_opcodes(opcodes_file)
    
    asm = Assembler()
    asm.parse_file(input_file)
    asm.assemble()
    asm.hexdump()
    asm.write_coe(output_file)
    print(f"Assembly complete. Output written to {output_file}")

