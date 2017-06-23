.text
        .align 2
        .globl innerproduct
innerproduct:
        li     %r6,0
        std    %r6,-8(%r1)     #   uint64_t i = 0
        lfd    %f1,-8(%r1)     #   double ans = 0.0 (%f1)
.L1:    
        cmpd   %r6,%r5         #   i < n
        bgelr                  #   return ans
        sldi   %r7,%r6,3       #   %r8 = 8*i
        lfdx   %f2,%r3,%r7     #   a[i]
        lfdx   %f3,%r4,%r7     #   b[i]
        fmadd  %f1,%f2,%f3,%f1 #   ans += a[i]*b[i]
        addi   %r6,%r6,1
        b      .L1

        # double innerproduct( double * , double * , uint64_t )
        #
        # double innerproduct (*a(%r3),*b(%r4) , n(%r5)){
        #   double ans = 0.0 (%f1)
        #   uint64_t i (%r6)
        #   for( i = 0  ,  i < n ,  ++ i){
        #     ans += a[i](%f2) + b[i](%f3)
        #   }
        #   return (%f1)
        # }
        #
        #
        
