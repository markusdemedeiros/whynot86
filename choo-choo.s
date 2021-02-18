# Uh oh! Somebody let at runaway train onto the stack! 
irmovq 0x2000, %rsp
irmovq 32, %rbx
irmovq 0x1FE0, %rax

irmovq 0xA0AFA09FA0101010, %r12   
irmovq 0x3800403061CFA0BF, %r11
irmovq 0x7000000000000000, %r10
irmovq 0x000000C4000000C4, %r9 #C4000000 C4000000 = CHOOOOOO CHOOOOOO!
pushq %r9
pushq %r10
pushq %r11
pushq %r12
jmp 0x1FE0

# Just here so we can look at the stack
.pos 0x2000

