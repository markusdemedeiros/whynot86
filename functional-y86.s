# FIRST CLASS FUNCTIONS IN y86
# (a solution to http://www.rosettacode.org/wiki/First-class_functions)
# using self-modifying code.

# (run in sequential: ANY pipelining ruins this. Instructions overwrite each
# other so we have a data hazard in FETCH)

irmovq stack, %rsp
irmovq fnstack, %rbp
jmp main

# Example functional program
.pos 0x100
main:
    irmovq addeight, %rdi
    irmovq endaddeight, %rsi
    call fnalloc
    rrmovq %rax, %r12               # %r12 = pointer to static (x -> (+8) x) function
    
    irmovq addten, %rdi
    irmovq endaddten, %rsi
    call fnalloc                    # %rax = pointer to static (x -> (+10) x) function
    
    rrmovq %rax, %rdi
    rrmovq %r12, %rsi
    call fncompose                  # %rax = pointer to static (x -> ((+10) . (+8)) x) function
    
    rrmovq %rax, %rdi
    irmovq 13, %rsi
    call fnexecute                  # evalute. %rax = ((+10) . (+8)) 13 = 31
    
    halt


################################################
## FUNCTIONAL OPERATORS


# fnexecute
#   Excecutes the funciton pointed to by %rdi with single argument %rsi and 
#   returns the result
.pos 0x500
fnexecute:
    irmovq fnjmp, %rdx
    rmmovq %rdi, 0x1(%rdx)
    rrmovq %rsi, %rdi
fnjmp:
    call invalidfn
    ret




# fnalloc
#   Takes a valid (single ret terminated), allocates space on the function stack,
#   and returns address of the now static function. Copies in 8-byte chunks. 
#   arguments:
#   %rdi = start of the function to be copied
#   %rsi = end of function to be copied
#   effects:
#       - function is copied to the top of the fnstack
#       - %rax = start of function to be copied
#       - %rbp is updated to point to the new stack top
fnalloc:
    rrmovq %rbp, %rax
    irmovq 0x8, %r8
    jmp loopcheck
    
    looptop:
    mrmovq 0(%rdi), %r11
    rmmovq %r11, 0(%rbp)
    addq %r8, %rbp
    addq %r8, %rdi
    
    loopcheck:
        # if (rdi < rsi) keep copying <=> if (rdi - rsi < 0) goto top
        # otherwise, we have copied everything. 
    rrmovq %rdi, %r11
    subq %rsi, %r11
    jl looptop
    
    # Allocate 8 extra bytes for and overwrite garbage with HALT: if a function
    #   doesn't return we want to terminate. Not strictly nessecary. 
    irmovq 0, %r10
    rmmovq %r10, 0(%rbp)
    rrmovq %rbp, %r9
    subq %r11, %r9
    rmmovq %r10, 0(%r9)
    addq %r8, %rbp
    ret



# fncompose 
# Allocates a new function on the static function stack which is the composition of the
#   two functions %rdi and %rsi, and returns the address. 
#   %rdi = address of outer function
#   %rsi = address of inner function
fncompose:
    irmovq TCompose, %rdx
    rmmovq %rsi, 2(%rdx)
    rmmovq %rdi, 23(%rdx)
    
    irmovq TCompose, %rdi
    irmovq TComposeEnd, %rsi
    call fnalloc
    ret
    
    # The following template will be overwritten and allocated as a new static fn
    TCompose:
        irmovq 0xDEADBEEF, %rdi
        call fnexecute
        rrmovq %rax, %rsi
        irmovq 0xDEADBEEF, %rdi
        call fnexecute
        ret
    TComposeEnd:
    




################################################
## STACK

.pos 0x2000
stack:




################################################
## PRIMITIVE FUNCTIONS

.pos 0x3000
invalidfn:
    halt

addeight:
    irmovq 0x8, %r8
    rrmovq %rdi, %rax
    addq %r8, %rax
    ret
endaddeight:

addten:
    irmovq 10, %r8
    rrmovq %rdi, %rax
    addq %r8, %rax
    ret
endaddten:




################################################
## STATICALLY ALLOCATED FUNCTION STACK

.pos 0x2000
stack:

# Static function stack
# Grows upwards (%rbp being the pointer to the top).
.pos 0x10000
fnstack:
# I have this initialized to invalid instructions just so we can see it
# in the simulator
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
.quad 0xC0C0C0C0C0C0C0C0
