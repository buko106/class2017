.text
        .align 2
        .globl mul128
mul128:
        ld 6,0(3)
        ld 7,8(3)
        ld 8,0(4)
        ld 9,8(4)
        mulld 10,7,9
        std 10,8(5)
        mulhdu 10,7,9
        mulld 11,6,9
	add 10,10,11
        mulld 11,7,8
        add 10,10,11
        std 10,0(5)
        blr
        
        #a[0]->%r6
        #a[1]->%r7
        #b[0]->%r8
        #b[1]->%r9
        #a[1]*b[1](LOW)->%r10->c[1]
        #a[1]*b[1](HIGH)->%r10
        #a[0]*b[1](LOW)(->%r11) + %r10 -> %r10
        #a[1]*b[0](LOW)(->%r11) + %r10 -> %r10
        #%r10 -> c[0]
