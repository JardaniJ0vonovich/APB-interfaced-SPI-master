# APB Interfaced SPI Master IP Core

A Verilog implementation of an **AMBA APB3 Interfaced SPI Master IP Core** developed as part of the **Maven Silicon VLSI Design Training Program**. The project implements an SPI Master with an APB3 slave interface, modular RTL architecture, and functional verification using a Verilog testbench.

---

## Overview

This project implements an **SPI Master IP Core** that communicates with an **AMBA APB3 bus** through an APB Slave Interface. The processor configures the SPI peripheral using APB read/write transactions, while the SPI core handles serial communication with external SPI slave devices.

The design follows a modular architecture consisting of four major functional blocks:

- APB Slave Interface
- Baud Rate Generator
- SPI Shifter
- SPI Slave Select Controller

The project was developed in Verilog HDL and verified through functional simulation.

---

## Features

- AMBA APB3 compliant slave interface
- SPI Master implementation
- Configurable baud-rate generation
- 8-bit full-duplex SPI communication
- APB register read/write support
- MOSI, MISO, SCLK and Slave Select (SS)
- Modular RTL design
- Self-checking Verilog Testbench
- ASIC synthesis compatible RTL


---

## Project Structure

```
APB-interfaced-SPI-master/
│
├── rtl/
│   ├── top_module.v
│   ├── apb_slave_interface.v
│   ├── baud_rate.v
│   ├── spi_shifter.v
│   └── spi_slave_select.v
│
├── tb/
│   └── top_module_tb.v
│
├── synthesis/
│   ├── top_module.tcl
│
├── lint/
│   ├── vc_lint.tcl
│   └── Makefile
│
├── docs/
│   ├── 310239-ARM_AMBA3_APB.pdf
│   └── 310235-S12SPIV3.pdf
│
└── README.md
```

# Architecture

```
                        +----------------------+
                        |      APB Master      |
                        +----------+-----------+
                                   |
                             AMBA APB3 Bus
                                   |
                    +--------------v--------------+
                    |         Top Module          |
                    +--------------+--------------+
                                   |
     -------------------------------------------------------------
     |                     |                  |                  |
     |                     |                  |                  |
+-------------+    +----------------+   +----------------+  +----------------+
| APB Slave   |    | Baud Rate      |   | SPI Shifter   |  | SPI Slave      |
| Interface   |    | Generator      |   |               |  | Select Logic   |
+-------------+    +----------------+   +----------------+  +----------------+
        |                  |                   |                   |
        ------------------------------------------------------------
                                   |
                        MOSI   MISO   SCLK   SS
```

---

# Module Description

## 1. APB Slave Interface

Implements the AMBA APB3 protocol and acts as the communication bridge between the processor and the SPI core.

### Responsibilities

- APB protocol implementation
- Address decoding
- Register read/write operations
- APB state handling
- Generation of control signals for SPI modules

---

## 2. Baud Rate Generator

Generates the SPI serial clock by dividing the system clock according to the programmed baud-rate register.

### Responsibilities

- Clock divider
- SPI clock generation
- Configurable serial clock frequency
- Clock synchronization

---

## 3. SPI Shifter

Performs serial transmission and reception of SPI data.

### Responsibilities

- Parallel-to-Serial conversion
- Serial-to-Parallel conversion
- MOSI transmission
- MISO reception
- Shift counter
- Transfer complete detection

---

## 4. SPI Slave Select Controller

Controls the Slave Select (SS) signal during SPI communication.

### Responsibilities

- Assert SS before transfer
- Deassert SS after transfer completion
- Enable SPI slave communication

---

# SPI Interface

| Signal | Direction | Description |
|---------|-----------|-------------|
| MOSI | Output | Master Output Slave Input |
| MISO | Input | Master Input Slave Output |
| SCLK | Output | Serial Clock |
| SS | Output | Slave Select |

---

## Testbench Features

- Clock generation
- Active-low reset generation
- APB write task
- APB read task
- SPI slave emulation through the MISO input
- Functional verification of the integrated top module

## Simulation Scenarios

- APB write transactions
- APB read transactions
- SPI control register configuration
- Baud-rate register programming
- SPI transmit operation
- SPI receive operation
- Slave Select timing verification
- SPI clock generation
- Reset verification
- End-to-end data transfer

---

# Simulation Flow

1. Apply reset.
2. Configure SPI control registers.
3. Configure baud-rate register.
4. Read back configuration registers.
5. Write transmit data through APB.
6. Emulate SPI slave using the MISO signal.
7. Receive serial data.
8. Read received data through APB.
9. Verify successful SPI communication.

---

# Simulation

Compile and simulate using QuestaSim(or any similar software) and shell scripts for synthesis and linting are in the respective folders

# Tools Used

- Verilog HDL
- QuestaSim
- Synopsys Design Compiler
- SpyGlass Lint

---

# Future Improvements

- Verification of the current Design has to be done

---

# Author

**John Francis**

Bachelor of Technology (Electronics and Communication Engineering)

VLSI Design Enthusiast
