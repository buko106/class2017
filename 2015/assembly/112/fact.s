.text
        .align 2
        .globl fact
fact:
        cmpwi %r3,2
        bge .skip
        li %r3,1
        blr
.skip:
        mflr %r0
        std %r0,16(%r1)
        stdu %r1,-128(%r1)
        std %r3,112(%r1)
        subi %r3,%r3,1
        bl fact
        ld %r4,112(%r1)
        addi %r1,%r1,128
        ld %r0,16(%r1)
        mtlr %r0
        mullw %r3,%r3,%r4
        blr
        
        #int fact(int i(%r3->112)){
        #  if(i<2)return 1
        #  return i(112->%r4)*fact(i-1)
        #}
        #
