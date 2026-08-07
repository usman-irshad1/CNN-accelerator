# 🚀 CNN Accelerator Architecture (FPGA SystemVerilog)

A hardware-accelerated **Convolutional Neural Network (CNN) Engine** implemented in **SystemVerilog** for FPGA deployment. This project follows a disciplined, bottom-up architectural methodology—starting from fundamental memory blocks and Multiply-Accumulate (MAC) DSP units, and systematically building towards a fully pipelined, multi-channel 2D CNN layer processor.

---

## 📌 Project Overview

Convolutional Neural Networks (CNNs) rely heavily on 2D matrix convolutions, which are computationally dominated by Multiply-Accumulate (MAC) inner-product operations. Standard general-purpose processors (CPUs/GPUs) introduce memory bandwidth bottlenecks when streaming feature maps. 

This project implements a custom **FPGA hardware accelerator datapath** designed to optimize compute throughput, minimize memory access latency, and maximize resource utilization on Xilinx FPGAs via Vivado synthesis and simulation.

---

## 🏗️ Hardware Architecture & Datapath

The core engine is structured around a **Phase-Separated Datapath Architecture** connecting dual-port Block RAM (BRAM) directly to a custom DSP Multiply-Accumulate (MAC) core.

```text
                     Dual-Port BRAM
                     ┌─────────────┐
Address Port 1 ────► │             │ ────► Read Data Port 1 (Operand A)
                     │  512 x 9-bit│
Address Port 2 ────► │  Memory     │ ────► Read Data Port 2 (Operand B)
                     └─────────────┘
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
       ┌─────────────┐             ┌─────────────┐
       │   Posedge   │             │   Posedge   │
       │ Memory Read │             │ Memory Read │
       └──────┬──────┘             └──────┬──────┘
              │                           │
              └─────────────┬─────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ Multiplier   │  (9-bit x 9-bit)
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ Adder Stage  │ ◄─── Previous Accumulator
                    └──────┬───────┘
                           │  (Negedge Clock Trigger)
                           ▼
                    ┌──────────────┐
                    │ Accumulator  │  (27-bit Register)
                    └──────┬───────┘
                           │
                           ▼
                    [ Output Result ]
```

### ⚡ Timing & Phase Separation Strategy

To ensure clean timing closure and eliminate race conditions between memory read latency and arithmetic computations:
- **`posedge clock`**: Dual-port BRAM reads data values matching incoming addresses.
- **`negedge clock`**: DSP Multiply-Accumulate block reads stable data outputs from BRAM, computes the product ($A \times B$), and updates the 27-bit accumulator register.

This half-cycle phase separation provides setup and hold time margin without requiring additional hardware register pipeline stages in the early prototyping phase.

---

## 📐 Mathematical Formulation

### 1. Multiply-Accumulate (MAC) Unit
The fundamental element performs iterative accumulation:
$$\text{ACC}_{k} = \text{ACC}_{k-1} + (A_k \times B_k)$$

### 2. 2D Kernel Convolution
For a standard $3 \times 3$ convolution kernel over an input patch $X$, the output pixel $Y$ is computed as:
$$Y = \sum_{i=0}^{8} X_i \cdot W_i = X_0 W_0 + X_1 W_1 + X_2 W_2 + X_3 W_3 + X_4 W_4 + X_5 W_5 + X_6 W_6 + X_7 W_7 + X_8 W_8$$

---

## 📁 Repository Directory Structure

```text
CNN_Architecture/
├── documenation/
│   ├── documetaion.txt      # Detailed architectural notes & execution roadmap
│   └── MAC_output.pdf       # Vivado waveform verification plot
├── MAC.srcs/
│   ├── sources_1/new/
│   │   ├── BRAM.sv          # Parameterized Dual-Port BRAM memory module
│   │   ├── DSP.sv           # Multiply-Accumulate (MAC) DSP block
│   │   └── top.sv           # Top-level MAC_TOP integration module
│   └── sim_1/new/
│       ├── tb.sv            # Top-level testbench with math verification
│       └── tb_MAC.sv        # Subsystem verification testbench
├── BRAM.mem                 # Hex/Binary memory initialization dataset
├── MAC.xpr                  # Xilinx Vivado project file
├── README.md                # Project documentation & 1-week timeline
└── .gitignore               # Ignored build outputs and temporary Vivado logs
```

---

## 🔬 Sub-module Specifications

### 1. `BRAM.sv` — Dual-Port Block RAM
- **Parameters**: `mem_depth=512`, `mem_length=9` (data width), `ins_width=9` (address width).
- **Features**: Fully independent dual read/write ports, memory initialization from `BRAM.mem`, and address write collision warning.

### 2. `DSP.sv` — Multiply-Accumulate Core
- **Parameters**: `mem_length=9`, `accum_length=27`.
- **Features**: Active-high asynchronous reset clearing accumulator, negedge-triggered accumulation logic preventing BRAM read race conditions.

### 3. `MAC_TOP.sv` — Integration Top Wrapper
- Interconnects `BRAM` and `DSP` modules, exposing address input ports and output accumulator result for top-level system verification.

---

## 🧪 Simulation & Verification Results

The testbench (`tb.sv`) validates 5 sequential accumulation cycles reading from initialized memory addresses:

```text
==================================================================
          Starting MAC_TOP SystemVerilog Verification            
==================================================================
[10 ns] Reset released. Accumulator initialized to 0.
[20 ns] Step 1 | Addr (0,1) -> Data (0,1) | ACC = 0
[30 ns] Step 2 | Addr (1,2) -> Data (1,2) | ACC = 2
[40 ns] Step 3 | Addr (2,3) -> Data (2,3) | ACC = 8
[50 ns] Step 4 | Addr (3,4) -> Data (3,4) | ACC = 20
[60 ns] Step 5 | Addr (4,5) -> Data (4,5) | ACC = 40
------------------------------------------------------------------
  FINAL MAC ACCUMULATOR RESULT = 40
  EXPECTED MATHEMATICAL VALUE  = 40
  VERIFICATION STATUS          = SUCCESS (PASS)
------------------------------------------------------------------
```

---

## 📅 1-Week Implementation Timeline & Roadmap

| Day | Focus Area | Architectural Objectives & SystemVerilog Scope | Status |
|---|---|---|---|
| **Day 1** | **Single MAC & BRAM Datapath** | • Parameterized Dual-Port BRAM (`BRAM.sv`)<br>• MAC DSP Core with phase separation (`DSP.sv`)<br>• Integration Top Module (`MAC_TOP.sv`) & Testbenches | **DONE / VERIFIED** ✅ |
| **Day 2** | **3x3 Sequential Convolution Engine** | • State machine (FSM) controlling 9 sequential MAC cycles<br>• Address generation unit (AGU) for $3 \times 3$ kernel patches<br>• End-of-convolution strobe & output latch | **IN PROGRESS** 🔄 |
| **Day 3** | **Vectorized Array MAC Processing** | • SystemVerilog unrolled vector representations (`logic [8:0][8:0]`)<br>• Synthesizable `for` loop explorations vs parallel resource allocation<br>• Vectorized testbench environment | **PLANNED** 📅 |
| **Day 4** | **3-MAC Partial Parallel Architecture** | • 3 parallel MAC blocks computing 3 kernel rows simultaneously<br>• Row-buffer address indexing<br>• 3-input partial accumulator reduction | **PLANNED** 📅 |
| **Day 5** | **9-MAC Parallel Processing & Adder Tree** | • 9 parallel multiplier units for single-cycle $3 \times 3$ dot product<br>• Binary Pipelined Reduction Adder Tree<br>• Throughput vs Resource Trade-off Analysis | **PLANNED** 📅 |
| **Day 6** | **Streaming Line Buffers & Sliding Window** | • 2-line BRAM line buffers for continuous streaming data<br>• $3 \times 3$ shift-register sliding window generator<br>• Zero-padding / Boundary handling logic | **PLANNED** 📅 |
| **Day 7** | **Full CNN Layer Integration** | • Multi-filter output channel processing<br>• Post-MAC Bias addition & Activation Unit ($\text{ReLU}(x) = \max(0, x)$)<br>• Feature map output BRAM storage & complete layer simulation | **PLANNED** 📅 |

---

## 🛠️ How to Run Simulation in Xilinx Vivado

1. Open **Vivado** (2020.2 or later).
2. Open project file `MAC.xpr`.
3. Set `MAC_TOP_tb` or `tb_MAC` as the active simulation top module.
4. Click **Run Simulation -> Run Behavioral Simulation**.
5. Observe testbench `$display` outputs and waveform window confirming `result = 40`.

---

## 👤 Author & License
- **Author**: Mohammad Usman Irshad
- **Repository**: `CNN Architecture`
- **License**: MIT
