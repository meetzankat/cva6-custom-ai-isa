.section .text
.global _start
_start:
    # x1 = packed INT8: [1,2,3,4,1,2,3,4]
    li x1, 0x01020304
    slli x1, x1, 32
    li x2, 0x01020304
    add x1, x1, x2

    # x2 = same value
    li x2, 0x01020304
    slli x2, x2, 32
    li x5, 0x01020304
    add x2, x2, x5

    # VDOT x3, x1, x2
    # funct7=0000000 rs2=x2(00010) rs1=x1(00001) funct3=000 rd=x3(00011) opcode=0001011
    .word 0x0020818B

    # Expected result = 1+4+9+16+1+4+9+16 = 60
    li x4, 60
    beq x3, x4, pass
fail:
    li x1, 3
    la x2, tohost
    sd x1, 0(x2)
    j fail
pass:
    li x1, 1
    la x2, tohost
    sd x1, 0(x2)
    j pass

.section ".tohost","aw",@progbits
.align 3
.global tohost
.type tohost, @object
.size tohost, 8
tohost: .dword 0
.global fromhost
.type fromhost, @object
.size fromhost, 8
fromhost: .dword 0
