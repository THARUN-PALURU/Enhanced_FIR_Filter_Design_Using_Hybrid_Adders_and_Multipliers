# Enhanced FIR Filter Design Using Hybrid Adders and Multipliers

This repository presents the complete source files, documentation, and analysis reports for the project titled **"Enhanced FIR Filter Design Using Hybrid Adders and Multipliers"**. The project focuses on designing an optimized 16-tap Finite Impulse Response (FIR) filter architecture of input size of 16-bit using novel hybrid arithmetic units, aiming to achieve high performance in terms of power, delay, and Power-Delay Product (PDP) for real-time Digital Signal Processing (DSP) applications using Verilog.
The core innovation of this project lies in two key components:
1.  A **custom 32-bit Hybrid Adder (LKSA)**, which intelligently combines a 16-bit Ling adder with a 16-bit Sparse Kogge-Stone Adder (SKSA) and incorporates an enable logic for dynamic power management.
2.  A **16-bit Hybrid Multiplier** that leverages an advanced 4-chain tree-based partial product addition technique to accelerate computation.

---

This project is my B.Tech final year major project.
## 👨‍💻 Contributors

* ***PALURU THARUN*** - Team Lead
* **N. Srinivasa Naidu** - Project Guide
* **P. Rohan Kumar Raju**
* **K. Himakar**
* **L. Sanjay**

---

## 🛠️ Tools Used

* **Xilinx Vivado 2024.1:** The primary Electronic Design Automation (EDA) tool used for RTL synthesis, functional and timing simulation, and power analysis.
* **Verilog HDL:** The hardware description language employed for modeling all digital circuits (both behavioral and structural).
* **GitHub Desktop:** Used for efficient version control and managing the repository's publishing to GitHub.
* **Windows 10:** The operating system environment used for development.

---

## 🔍 🚀 Project Motivation & Overview

Finite Impulse Response (FIR) filters are fundamental building blocks in DSP for various applications, including audio processing, image filtering, telecommunications, and biomedical devices. Their inherent stability and linear phase characteristics minimize signal distortion and ensure high precision.

However, traditional FIR filter designs, relying on standard adders and multipliers, often face significant challenges:
* **High Power Consumption:** Due to computationally intensive convolution operations involving numerous multiplications and additions.
* **Large Propagation Delay:** Limiting their applicability in high-speed, real-time systems.
* **Inefficient Silicon Area Utilization:** Arising from the complexity of conventional arithmetic circuits.

These limitations hinder their deployment in energy-sensitive or high-speed applications such as:

* ECG filtering in wearable biomedical devices
* Image and speech processing
* Wireless communication systems

This project directly addresses these challenges by proposing and implementing:

* A **32-bit Hybrid Adder** composed of a **Ling16 + Sparse Kogge-Stone16 (LKSA)** with intelligent enable logic for dynamic power management.
* A **16-bit Hybrid Multiplier** based on an advanced 4-chain tree architecture using the proposed hybrid adder for accelerated computation.
* An **Enhanced FIR Filter** architecture that seamlessly integrates these custom-designed, optimized arithmetic units.

All designs were implemented in **Verilog HDL** and synthesized using **Xilinx Vivado 2024.1**. Functional simulation was performed, and detailed performance metrics were extracted using Vivado's synthesis and implementation tools.

---

## ⚙️ Deep Dive into Design Methodology


### 🔧 1. Proposed Hybrid Adder (32-bit LKSA)

The 32-bit Hybrid Adder, creatively referred to as the **LSKSA**, is a novel design that ingeniously couples a Sparse Kogge-Stone Adder (SKSA) and a Ling Adder for both speed and power efficiency.

* **Input Splitting:** It takes a 32-bit input and intelligently splits it into two 16-bit segments.
* **Upper 16-bit Computation (SKSA):** The upper 16 bits are processed by a **Sparse Kogge-Stone Adder**. The SKSA is chosen for its efficiency in propagating carries due to its reduced node, sparser prefix tree and fewer interconnects, maximizing parallelism and minimizing logic depth, leading to low delay.
* **Lower 16-bit Computation (Ling Adder):** The lower 16 bits are calculated with a **Ling Adder**. The Ling adder modifies traditional generate (Gi) and propagate (Pi) signals into new signals (Hi, Di, Si), simplifying carry computation and reducing logic depth, which is meant to be power efficient by minimizing switching power.
* **Carry Propagation:** A carry bit travels between the two adder circuits to ensure correct summation.
* **Enable Signal:** An **Enable signal** is introduced to control each block. This mechanism helps in minimizing dynamic power consumption by reducing unnecessary switching activity, a technique also known as Power Gating or Power Isolation.

This partitioning scheme and the integration of an enable signal make for an optimal speed-power trade-off, crucial for high-speed VLSI designs and DSP systems.

* **Combined Strengths:** It leverages the high-speed carry propagation of the Sparse Kogge-Stone Adder (SKSA) for the upper 16 bits, known for its parallelism and minimal logic depth. Simultaneously, it utilizes the power efficiency of the Ling Adder for the lower 16 bits, which simplifies carry computation by modifying traditional generate and propagate signals.
* **Enable-based Logic:** Incorporates an **enable signal** to control each internal block, significantly reducing dynamic power consumption by minimizing unnecessary switching activity (a technique similar to Power Gating or Power Isolation).
* **Performance:** Achieved PDP improvement of **45.64%** compared to a conventional 32-bit Ling adder.

### ✴️ 2. ProposedHybrid Multiplier (16-bit, 4-Chain)

The 32-bit Hybrid Adder, creatively referred to as the **LSKSA**, is a novel design that ingeniously couples a Sparse Kogge-Stone Adder (SKSA) and a Ling Adder for both speed and power efficiency.

* **Input Splitting:** It takes a 32-bit input and intelligently splits it into two 16-bit segments.
* **Upper 16-bit Computation (SKSA):** The upper 16 bits are processed by a **Sparse Kogge-Stone Adder**. The SKSA is chosen for its efficiency in propagating carries due to its reduced node, sparser prefix tree and fewer interconnects, maximizing parallelism and minimizing logic depth, leading to low delay.
* **Lower 16-bit Computation (Ling Adder):** The lower 16 bits are calculated with a **Ling Adder**. The Ling adder modifies traditional generate (Gi) and propagate (Pi) signals into new signals (Hi, Di, Si), simplifying carry computation and reducing logic depth, which is meant to be power efficient by minimizing switching power.
* **Carry Propagation:** A carry bit travels between the two adder circuits to ensure correct summation.
* **Enable Signal:** An **Enable signal** is introduced to control each block. This mechanism helps in minimizing dynamic power consumption by reducing unnecessary switching activity, a technique also known as Power Gating or Power Isolation.

This partitioning scheme and the integration of an enable signal make for an optimal speed-power trade-off, crucial for high-speed VLSI designs and DSP systems.

* **Partial Product Summation:** Partial products generated from the two 16-bit inputs are efficiently summed using **four parallel chains of hybrid adders** in a tree-based structure.
* **Tree-based Structure:** This 4-chain tree approach divides the 16 partial products into four parallel groups, with each group undergoing serial (ripple) addition initially. The results are then combined in subsequent stages, leading to a faster and more balanced accumulation process.
* **Throughput & Delay:** The tree-based structure significantly improves throughput and ensures a balanced delay across the multiplier, maintaining high performance.
* **Performance:** Reduces PDP by **41.53%** over the conventional 16-bit Vedic multiplier.

### 📉 3. Proposed Optimized 16-Tap FIR Filter

The project culminates in the design of a **16-tap FIR Filter** that seamlessly integrates the optimized 32-bit Hybrid LKSA Adder and the 16-bit Hybrid Multiplier.

The culmination of this project is the **16-tap FIR Filter** that integrates both the proposed 32-bit Hybrid LKSA Adder and the 16-bit Hybrid Multiplier.
This integrated design ensures that the benefits of the optimized arithmetic units are fully realized at the system level, leading to a high-performance and low-power FIR filter suitable for demanding DSP applications.

* **Coefficient Integration:** Multiplies input data with 16 symmetric coefficients to achieve specific filter characteristics (e.g., low-pass).
* **Power Optimization:** Incorporates **enable-controlled delay elements** to suppress spurious switching activity, contributing significantly to overall power reduction (part of the SPSE technique).
* **Timing Closure:** Supports timing closure at **33.333 MHz (30 ns)** with only **0.075W** estimated power consumption, making it suitable for real-time applications.
* **Performance:** Reduces power-delay product by **85.87%** compared to traditional FIR filters using direct arithmetic.

---

## 📊 Performance Summary

The comprehensive analysis using Xilinx Vivado demonstrates the superior performance of the proposed hybrid designs compared to conventional architectures across various metrics.

| Component | Metric | Compared To | Improvement |
| :-------------------- | :---------------------- | :-------------------------- | :------------------ |
| **32-bit Adder** | Power | Ling | 33.63% ↓ |
| | Delay | Ling | 18.60% ↓ |
| | Power-Delay Product | Ling | 45.64% ↓ |
| | Power-Delay Product | SKSA | 43.82% ↓ |
| **16-bit Multiplier** | Power | Vedic | 62.41% ↓ |
| | Power-Delay Product | Vedic | 41.53% ↓ |
| | Power-Delay Product | Wallace Tree | 60.25% ↓ |
| **FIR Filter (16-tap)** | Power | FIR (Direct Arithmetic) | 83.82% ↓ |
| | Delay | FIR (Direct Arithmetic) | 12.72% ↓ |
| | Power-Delay Product | FIR (Direct Arithmetic) | 85.87% ↓ |


The proposed hybrid designs consistently outperform conventional architectures, demonstrating significant improvements across power, delay, and Power-Delay Product (PDP) as validated through Xilinx Vivado.

-   **⚡ 32-bit LKSA Hybrid Adder:**
    -   Achieves a **45.64% decrease in Power-Delay Product (PDP)** compared to the 32-bit conventional Ling Adder.
    -   Shows a **43.69% decrease in PDP** compared to the 32-bit conventional Sparse Kogge-Stone Adder.
-   **⚡ 16-bit Hybrid Multiplier:**
    -   Delivers a substantial **41.53% PDP improvement** (reduction) compared to the conventional 16-bit Vedic Multiplier.
    -   Achieves a **62.415% decrease in power dissipation** compared to the standard 16-bit Vedic Multiplier.
-   **⚡ Enhanced 16-tap FIR Filter:**
    -   Realizes an **overall 85.87% reduction in Power-Delay Product (PDP)**.
    -   Achieves **83.82% power consumption reduction**.
    -   Demonstrates a **12.721% delay reduction** relative to a regular FIR filter employing basic arithmetic operations without timing constraints.
    -   Under timing constraints, the optimized design achieves an extra **7.40% power saving, a 33.49% delay saving, and a 38.44% PDP saving** at 33.33 MHz.

These compelling results underscore the effectiveness of the proposed hybrid approach in achieving superior performance metrics critical for modern DSP applications demanding low power and high speed.
---


## 🧪 Simulation & Validation

* **Functional Correctness:** Verified rigorously through extensive Verilog testbenches designed for each component and the overall FIR filter.
* **Waveform Analysis:** XSIM (the Vivado simulator) was utilized for detailed waveform analysis to confirm the expected behavior and timing of the digital circuits.
* **Performance Metrics:** All reported performance metrics (power, delay, PDP) are based on post-synthesis reports generated by Xilinx Vivado.

## 🚫 Disclaimer on Power Analysis
Power values were estimated using Vivado's internal tools with default toggling assumptions and without full pin constraints or `.saif` switching activity files. These results serve as relative performance indicators and may vary with post-implementation simulation under actual operational conditions.

---
## 📁 Project Structure

This repository is meticulously organized to reflect the project's various components, design stages, and documentation. You will find dedicated subfolders for different aspects of the design, such as individual adders, multipliers, the complete FIR filter implementation, and related reports. The folder structure mirrors the arrangement on a local system, ensuring clear navigation and easy access to specific design files.
---
## 🚀 Getting Started

To explore and replicate the results of this project using Xilinx Vivado 2024.1:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/Enhanced-FIR-Filter-Design-Project.git](https://github.com/your-username/Enhanced-FIR-Filter-Design-Project.git)
    ```
    *(Remember to replace `your-username` with your actual GitHub username)*

2.  **Navigate to the project directory:**
    ```bash
    cd Enhanced-FIR-Filter-Design-Project
    ```

3.  **Create a New Vivado Project:**
    * Launch Xilinx Vivado 2024.1.
    * Select `Create Project`.
    * Follow the wizard:
        * Choose a project name and location (outside the cloned repository).
        * Select `RTL Project` and ensure `Do not specify sources at this time` is checked.
        * Select your target FPGA device (e.g., from the Kintex-7 family, if applicable to your paper's results).
    * Click `Finish`.

4.  **Add Design Sources:**
    * In the Vivado `Flow Navigator`, under `Project Manager`, click `Add Sources`.
    * Select `Add or Create Design Sources`.
    * Click `Add Files...` and navigate to your cloned `Enhanced-FIR-Filter-Design-Project` directory.
    * **Crucially, select ALL relevant Verilog (`.v`) files** from the `adders/`, `multipliers16bit/`, `fir_filters/` and any top-level `.v` files (like `Code_Enhanced_FIR_Filter_16tap_Propos.v`).
    * Ensure `Copy sources into project` is **unchecked** if you want to keep your Vivado project separate from the Git repository.
    * Click `Finish`. Vivado will automatically infer the hierarchy.

5.  **Add Simulation Sources (if separate testbenches):**
    * If you have separate testbench files, repeat the `Add Sources` step, but choose `Add or Create Simulation Sources`.

6.  **Run Simulation:**
    * In `Flow Navigator`, under `Simulation`, click `Run Simulation` -> `Run Behavioral Simulation`.
    * Observe the waveforms and verify functional correctness.

7.  **Run Synthesis & Implementation:**
    * In `Flow Navigator`, under `Synthesis`, click `Run Synthesis`.
    * Once synthesis completes, click `Run Implementation`.
    * After implementation, you can open the `Implemented Design` to view device utilization, timing, and power reports.

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
