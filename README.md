# AION-CORE: Physics-Aware Adaptive Control Kernel

<p align="center">
  <img src="https://img.shields.io/badge/Status-TRL%204%20(Lab%20Validated)-success?style=for-the-badge&logo=github" alt="Status TRL 4">
  <img src="https://img.shields.io/badge/Platform-FPGA%20%2F%20Real--Time-red?style=for-the-badge&logo=xilinx" alt="Platform FPGA">
  <img src="https://img.shields.io/badge/Latency-%3C%201%C2%B5s%20(Target)-blue?style=for-the-badge&logo=speedtest" alt="Latency Sub-microsecond">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=for-the-badge" alt="License MIT">
</p>

---

## ⚛️ The Paradigm Shift in Fast Control

**AION-CORE** is not just another controller. It is a **Control Kernel** designed for extreme physical systems where traditional PID fails due to latency, and standard MPC fails due to computational load.

It introduces the **PACC (Physics-Aware Adaptive Control Core)** paradigm: orchestrating control decisions based on immediate physical precursors rather than delayed error integration.

> **Core Mission:** To provide a deterministic, sub-microsecond "Guardian Layer" for systems operating on the brink of instability, such as Tokamak plasmas and pulsed propulsion drives.

---

## 🚀 Key Features & Innovations

| Feature | Description |
| :--- | :--- |
| **⚡ Sub-Microsecond Response** | Designed for bare-metal FPGA implementation (COOK framework), targeting **21ns – 1µs** reflex latency. |
| **🛡️ Guardian Mode Interlock** | Hard-coded safety layer that vetoes unsafe control actions based on physical invariants, preventing catastrophic failures. |
| **🧠 Physics-Anchored Logic** | Uses simplified internal models and **Precursor Maps** instead of black-box neural networks, ensuring interpretability. |
| **⏱️ PSQ Metric** | *Plasma Synchronization Quotient*: A novel metric for quantifying temporal coherence between control pulses and physical dynamics. |
| **🏭 Industrial Validation** | Tested against high-fidelity simulators (50+ state variables) with realistic sensor noise and drift (TRL 4). |

---
## 🏗️ Architecture: The COOK Framework

AION-CORE executes within the **Control-Oriented Operating Kernel (COOK)**, a dual-loop architecture optimized for determinism.

```mermaid
graph TD
    subgraph "Physical Plant (Tokamak/PEC)"
        S[⚡ Fast Sensors (dB/dt, Ip)]
        A[🔌 Actuators (Coils/Pulses)]
    end

    subgraph "COOK Kernel (FPGA Fabric)"
        direction TB

        subgraph "Layer 1: Reflex Loop (<1µs)"
            PM[🔍 Precursor Monitor]
            TM[🧠 Threat Memory (BRAM)]
            GL[🛡️ Guardian Logic (Interlock)]
        end

        subgraph "Layer 2: Cognitive Loop (~1ms)"
            ADAPT[🔄 RLS Model Adaptation]
        end

        S ===>|Raw Data| PM
        PM ===>|Signature Match| TM
        TM ===>|Candidate Action| GL
        GL ===>|Verified Pulse| A

        S -.->|Slow Data| ADAPT
        ADAPT -.->|Update Parameters| TM
    end

    style GL fill:#f96,stroke:#333,stroke-width:2px,color:black
    style PM fill:#add8e6,stroke:#333,color:black
```
