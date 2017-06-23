.text
        .align 2
        .globl max
max:
        std 3,-8(1)
        std 4,-16(1)
        ld 3,-8(1)
        ld 4,-16(1)
        cmpd 3,4
        bge skip
        mr 3,4
skip:   
        blr
       
