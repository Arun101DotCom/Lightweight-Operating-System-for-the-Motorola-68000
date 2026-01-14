*-----------------------------------------------------------
* M68K-LCOS: Preemptive Microkernel Logic
* AUTHOR: Arun Chakkyadath Chandran
*-----------------------------------------------------------

;system call equates
sys      equ     0               ; system call trap (trap 0)
syscr    equ     1               ; create new task
sysdel   equ     2               ; delete task
syswtmx  equ     3               ; wait on mutex
syssgmx  equ     4               ; signal mutex
sysinmx  equ     5               ; initialise mutex 
syswttm  equ     6               ; wait on timer

READY_LIST_HEAD_POINTER     equ    $2000   
WAIT_LIST_HEAD_POINTER      equ    $2050   
TASK_STACK_SIZE             equ    2000

usrcode equ     $8000           ;address of user task 0
usrstk  equ     $6000           ;address of user stack
ntcblst equ     8               ;number of records in tcb list

*-----------------------------------------------------------
* TCB Structure Offsets
*-----------------------------------------------------------
tcb      org     0               ;tcb record
tcbd0    ds.l    1               ; D register save
tcbd1    ds.l    1
tcbd2    ds.l    1
tcbd3    ds.l    1
tcbd4    ds.l    1
tcbd5    ds.l    1
tcbd6    ds.l    1
tcbd7    ds.l    1
tcba0    ds.l    1               ; A register save
tcba1    ds.l    1
tcba2    ds.l    1
tcba3    ds.l    1
tcba4    ds.l    1
tcba5    ds.l    1
tcba6    ds.l    1
tcba7    ds.l    1               ; Stack Pointer save
tcbsr    ds.l    1               ; SR (status reg) save
tcbpc    ds.l    1               ; PC save
tcbhead  ds.l    1               ; code address
tcbnext  ds.l    1               ; link to next TCB
tcbused  ds.l    1               ; $FFFF=unused, $0000=used
tcbwtim  ds.l    1               ; timer wait
tcbready ds.l    1               ; #$FF=ready, #$00=wait
tcbstack ds.l    1               ; stack start
tcbwait_mutex ds.l 1             ; mutex wait flag
tcblen   equ     *

*-----------------------------------------------------------
* EXCEPTION VECTORS
*-----------------------------------------------------------
        org     0
        dc.l    usrstk           ; initial SP
        dc.l    res              ; reset
        
        org     $64
        dc.l    fltint           ; interrupt 1 (timer)
        
        org     $80
        dc.l    flsint           ; software 0 (sys call)
        dc.l    wait_mutex_handler   
        dc.l    signal_mutex_handler

*-----------------------------------------------------------
* KERNEL START & INITIALIZATION
*-----------------------------------------------------------
        org     $400
res:
    or      #$0700,sr           ; disable interrupts
    lea     welcome_text,A1
    move    #13,D0
    trap    #15                 ; print welcome

    ; clean tcb memory
    move    #$1000, A0
__clean_memory_phase:
    move.l  #$FFFFFFFF, tcbused(a0) 
    add     #$100, A0
    cmp     #$1900, A0
    bne     __clean_memory_phase

    ; Init Data
    move.l  #$1000, rdytcb
    move    #$FFFF, wait_mutex
    move    #$FFFF, signal_mutex
    
    and     #$f8ff,sr           ; enable timer
    jmp     T0 

*-----------------------------------------------------------
* INTERRUPT HANDLING (CONTEXT SAVING)
*-----------------------------------------------------------
fltint:                         ; Timer Entry
    or      #$0700,sr           ; mask interrupts
    move.l  d0,d0sav
    move.l  #0,id               ; id 0 = hardware
    bra     fl1

flsint:                         ; Trap Entry
    or      #$0700,sr
    move.l  d0,id               ; save function id
    bra     fl1

fl1:
    move.l  a0,a0sav
    move.l  rdytcb,a0           ; current TCB

    ; --- Store Registers ---
    move.l  d1,tcbd1(a0)
    move.l  d2,tcbd2(a0)
    move.l  d3,tcbd3(a0)
    move.l  d4,tcbd4(a0)
    move.l  d5,tcbd5(a0)
    move.l  d6,tcbd6(a0)
    move.l  d7,tcbd7(a0)
    move.l  a0sav,d0
    move.l  d0,tcba0(a0)        ; Restore saved a0
    move.l  a1,tcba1(a0)
    move.l  a2,tcba2(a0)
    move.l  a3,tcba3(a0)
    move.l  a4,tcba4(a0)
    move.l  a5,tcba5(a0)
    move.l  a6,tcba6(a0)
    move.l  a7,tcba7(a0)        ; Save User SP

    ; --- Pop SR and PC from Stack ---
    move.w  (sp)+,d0            ; pop SR
    ext.l   d0
    move.l  d0,tcbsr(a0)
    move.l  (sp)+,tcbpc(a0)     ; pop PC
    
    move.l  d0sav,tcbd0(a0)     ; Save original D0
    
    move.l  id, d0
    bra     service_request

*-----------------------------------------------------------
* SCHEDULER & DISPATCHER
*-----------------------------------------------------------
sched:
    move.l  rdytcb, a0
    move.l  tcbnext(a0), a0     ; Round Robin: move to next
    
    ; Check if next TCB is valid and Ready
    cmp.l   #$1900, a0
    blo     __check_ready
    move.l  #$1000, a0          ; wrap around
    
__check_ready:
    cmp.l   #$00FF, tcbready(a0) ; is it ready?
    beq     disp
    move.l  tcbnext(a0), a0     ; try next if blocked
    bra     __check_ready

disp:
    move.l  a0, rdytcb
    move.l  tcba7(a0), a7       ; restore SP
    
    ; Push PC and SR back to stack for RTE
    move.l  tcbpc(a0), -(sp)
    move.l  tcbsr(a0), d0
    move.w  d0, -(sp)
    
    ; Restore Registers
    move.l  tcbd0(a0), d0
    move.l  tcbd1(a0), d1
    move.l  tcbd2(a0), d2
    move.l  tcbd3(a0), d3
    move.l  tcbd4(a0), d4
    move.l  tcbd5(a0), d5
    move.l  tcbd6(a0), d6
    move.l  tcbd7(a0), d7
    move.l  tcba1(a0), a1
    move.l  tcba2(a0), a2
    move.l  tcba3(a0), a3
    move.l  tcba4(a0), a4
    move.l  tcba5(a0), a5
    move.l  tcba6(a0), a6
    move.l  tcba0(a0), a0       ; restore a0 last
    
    rte                         ; Switch context

*-----------------------------------------------------------
* SHARED DATA & TASKS
*-----------------------------------------------------------
        org     $800
welcome_text     dc.b 'Lightweight OS version 1.9 (Motorola 68000)',13,10,0
start_timer_text dc.b 'Start the timer. setup is finished.',0
shutdown_text    dc.b 'System has stopped',0

        org     $300
rdytcb  ds.l    1
id      ds.l    1
d0sav   ds.l    1
a0sav   ds.l    1
wait_mutex ds.l 1
signal_mutex ds.l 1

        org     usrcode
T0: 
    ; Application Code Here...
    SIMHALT

    END res