	.file	"test.c"
	.section	".toc","aw"
	.section	".text"
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
	addi 10,31,120
	addi 9,31,124
	addis 3,2,.LC0@toc@ha
	addi 3,3,.LC0@toc@l
	mr 4,10
	mr 5,9
	bl __isoc99_scanf
	nop
	lwz 9,120(31)
	extsw 10,9
	lwz 9,124(31)
	extsw 9,9
	mr 3,10
	mr 4,9
	bl max
	nop
	mr 9,3
	addis 3,2,.LC1@toc@ha
	addi 3,3,.LC1@toc@l
	mr 4,9
	bl printf
	nop
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
