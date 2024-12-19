# Simple GPU in Verilog

A simple prototypical GPU design in Verilog to illustrate its basic operations. For use in Cooper Union's ECE251 Computer Architecture course.

# Architecture

This prototypical GPU design has the following components:

1. Processing Element (PE): This module performs arithmetic operations. Hence, we will use a simple ALU.
2. Memory: A limited on-chip memory to store data for the GPU
3. Control Unit: Like in CPU designs, the control unit fetches from memory the instructions and data upon which to operate. The control unit then dispatches these to each PE.
4. Input / Output (I/O): I/O interfaces between the GPU and a higher controlling system (like a CPU) to receive instructions and data and to send the GPU's output.

# Instruction Set

The following will be the instruction set for the GPU:

- `0001` : ADD &mdash; add two integers, e.g., `ADD A B C` C = A+B
- `1001` : ADDI &mdash; add two integers, ADD A B C <- A = B (reg) + C (imm)
- `0010` : SUB &mdash; subtract two integers, e.g., `SUB A B C` C = A-B
- `0011` : MUL &mdash; multiply two integers, e.g., `MUL A B C` C = A\*B
- `0100` : LOAD &mdash; load data from memory, e.g., `LOAD A B` B = mem(A); A is source addr and has 12 bits; B is destination register and has 4 bits.
- `0101` : STORE &mdash; store data to memory, e.g., `STORE A B` mem(A) = B; A is destination addr and has 12 bits; B is source register and has 4 bits.

## Instruction Format

`[31:28]  [27:24]  [23:20]  [19:16]  [15:12]  [11:0]`
16 registers each of 32 bits

| Bits    | Description |
| ------- | ----------- |
| [31:28] | Opcode      |
| [27:24] | Src Reg1    |
| [23:20] | Src Reg2    |
| [19:16] | Dest Reg    |
| [15:12] | (optional)  |
| [11:0]  | (unused)    |

\*\* Add immediate value calculations, like ADDI, SUBI, MULI

# Verilog Modules

- (top-level, test bench) `tb_simple_gpu.sv`
- `simple_gpu.sv`
- `memory_controller.sv`
- `my_utils.sv`
