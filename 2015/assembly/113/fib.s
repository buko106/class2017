.text
        .align 2
        .globl fib
fib:
        cmpwi 3,2
        bge skip
        blr
skip:
        mflr 0
        std 0,16(1)
        stdu 1,-128(1)
        stw 3,112(1)
        subi 3,3,1
        bl fib
        stw 3,116(1)
        lwz 3,112(1)
        subi 3,3,2
        bl fib
        lwz 4,116(1)
        addi 1,1,128
        ld 0,16(1)
        mtlr 0
        add 3,3,4
        blr

        #int fib_c(int i(%r3->112)){
        #if(i<2)return i;
        #return fib(i-1)(->116->%r4)+fib(i-2);
        #}
