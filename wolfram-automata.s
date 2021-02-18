# Cellular Automata within a single register! 

irmovq seed, %rax
mrmovq 0(%rax), %rax  # rax = latest iteration
irmovq rule, %r8
mrmovq 0x0(%r8), %r8    # r8 = rule

# Start:
irmovq 0x7, %rdi    # %rdi = bitmask (starting a low bits)
irmovq 0x1, %rsi    # %rsi = number we have to divide by to get value (index)
irmovq 0x2000000000000000, %r14 # r14 = stopping condition on index
irmovq 0x2, %r12    # %r12 = constant 2
irmovq 0x1, %r9     # %r9 = constant 1
xorq %rbx, %rbx     # %rbx = 0 = next iteration (in progress)
irmovq 0x4000000000000000, %rdx # Position mask (Leave off sign bit at the left)

bit_loop:
# Grab the right part of the last iteration
rrmovq %rax, %r13   # r13 = last complete iteration
andq %rdi, %r13     # r13 = masked out bits
divq %rsi, %r13     # r13 = masked out bits as an integer

# Compute the result of the automata by shifting the rule
rrmovq %r8, %rcx    # rcx = rule 
andq %r13, %r13     # Set CC's based on %r13
shl_loop:
je shl_loop_end     # If r13 is 0 we want the lowest bit of %rcx
divq %r12, %rcx     # Shift off the last bit of rcx
subq %r9, %r13      # decrement %r13
jmp shl_loop      
shl_loop_end:

# Place computed bit (lowest bit of %rcx) in the right spot in %rbx
andq %r9, %rcx      # Mask last bit of %rcx
mulq %rdx, %rcx     # Position rcx in the right spot
addq %rcx, %rbx     # Add computed bit to %rbx
divq %r12, %rbx     # Shift right rdx

# Check to see if loop should end
mulq %r12, %rdi     # Shift bitmask by one bit
mulq %r12, %rsi     # Multiply index by 2
subq %rsi, %r14     # r14 = r14 - rsi
jg bit_loop         # return to start if stopping condition not met

# rbx contains the correct next iteration! 
halt

.pos 0x4000
rule:
    .quad 0x1E          # Rule 30 :)

.pos 0x5000
# Since we can't really put breakpoints it's easiest to just run the program a couple times 
# advancing the offset on %rax by hand
seed:
    .quad 0x0000000100000000    # Seed
    .quad 0x0000000380000000    # iteration 1
    .quad 0x0000000DE0000000    # iteration 2
    .quad 0x0000001910000000    # ...
    .quad 0x00000037B8000000
    .quad 0x0000006424000000
    .quad 0x000000DE7E000000
    .quad 0x00000191C1000000
    .quad 0x0000037B23800000
    .quad 0x00000642F6400000
    
# Running these through a little python program to format them nicely in
# binary gives the picture: 
# 00000000 00000000 00000000 00000001 00000000 00000000 00000000 00000000
# 00000000 00000000 00000000 00000011 10000000 00000000 00000000 00000000
# 00000000 00000000 00000000 00001101 11100000 00000000 00000000 00000000
# 00000000 00000000 00000000 00011001 00010000 00000000 00000000 00000000
# 00000000 00000000 00000000 00110111 10111000 00000000 00000000 00000000
# 00000000 00000000 00000000 01100100 00100100 00000000 00000000 00000000
# 00000000 00000000 00000000 11011110 01111110 00000000 00000000 00000000
# 00000000 00000000 00000001 10010001 11000001 00000000 00000000 00000000
# 00000000 00000000 00000011 01111011 00100011 10000000 00000000 00000000
# 00000000 00000000 00000110 01000010 11110110 01000000 00000000 00000000


