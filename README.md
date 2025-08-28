# ⚡ Parameterized ALU (Arithmetic and Logic Unit)

[![Verilog](https://img.shields.io/badge/HDL-Verilog-blue.svg)](https://en.wikipedia.org/wiki/Verilog)  
[![Simulator](https://img.shields.io/badge/Simulator-QuestaSIM-green.svg)](https://eda.sw.siemens.com/en-US/ic/questa/)  
[![Synth Tool](https://img.shields.io/badge/Synthesis-Vivado-orange.svg)](https://www.xilinx.com/products/design-tools/vivado.html)  

---

## 📌 Project Overview
This project implements a parameterized Arithmetic and Logic Unit (ALU) in Verilog with a default operand width of 8 bits.
The ALU supports a wide range of arithmetic, logical, and special signed operations and is designed for flexibility, scalability, and synthesizability.

### Key highlights:

Parameterized operand width (default: 8 bits)

Logical and arithmetic modes controlled by a mode signal

Single-cycle and multi-cycle latency depending on operation

Verification using a structured self-checking testbench with coverage analysis

---

## 🎯 Objectives
 
- Implement an efficient **synthesizable Parameterized ALU** in Verilog.  
- Apply **linting** to improve quality and maintainability.  
- Verify functionality with **directed, random, and corner-case tests**.  
- Achieve **high code coverage** across all supported operations.  

---

## 🏗️ Design Architecture
- **Inputs**: `clk`, `reset`, `ce`, `opa`, `opb`, `inp_valid`, `mode`, `cmd`   
- **Outputs**: `res`, `cout`, `oflow`, `g/l/e`, `zero`, `err`

## 🏗️ Paramterized ALU Architecture  
<img width="720" height="720" alt="image" src="https://github.com/user-attachments/assets/6da9ab08-2b8c-40d5-8dd7-81a938899d66" />

---

## 🏗️ ALU Testbench Architecture
<img width="720" height="720" alt="image" src="https://github.com/user-attachments/assets/94f53ed7-3842-4463-8666-0061e30bf369" />

### 📑 Stimulus Vector Format for Self-Checking ALU
<img width="720" height="720" alt="image" src="https://github.com/user-attachments/assets/8830bc70-7a62-4534-85ee-8a6a6de8b318" />

---

### Supported Operations
**Unsigned Arithmetic**: ADD, SUB, ADD_CIN, SUB_CIN, INC/DEC, CMP, ADD_MUL, SH_MUL  
**Signed Arithmetic**: SP_1 (signed add + compare), SP_2 (signed sub + compare)  
**Logical**: AND, NAND, OR, NOR, XOR, XNOR, NOT_A, NOT_B, SHL_1,SHR_1, ROL, ROR  

---

## ⏱️ Timing Behaviour
- **1 cycle latency** → Most operations  
- **2 cycle latency** → Multi-cycle ops (e.g., multiplication)  
- Operates synchronously on **posedge clk** with clock enable (`ce`)  

---

## 🧪 Verification & Testbench
The verification environment is modular and **self-checking**, ensuring correctness and traceability.

- **Stimulus file**: `stimulus.txt` (57-bit wide test vectors)  
- **Driver**: Sends inputs and expected results to DUT and Scoreboard  
- **DUT**: ALU RTL implementation  
- **Monitor**: Observes DUT activity  
- **Scoreboard**: Compares actual vs expected, logs into `result.txt`  

✔ 100+ test cases executed (functional + edge + corner cases)  
✔ High **code coverage** achieved (line, branch, toggle)  

---

## ✅ Results
- Verified correct behaviour across all operations  
- Corner cases tested: clock disable, back-to-back MUL/ADD, Invalid CMD for different Mode  
- **Synthesized** using Xilinx Vivado → Clean, hardware-compatible RTL  
- **Simulated** using Questa SIM → Observed waveforms + correctness logs  
- **Scoreboard results** stored in `result.txt`
  
### ALU coverage Report
<img width="895" height="355" alt="image" src="https://github.com/user-attachments/assets/71ebda11-c048-4067-b5c2-ddf2d81f754b" />

---

## 📊 Quality Assurance
- **Linting** → Fixed coding style & synthesis issues  
- **Coverage** → Ensured all CMD cases & logic paths are tested  

---

## 📌 Conclusion
- Successfully designed & verified a **parameterized ALU**  
- Achieved **robust verification** with scoreboard and coverage  
- Clean, scalable RTL → reusable in larger **processor/SoC projects**  

---

## 🚀 Future Work
- ⏩ Add **pipelining** for higher performance  
- 🧾 Apply **formal verification**  
- ⚡ Optimize for **power and area**  
- ➕ Extend support for **new operations**  

---

## 👨‍💻 Author
 **Jason Linus Rodrigues**
 
---  

