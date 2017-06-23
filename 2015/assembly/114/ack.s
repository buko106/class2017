.text
        .align 2
        .globl ack
ack:
        cmpwi 3,0
        beq .L1
        cmpwi 4,0
        beq .L2
        mflr 0
        std 0,16(1)
        stdu 1,-128(1)
        stw 3,112(1)
        subi 4,4,1
        bl ack
        mr 4,3
        lwz 3,112(1)
        subi 3,3,1
        bl ack
        addi 1,1,128
        ld 0,16(1)
        mtlr 0
        blr
.L1:
        addi 3,4,1
        blr
.L2:
        subi 3,3,1
        li 4,1
        mflr 0
        std 0,16(1)
        stdu 1,-128(1)
        bl ack
        addi 1,1,128
        ld 0,16(1)
        mtlr 0
        blr
        
        
#int a(int m(%r3->112),int n(%r4)){
#  if(m==0)return n+1;
#  if(n==0)return a(m-1,1);
#  return a(m-1,a(m,n-1));
#}
