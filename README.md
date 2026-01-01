# ARM Assembly ALU (Arithmetic Logic Unit)

This repository contains a **fully functional ALU implemented in ARM Assembly**, designed for educational purposes and embedded systems projects. The ALU supports arithmetic, logical, shift/rotate, multiplication, comparison, and parity operations, with results and flags stored in memory for debugging.

---

## Features

- **Arithmetic Operations**  
  - ADD, SUB, INC, DEC  
  - ADC (Add with Carry), SBB (Subtract with Borrow)  

- **Logical Operations**  
  - AND, OR, XOR, NOT, NAND, NOR  

- **Shift & Rotate Operations**  
  - LSL, LSR, ASL, ASR  
  - ROL, ROR  
  - Barrel Shifter  

- **Multiplication**  
  - Booth Multiplication

- **Comparison Operations**  
  - Outputs: Greater than, Equal, Less than  

- **Parity Check**  
  - Checks if a value is even or odd  

- **Flags Handling**  
  - APSR flags updated automatically  
  - Results stored in memory for inspection  

---

## How to Use

1. Open the project in **Keil MDK** (Cortex ARM M4)  
2. Modify registers `A`, `B`, and `OPCODE` in the **watch window** to test different operations.  
3. Run `main` loop to execute `ALU_Step` repeatedly.  
4. Inspect **RESULT**, **FLAGS**, and **CMP_OUT** to verify outcomes.  

---

## Opcode Reference

| OPCODE | Operation             |
|--------|---------------------|
| 0      | ADD                 |
| 1      | SUB                 |
| 2      | INC                 |
| 3      | DEC                 |
| 4      | ADC (Add with Carry) |
| 5      | SBB (Subtract Borrow)|
| 6      | AND                 |
| 7      | OR                  |
| 8      | XOR                 |
| 9      | NOT                 |
| 10     | NAND                |
| 11     | NOR                 |
| 12     | LSL                 |
| 13     | LSR                 |
| 14     | ASL                 |
| 15     | ASR                 |
| 16     | ROL                 |
| 17     | ROR                 |
| 18     | Barrel Shift        |
| 19     | Booth Multiply      |
| 20     | Comparator          |
| 21     | Parity Check        |

---

## Video Demonstration

Watch the ALU in action on YouTube:  
[https://youtu.be/6N0yZf5nCdE](https://youtu.be/6N0yZf5nCdE)

---

## License

This project is **open-source** and available under the MIT License. Feel free to modify and use for educational purposes.  
