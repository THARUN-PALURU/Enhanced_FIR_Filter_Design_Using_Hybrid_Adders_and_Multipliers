# Enhanced FIR Filter Design Using Hybrid Adders and Multipliers


This repository presents the complete source files, documentation, and analysis reports for the project titled **"Enhanced FIR Filter Design Using Hybrid Adders and Multipliers"**. The project focuses on designing an optimized 16-tap Finite Impulse Response (FIR) filter architecture of input size of 16-bit using novel hybrid arithmetic units, aiming to achieve high performance in terms of power, delay, and Power-Delay Product (PDP) for real-time Digital Signal Processing (DSP) applications using Verilog.
This project is my B.Tech final year major project.

The core innovation of this project lies in two key components:
1.  A **custom 32-bit Hybrid Adder (LKSA)**, which intelligently combines a 16-bit Ling adder with a 16-bit Sparse Kogge-Stone Adder (SKSA) and incorporates an enable logic for dynamic power management.
2.  A **16-bit Hybrid Multiplier** that leverages an advanced 4-chain tree-based partial product addition technique to accelerate computation.

---


## 🔍 Project Motivation & Overview

Finite Impulse Response (FIR) filters are fundamental building blocks in DSP for various applications, including audio processing, image filtering, telecommunications, and biomedical devices. Their inherent stability and linear phase characteristics minimize signal distortion and ensure high precision.

However, traditional FIR filter designs, relying on standard adders and multipliers, often face significant challenges that hinder their deployment in energy-sensitive or high-speed applications. These limitations include:

* **High Power Consumption:** Due to computationally intensive convolution operations involving numerous multiplications and additions.
* **Large Propagation Delay:** Limiting their applicability in high-speed, real-time systems.

These limitations hinder their deployment in real-world applications such as:

* ECG filtering in wearable biomedical devices
* Image and speech processing
* Wireless communication systems

This project directly addresses these challenges by proposing and implementing an **Enhanced FIR Filter architecture** that seamlessly integrates custom-designed, optimized hybrid arithmetic units. All designs were implemented in **Verilog HDL** and synthesized using **Xilinx Vivado 2024.1**. Functional simulation was performed, and detailed performance metrics were extracted using Vivado's synthesis and implementation tools.

---

## ⚙️ Deep Dive into Design Methodology

Our approach involves a hierarchical design, optimizing the fundamental arithmetic operations before integrating them into the larger FIR filter structure.

### 1. Proposed Hybrid Adder (32-bit LKSA)

The 32-bit Hybrid Adder, creatively referred to as the **LSKSA**, is a novel design that ingeniously couples a Sparse Kogge-Stone Adder (SKSA) and a Ling Adder for both speed and power efficiency.

* **Input Splitting:** It takes a 32-bit input and intelligently splits it into two 16-bit segments.
* **Upper 16-bit Computation (SKSA):** The upper 16 bits are processed by a **Sparse Kogge-Stone Adder**. The SKSA is chosen for its efficiency in propagating carries due to its reduced node, sparser prefix tree and fewer interconnects, maximizing parallelism and minimizing logic depth, leading to low delay.
* **Lower 16-bit Computation (Ling Adder):** The lower 16 bits are calculated with a **Ling Adder**. The Ling adder modifies traditional generate (Gi) and propagate (Pi) signals into new signals (Hi, Di, Si), simplifying carry computation and reducing logic depth, which is meant to be power efficient by minimizing switching power.
* **Carry Propagation:** A carry bit travels between the two adder circuits to ensure correct summation.
* **Enable Signal:** An **Enable signal** is introduced to control each block. This mechanism helps in minimizing dynamic power consumption by reducing unnecessary switching activity, a technique also known as Power Gating or Power Isolation.

This partitioning scheme and the integration of an enable signal make for an optimal speed-power trade-off, crucial for high-speed VLSI designs and DSP systems. It achieved a PDP improvement of **45.64%** compared to a conventional 32-bit Ling adder.

### 2. Proposed Hybrid Multiplier (16-bit, 4-Chain)

The proposed 16-bit Hybrid Multiplier architecture intelligently combines multiplication and addition operations to offer both speed improvements and reduced power consumption.

* **Partial Product Summation:** Partial products generated from the two 16-bit inputs are efficiently summed using **four parallel chains of hybrid adders proposed in the adder section** in a tree-based structure.
* **Tree-based Structure:** This 4-chain tree approach divides the 16 partial products into four parallel groups, with each group undergoing serial (ripple) addition initially. The results are then combined in subsequent stages, leading to a faster and more balanced accumulation process.
* **Throughput & Delay:** The tree-based structure significantly improves throughput and ensures a balanced delay across the multiplier, maintaining high performance.
* **Performance:** Reduces PDP by **41.53%** over the conventional 16-bit Vedic multiplier.

### 3. Proposed Optimized 16-Tap FIR Filter

The project culminates in the design of a **16-tap FIR Filter** that seamlessly integrates the optimized 32-bit Hybrid LKSA Adder and the 16-bit Hybrid Multiplier. This integrated design ensures that the benefits of the optimized arithmetic units are fully realized at the system level, leading to a high-performance and low-power FIR filter suitable for demanding DSP applications.

* **Coefficient Integration:** Multiplies input data with 16 symmetric coefficients to achieve specific filter characteristics (e.g., low-pass).
* **Power Optimization:** Incorporates **enable-controlled delay elements** to suppress spurious switching activity, contributing significantly to overall power reduction (part of the SPSE technique).
* **Timing Closure:** Supports timing closure at **33.333 MHz (30 ns)** with only **0.075W** estimated power consumption, making it suitable for real-time applications.
* **Performance:** Reduces power-delay product by **85.87%** compared to traditional FIR filters using direct arithmetic.

---


## 📊 Performance Summary

The comprehensive analysis using Xilinx Vivado demonstrates the superior performance of the proposed hybrid designs compared to conventional architectures across various metrics.

| Component | Metric | Conventional Design | Proposed Hybrid Design Improvement |
| :--------------------------- | :-------------------- | :------------------------ | :------------------------- |
| **16-bit Adders** | Power Consumption | Ling adder | 25.79% ↓ |
| | Delay | Ling adder | 6.797% ↓ |
| | Power delay product | Ling adder | 30.836% ↓ |
| **32-bit Adder** | Power Consumption | Ling adder | 33.63% ↓ |
| | Delay | Ling adder | 18.6% ↓ |
| | Power delay product | Ling adder | 45.64% ↓ |
| | Power Consumption | Sparse Kogge–Stone adder | 33.63% ↓ |
| | Delay | Sparse Kogge–Stone adder | 15.36% ↓ |
| | Power delay product | Sparse Kogge–Stone adder | 43.82% ↓ |
| **16-bit Multiplier** | Power Consumption | Vedic Multiplier | 62.415% ↓ |
| | Power Consumption | Wallace Tree Multiplier | 69.192% ↓ |
| **16-bit 16 tap FIR Filter** | Power Consumption | Arithmetic Operators | 83.82% ↓ |
| | Delay | Arithmetic Operators | 12.721% ↓ |
| | Power-Delay Product (PDP) | Arithmetic Operators | 85.87% ↓ |

The proposed hybrid designs consistently outperform conventional architectures, demonstrating significant improvements across power, delay, and Power-Delay Product (PDP) as validated through Xilinx Vivado. These compelling results underscore the effectiveness of the proposed hybrid approach in achieving superior performance metrics critical for modern DSP applications demanding low power and high speed.

---

## 🛠️ Tools Used

* **Xilinx Vivado 2024.1:** The primary Electronic Design Automation (EDA) tool used for RTL synthesis, functional and timing simulation, and power analysis.
* **Verilog HDL:** The hardware description language employed for modeling all digital circuits (both behavioral and structural).

---

## 🧪 Simulation & Validation

* **Functional Correctness:** Verified rigorously through extensive Verilog testbenches designed for each component and the overall FIR filter.
* **Waveform Analysis:** XSIM (the Vivado simulator) was utilized for detailed waveform analysis to confirm the expected behavior and timing of the digital circuits.
* **Performance Metrics:** All reported performance metrics (power, delay, PDP) are based on post-synthesis reports generated by Xilinx Vivado.   

## 🚫 Disclaimer on Power Analysis 
* Power values were estimated using Vivado's internal tools with default toggling assumptions and without full pin constraints or `.saif` switching activity files. These results serve as relative performance indicators and may vary with post-implementation simulation under actual operational conditions. 
---

## 👨‍💻 Contributors

* ### PALURU THARUN - Team Lead
* **N. Srinivasa Naidu** - Project Guide
* **P. Rohan Kumar Raju**
* **K. Himakar**
* **L. Sanjay**
---

## 📄 License

This project is licensed under the **MIT License**.

MIT License

Copyright (c) 2025 THARUN PALURU

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

