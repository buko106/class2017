.text
        .align 2
        .globl make_double
make_double:
        sldi %r3,%r3,63
        sldi %r4,%r4,52
        or %r3,%r3,%r4
        or %r3,%r3,%r5
        std %r3,-8(%r1)
        lfd %f1,-8(%r1)
        blr
