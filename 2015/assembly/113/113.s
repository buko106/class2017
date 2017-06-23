	.file	"113.c"
	.section	".toc","aw"
	.section	".text"
	.align 2
	.globl fib_c
	.section	".opd","aw"
	.align 3
fib_c:
	.quad	.L.fib_c,.TOC.@tocbase,0
	.previous
	.type	fib_c, @function
.L.fib_c:
	mflr 0
	std 0,16(1)
	std 30,-16(1)
	std 31,-8(1)
	stdu 1,-128(1)
	mr 31,1
	mr 9,3
	stw 9,176(31)
	lwz 9,176(31)
	cmpwi 7,9,1
	bgt 7,.L2
	lwz 9,176(31)
	extsw 9,9
	b .L3
.L2:
	lwz 9,176(31)
	addi 9,9,-1
	extsw 9,9
	mr 3,9
	bl fib
	nop
	mr 9,3
	mr 30,9
	lwz 9,176(31)
	addi 9,9,-2
	extsw 9,9
	mr 3,9
	bl fib
	nop
	mr 9,3
	add 9,30,9
	extsw 9,9
.L3:
	mr 3,9
	addi 1,31,128
	ld 0,16(1)
	mtlr 0
	ld 30,-16(1)
	ld 31,-8(1)
	blr
	.long 0
	.byte 0,0,0,1,128,2,0,1
	.size	fib_c,.-.L.fib_c
	.section	.rodata
	.align 3
.LC0:
	.string	"%d %d"
	.align 3
.LC1:
	.string	"%d\n"
	.section	".text"
	.align 2
	.globl main
	.section	".opd","aw"
	.align 3
main:
	.quad	.L.main,.TOC.@tocbase,0
	.previous
	.type	main, @function
.L.main:
	mflr 0
	std 0,16(1)
	std 31,-8(1)
	stdu 1,-144(1)
	mr 31,1
	addi 10,31,116
	addi 9,31,120
	addis 3,2,.LC0@toc@ha
	addi 3,3,.LC0@toc@l
	mr 4,10
	mr 5,9
	bl __isoc99_scanf
	nop
	li 9,0
	stw 9,124(31)
	b .L5
.L8:
	lwz 9,120(31)
	extsw 9,9
	cmpdi 7,9,0
	beq 7,.L6
	lwz 9,124(31)
	extsw 9,9
	mr 3,9
	bl fib
	nop
	mr 9,3
	addis 3,2,.LC1@toc@ha
	addi 3,3,.LC1@toc@l
	mr 4,9
	bl printf
	nop
	b .L7
.L6:
	lwz 9,124(31)
	extsw 9,9
	mr 3,9
	bl fib_c
	mr 9,3
	addis 3,2,.LC1@toc@ha
	addi 3,3,.LC1@toc@l
	mr 4,9
	bl printf
	nop
.L7:
	lwz 9,124(31)
	addi 9,9,1
	stw 9,124(31)
.L5:
	lwz 9,116(31)
	extsw 9,9
	lwz 10,124(31)
	cmpw 7,10,9
	ble 7,.L8
	li 9,0
	mr 3,9
	addi 1,31,144
	ld 0,16(1)
	mtlr 0
	ld 31,-8(1)
	blr
	.long 0
	.byte 0,0,0,1,128,1,0,1
	.size	main,.-.L.main
	.ident	"GCC: (Ubuntu 4.8.2-16ubuntu3) 4.8.2"
