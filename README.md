# M68K-LCOS: Preemptive Microkernel Analysis

**M68K-LCOS:** A preemptive microkernel for the Motorola 68000 architecture featuring a Round-Robin scheduler, TCB management, and mutex synchronization.

**Systems Programming | Motorola 68000 Architecture**

## 🔬 Project Overview

This research involves the design and implementation of a **Preemptive Lightweight Operating System (LCOS)** for the Motorola 68000. The study focuses on achieving stable multi-tasking by managing supervisor/user mode transitions and implementing atomic synchronization primitives.



The project is structured into four core segments:

* **Part A:** Hardware-level Exception Vector Table (EVT) initialization.
* **Part B:** Context switching and CPU state preservation.
* **Part C:** Round-Robin scheduling and Task Control Block (TCB) management.
* **Part D:** Concurrency control using atomic Mutex synchronization.

## 🏆 Key Achievements

* **Preemptive Logic:** Successfully implemented a context switcher driven by hardware timer interrupts (IRQ 1).
* **Full State Preservation:** Achieved 100% restoration of all 15 registers (D0-D7, A0-A6) plus SR and PC.
* **Optimized Scheduling:** Developed a circular linked-list scheduler with specialized "Ready/Blocked" states.
* **Kernel Security:** Implemented a secure TRAP #0 interface to isolate kernel services from user applications.

## 🛠️ System Architecture & Workflow

The system utilizes a low-level assembly approach to leverage the hardware abstraction layer of the M68K:

1. **Kernel Pipeline:** Handles the boot sequence, stack initialization, and hardware-interrupt servicing.
2. **Task Pipeline:** Utilizes Task Control Blocks (TCB) for state-saving, hyper-tuning task priorities, and real-time dispatching.



## 📊 Detailed System Specifications

### **1. Memory Architecture Tiers**

Through strict memory mapping, the kernel segments were categorized by their access level:

* **Tier 1 (System):** Exception Vector Table ($0000 - $03FF).
* **Tier 2 (Kernel):** ISR routines, Scheduler, and Mutex logic ($0400 - $0FFF).
* **Tier 3 (Metadata):** TCB Storage and Shared Ready List ($1000 - $17FF).
* **Tier 4 (User):** Isolated Task Stacks and Application Code ($6000+).

### **2. Kernel Service Performance**

| Service | Trap ID | Function |


* | **Task Creation** | **D0 = 1** | Initializes TCB and Stack Pointer. |
* | **Wait Mutex** | **D0 = 3** | Blocks task if resource is locked. |
* | **Signal Mutex** | **D0 = 4** | Releases resource and wakes blocked tasks. |

## 📂 Repository Structure (Development Workflow)

To navigate the kernel research methodology, please follow the folders in numerical order:

* **01_Source_Code**: Contains the primary kernel source code (`.X68 `), including the Exception Vector Table, Scheduler, and Synchronization Primitives.
* **02_Technical_Report**: A comprehensive PDF detailing the memory map, context switch timing analysis, and supervisor-mode security protocols.
* **03_Presentation_Video**: A recorded demonstration showing the kernel managing multiple concurrent tasks and handling mutex contention in the EASy68K simulator.

  
**Author:** Arun Chakkyadath Chandran
**Institution:** Newcastle University, UK  
**Keywords:** Motorola 68000, Assembly, Microkernel, Context Switching, Preemptive Multitasking.
