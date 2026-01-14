# Lightweight-Operating-System-for-the-Motorola-68000
M68K-LCOS A preemptive microkernel for the Motorola 68000. Features a Round-Robin scheduler, TCB state management, and Mutex primitives. Implements low-level context switching, isolated task stacks, and a TRAP #0 system call API. Designed to showcase hardware-level OS architecture, supervisor/user mode transitions, and atomic synchronization.

A Preemptive Lightweight Operating System for Motorola 68000
M68K-LCOS is a specialized microkernel written in 68000 Assembly. It demonstrates core OS concepts including hardware-level context switching, TCB management, and process synchronization through a preemptive multitasking framework.

🚀 Core Features
Preemptive Multitasking: Implements a Round-Robin scheduler driven by hardware timer interrupts (IRQ 1).
Context Switching: Full preservation of CPU state (D0-D7, A0-A6, SR, and PC) across task transitions.
Task Control Blocks (TCB): Structured memory management for task metadata and isolated stacks.
System Call API: A TRAP #0 interface providing services for task creation, deletion, and synchronization.
Mutex Primitives: Atomic Wait and Signal operations with task blocking to prevent busy-waiting.

🏗️ Technical Architecture
The kernel operates in Supervisor Mode, managing transitions to User Mode for application tasks. This ensures system stability by isolating hardware-critical instructions from user-space logic.
Memory Map
Range Function
$0000 - $03FF Exception Vector Table (EVT)
$0400 - $0FFFKernel Services & Service Routines
$1000 - $17FFTCB Storage (Supporting up to 8 Tasks)
$6000 - $7FFFIsolated Task Stacks$8000+User Application Code

🚦 System Call APITasks interact with the kernel by loading a function ID into D0 and triggering TRAP #0:
syscr (D0=1): Create Task (D1=Entry Point, D2=Stack Pointer)syswtmx (D0=3): Wait Mutex (Blocks task if resource is unavailable)syssgmx (D0=4): Signal Mutex (Releases resource and wakes blocked tasks)🛠️ Getting StartedOpen the source code in an M68K simulator (e.g., EASy68K).Assemble the project to generate the S-Record binary.Set the program counter to $400 and execute.Monitor task switching via memory-mapped I/O at address $E0000E.
