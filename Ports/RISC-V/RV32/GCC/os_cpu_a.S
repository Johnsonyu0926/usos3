#********************************************************************************************************
#                                              uC/OS-III
#                                        The Real-Time Kernel
#
#                    Copyright 2009-2021 Silicon Laboratories Inc. www.silabs.com
#
#                                 SPDX-License-Identifier: APACHE-2.0
#
#               This software is subject to an open source license and is distributed by
#                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
#                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
#
#********************************************************************************************************

#********************************************************************************************************
#
#                                        ASSEMBLY LANGUAGE PORT
#                                              RISC-V PORT
#
# File      : os_cpu_a.S
# Version   : V3.08.01
#********************************************************************************************************
# For       : RISC-V RV32
# Toolchain : GNU C Compiler
#********************************************************************************************************
#********************************************************************************************************

#********************************************************************************************************
#                                          PUBLIC FUNCTIONS
#********************************************************************************************************

    .extern  OSRunning                               # External references
    .extern  OSPrioCur
    .extern  OSPrioHighRdy
    .extern  OSTCBCurPtr
    .extern  OSTCBHighRdyPtr
    .extern  OSTaskSwHook


    .global  OSStartHighRdy                          # Functions declared in this file
    .global  OSCtxSw
    .global  OSIntCtxSw
    .global  Software_IRQHandler
    .global  ucos_intr_exception_handler


#********************************************************************************************************
#                                               EQUATES
#********************************************************************************************************

    .equ  RISCV_MSTATUS_MIE,          0x08

    .equ  ARCH_CPU_MCAUSE_INTR_MASK,  0x80000000

    .equ  ARCH_CPU_MCAUSE_CAUSE_MASK, 0x000003FF


#********************************************************************************************************
#                                     CODE GENERATION DIRECTIVES
#********************************************************************************************************

.section .text


#********************************************************************************************************
#                                         START MULTITASKING
#                                      void OSStartHighRdy(void)
#
# Note(s) : 1) OSStartHighRdy() MUST:
#              a) Call OSTaskSwHook() then,
#              b) Set OSRunning to TRUE,
#              c) Set OSTCBHighRdyPtr->StkPtr = SP
#              d) Restore x1-x31 and f0-f31; There is no need to restore x0 since it is always zero.
#              e) Enable interrupts (tasks will run with interrupts enabled).
#              f) Switch to highest priority task.
#********************************************************************************************************

OSStartHighRdy:
# Disable interrupts
    # load immediately "RISCV_MSTATUS_MIE" into t0 register
    li     t0, RISCV_MSTATUS_MIE
    # mstatus = mstatus & ~t0
    csrrc  zero, mstatus, t0

# Execute OS task switch hook.
    # jump to OSTaskSwHook function(address) and store the next instruction
    # into link register
    # this function will get called each time when the context switch happens
    jal    OSTaskSwHook

# OSRunning = TRUE;
    li     t0, 0x01
    # load address of OSRunning into t1 register
    la     t1, OSRunning
    # store byte value of t0 into memory address pointed by t1 with 0 offset
    sb     t0, 0(t1)

# SWITCH TO HIGHEST PRIORITY TASK
    la     t0, OSTCBHighRdyPtr
    # load word from address stored in [t0 + 0(offset)] to t1
    lw     t1, 0(t0)
    # load word from address stored in [t1+ 0(offset)] into sp
    lw     sp, 0(t1)

# Retrieve the location where to jump
    lw     t0, 31 * 4(sp)
    # value stored in t0 is stored into mepc
    csrw   mepc, t0

# Restore x1 to x31 registers (base registers)
    # load word from memory addres [(0 * 4) + sp] into ra register
    lw     ra,   0 * 4(sp)
    lw     t0,   4 * 4(sp)
    lw     t1,   5 * 4(sp)
    lw     t2,   6 * 4(sp)
    lw     s0,   7 * 4(sp)
    lw     s1,   8 * 4(sp)
    lw     a0,   9 * 4(sp)
    lw     a1,  10 * 4(sp)
    lw     a2,  11 * 4(sp)
    lw     a3,  12 * 4(sp)
    lw     a4,  13 * 4(sp)
    lw     a5,  14 * 4(sp)
    lw     a6,  15 * 4(sp)
    lw     a7,  16 * 4(sp)
    lw     s2,  17 * 4(sp)
    lw     s3,  18 * 4(sp)
    lw     s4,  19 * 4(sp)
    lw     s5,  20 * 4(sp)
    lw     s6,  21 * 4(sp)
    lw     s7,  22 * 4(sp)
    lw     s8,  23 * 4(sp)
    lw     s9,  24 * 4(sp)
    lw     s10, 25 * 4(sp)
    lw     s11, 26 * 4(sp)
    lw     t3,  27 * 4(sp)
    lw     t4,  28 * 4(sp)
    lw     t5,  29 * 4(sp)
    lw     t6,  30 * 4(sp)

    #Restore f0 to f31 registers (FP registers)
    flw    f0,  32 * 4(sp)
    flw    f1,  33 * 4(sp)
    flw    f2,  34 * 4(sp)
    flw    f3,  35 * 4(sp)
    flw    f4,  36 * 4(sp)
    flw    f5,  37 * 4(sp)
    flw    f6,  38 * 4(sp)
    flw    f7,  39 * 4(sp)
    flw    f8,  40 * 4(sp)
    flw    f9,  41 * 4(sp)
    flw    f10, 42 * 4(sp)
    flw    f11, 43 * 4(sp)
    flw    f12, 44 * 4(sp)
    flw    f13, 45 * 4(sp)
    flw    f14, 46 * 4(sp)
    flw    f15, 47 * 4(sp)
    flw    f16, 48 * 4(sp)
    flw    f17, 49 * 4(sp)
    flw    f18, 50 * 4(sp)
    flw    f19, 51 * 4(sp)
    flw    f20, 52 * 4(sp)
    flw    f21, 53 * 4(sp)
    flw    f22, 54 * 4(sp)
    flw    f23, 55 * 4(sp)
    flw    f24, 56 * 4(sp)
    flw    f25, 57 * 4(sp)
    flw    f26, 58 * 4(sp)
    flw    f27, 59 * 4(sp)
    flw    f28, 60 * 4(sp)
    flw    f29, 61 * 4(sp)
    flw    f30, 62 * 4(sp)
    flw    f31, 63 * 4(sp)

# Compensate for the stack pointer
    # sp = sp + 64 * 4
    addi   sp, sp, 64 * 4

# Use register t6 to jump to HIGHEST priority
    csrr   t6, mepc

# Enable global interrupts
    li     t0, RISCV_MSTATUS_MIE
    csrrs  zero, mstatus, t0

# Jump to HIGHEST priority task.
    jalr   x0, t6, 0


#********************************************************************************************************
#                       PERFORM A CONTEXT SWITCH (From task level) - OSCtxSw()
#                   PERFORM A CONTEXT SWITCH (From interrupt level) - OSIntCtxSw()
#
# Note(s) : 1) OSCtxSw() is called when OS wants to perform a task context switch.  This function
#              triggers a ecall.
#
#           2) OSIntCtxSw() is called by OSIntExit() when it determines a context switch is needed as
#              the result of an interrupt.  This function just return back as the context switch after interrupt
#              is executed just before exiting the interrupt handler.
#********************************************************************************************************
OSIntCtxSw:
    ret

OSCtxSw:
    ecall
    ret

# Exception handler should be 256 bytes aligned
.align 8
ucos_intr_exception_handler:
    # save regs to current sp
    addi sp, sp, -4*64
    # store contents of register ra into memory [(0 * 4) + sp]
    sw     ra,   0 * 4(sp)
    sw     t0,   4 * 4(sp)
    sw     t1,   5 * 4(sp)
    sw     t2,   6 * 4(sp)
    sw     s0,   7 * 4(sp)
    sw     s1,   8 * 4(sp)
    sw     a0,   9 * 4(sp)
    sw     a1,  10 * 4(sp)
    sw     a2,  11 * 4(sp)
    sw     a3,  12 * 4(sp)
    sw     a4,  13 * 4(sp)
    sw     a5,  14 * 4(sp)
    sw     a6,  15 * 4(sp)
    sw     a7,  16 * 4(sp)
    sw     s2,  17 * 4(sp)
    sw     s3,  18 * 4(sp)
    sw     s4,  19 * 4(sp)
    sw     s5,  20 * 4(sp)
    sw     s6,  21 * 4(sp)
    sw     s7,  22 * 4(sp)
    sw     s8,  23 * 4(sp)
    sw     s9,  24 * 4(sp)
    sw     s10, 25 * 4(sp)
    sw     s11, 26 * 4(sp)
    sw     t3,  27 * 4(sp)
    sw     t4,  28 * 4(sp)
    sw     t5,  29 * 4(sp)
    sw     t6,  30 * 4(sp)

    #  save f0 to f31 registers (FPU registers)
    fsw    f0,  32 * 4(sp)
    fsw    f1,  33 * 4(sp)
    fsw    f2,  34 * 4(sp)
    fsw    f3,  35 * 4(sp)
    fsw    f4,  36 * 4(sp)
    fsw    f5,  37 * 4(sp)
    fsw    f6,  38 * 4(sp)
    fsw    f7,  39 * 4(sp)
    fsw    f8,  40 * 4(sp)
    fsw    f9,  41 * 4(sp)
    fsw    f10, 42 * 4(sp)
    fsw    f11, 43 * 4(sp)
    fsw    f12, 44 * 4(sp)
    fsw    f13, 45 * 4(sp)
    fsw    f14, 46 * 4(sp)
    fsw    f15, 47 * 4(sp)
    fsw    f16, 48 * 4(sp)
    fsw    f17, 49 * 4(sp)
    fsw    f18, 50 * 4(sp)
    fsw    f19, 51 * 4(sp)
    fsw    f20, 52 * 4(sp)
    fsw    f21, 53 * 4(sp)
    fsw    f22, 54 * 4(sp)
    fsw    f23, 55 * 4(sp)
    fsw    f24, 56 * 4(sp)
    fsw    f25, 57 * 4(sp)
    fsw    f26, 58 * 4(sp)
    fsw    f27, 59 * 4(sp)
    fsw    f28, 60 * 4(sp)
    fsw    f29, 61 * 4(sp)
    fsw    f30, 62 * 4(sp)
    fsw    f31, 63 * 4(sp)

    # If it is a ecall, do not add 4 in mepc
    # otherwise add 4 in mepc
    li t1, ARCH_CPU_MCAUSE_CAUSE_MASK
    csrr  t0, mcause
    # t3 = t1 & t0
    and t3, t1, t0
    li t1, 11
    csrr   t0,  mepc
    # If t1 != t3 jump to DONTADD:
    bne t1, t3, DONTADD
    addi   t0,  t0, 4
   
DONTADD: # for interrupt do not add 4 in mepc
    sw     t0,  31*4(sp)
    # load address of OSTCBCurPtr into t0 register
    la     t0, OSTCBCurPtr
    # load word from register [t0 + 0] address into t1
    lw     t1, 0(t0)
    # store value stored in sp to [t1 + 0] address
    sw     sp, 0(t1)

    li t1, ARCH_CPU_MCAUSE_INTR_MASK
    csrr  t0, mcause
    and t2, t1, t0
    bne t1, t2, run_exception_handler
    # it is a interrupt
    j run_interrupt_exception_handler

run_exception_handler:
    li t1, ARCH_CPU_MCAUSE_CAUSE_MASK
    csrr  t0, mcause
    and t3, t1, t0
    li t1, 11
    bne t1, t3, run_interrupt_exception_handler
    # it is a ecall
    j run_ecall_handler

run_interrupt_exception_handler:
    jal osa_intr_master_isr 

run_ecall_handler:
    j Software_IRQHandler




#********************************************************************************************************
#                                   void Software_IRQHandler (void)
#
#           1) Pseudo-code is:
#              a) Call OSTaskSwHook();
#              b) Get current high priority, OSPrioCur = OSPrioHighRdy;
#              c) Get current ready thread TCB, OSTCBCurPtr = OSTCBHighRdyPtr;
#              d) Get new process SP from TCB, SP = OSTCBHighRdyPtr->StkPtr;
#              e) Retrieve the address at which exception happened.
#              f) Restore x1-x31(base registers) and f0-f31(FP registers)
#                 from new process stack; x0 is always zero.
#              g) set MPIE = 1 to enable interrupt before returning.
#              h) Perform exception return which will restore remaining context.
#
#********************************************************************************************************

Software_IRQHandler:
# Execute OS task switch hook.
    jal    OSTaskSwHook

# OSPrioCur = OSPrioHighRdy;
    la     t0, OSPrioHighRdy
    lb     t1, 0(t0)
    la     t0, OSPrioCur
    sb     t1, 0(t0)

# OSTCBCurPtr = OSTCBHighRdyPtr;
    la     t0, OSTCBHighRdyPtr
    lw     t1, 0(t0)
    la     t0, OSTCBCurPtr
    sw     t1, 0(t0)

# SP = OSTCBHighRdyPtr->StkPtr;
    lw     sp, 0(t1)

# Retrieve the address at which exception happened
    lw     t0, 31 * 4(sp)
    csrw   mepc, t0

# Restore x1 to x31 registers
    lw     ra,   0 * 4(sp)
    lw     t0,   4 * 4(sp)
    lw     t1,   5 * 4(sp)
    lw     t2,   6 * 4(sp)
    lw     s0,   7 * 4(sp)
    lw     s1,   8 * 4(sp)
    lw     a0,   9 * 4(sp)
    lw     a1,  10 * 4(sp)
    lw     a2,  11 * 4(sp)
    lw     a3,  12 * 4(sp)
    lw     a4,  13 * 4(sp)
    lw     a5,  14 * 4(sp)
    lw     a6,  15 * 4(sp)
    lw     a7,  16 * 4(sp)
    lw     s2,  17 * 4(sp)
    lw     s3,  18 * 4(sp)
    lw     s4,  19 * 4(sp)
    lw     s5,  20 * 4(sp)
    lw     s6,  21 * 4(sp)
    lw     s7,  22 * 4(sp)
    lw     s8,  23 * 4(sp)
    lw     s9,  24 * 4(sp)
    lw     s10, 25 * 4(sp)
    lw     s11, 26 * 4(sp)
    lw     t3,  27 * 4(sp)
    lw     t4,  28 * 4(sp)
    lw     t5,  29 * 4(sp)
    lw     t6,  30 * 4(sp)

    #  Restore f0 to f31 registers (FPU registers)
    flw    f0,  32 * 4(sp)
    flw    f1,  33 * 4(sp)
    flw    f2,  34 * 4(sp)
    flw    f3,  35 * 4(sp)
    flw    f4,  36 * 4(sp)
    flw    f5,  37 * 4(sp)
    flw    f6,  38 * 4(sp)
    flw    f7,  39 * 4(sp)
    flw    f8,  40 * 4(sp)
    flw    f9,  41 * 4(sp)
    flw    f10, 42 * 4(sp)
    flw    f11, 43 * 4(sp)
    flw    f12, 44 * 4(sp)
    flw    f13, 45 * 4(sp)
    flw    f14, 46 * 4(sp)
    flw    f15, 47 * 4(sp)
    flw    f16, 48 * 4(sp)
    flw    f17, 49 * 4(sp)
    flw    f18, 50 * 4(sp)
    flw    f19, 51 * 4(sp)
    flw    f20, 52 * 4(sp)
    flw    f21, 53 * 4(sp)
    flw    f22, 54 * 4(sp)
    flw    f23, 55 * 4(sp)
    flw    f24, 56 * 4(sp)
    flw    f25, 57 * 4(sp)
    flw    f26, 58 * 4(sp)
    flw    f27, 59 * 4(sp)
    flw    f28, 60 * 4(sp)
    flw    f29, 61 * 4(sp)
    flw    f30, 62 * 4(sp)
    flw    f31, 63 * 4(sp)

# Compensate for the stack pointer
    addi   sp, sp, 4 * 64

# Exception return will restore remaining context
    # set MPIE = 1
    # interrupts will be enabled from here onwards
    li t0, 0x80
    csrrs zero, mstatus, t0   
    mret

#********************************************************************************************************
#                                             MODULE END
#*********************************************************************************************************
