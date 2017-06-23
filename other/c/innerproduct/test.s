	.file	"test.c"
	.section	".toc","aw"
	.section	".text"
	.section	.rodata
	.align 3
.LC0:
	.string	"%Lf %Lf"
	.globl __gcc_qmul
	.align 3
.LC1:
	.string	"%lu %Le %Le\n"
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
	stdu 1,-176(1)
	mr 31,1
	addi 10,31,128
	addi 9,31,144
	addis 3,2,.LC0@toc@ha
	addi 3,3,.LC0@toc@l
	mr 4,10
	mr 5,9
	bl __isoc99_scanf
	nop
	addi 9,31,128
	lfd 0,0(9)
	lfd 1,8(9)
	addi 9,31,144
	lfd 12,0(9)
	lfd 13,8(9)
	fmr 2,1
	fmr 1,0
	fmr 3,12
	fmr 4,13
	bl __gcc_qmul
	nop
	fmr 0,1
	fmr 1,2
	addi 9,31,128
	stfd 0,0(9)
	stfd 1,8(9)
	addi 9,31,128
	lfd 0,0(9)
	lfd 1,8(9)
	addi 9,31,144
	lfd 12,0(9)
	lfd 13,8(9)
	fmr 2,1
	fmr 1,0
	fmr 3,12
	fmr 4,13
	bl __gcc_qmul
	nop
	fmr 0,1
	fmr 1,2
	addi 9,31,144
	stfd 0,0(9)
	stfd 1,8(9)
	addi 9,31,128
	lfd 0,0(9)
	lfd 1,8(9)
	addi 9,31,144
	lfd 12,0(9)
	lfd 13,8(9)
	stfd 0,112(31)
	stfd 1,120(31)
	ld 7,112(31)
	ld 8,120(31)
	mr 10,8
	mr 9,7
	mr 7,9
	mr 8,10
	std 7,112(31)
	std 8,120(31)
	lfd 8,112(31)
	lfd 9,120(31)
	std 9,112(31)
	std 10,120(31)
	lfd 0,112(31)
	lfd 1,120(31)
	stfd 12,112(31)
	stfd 13,120(31)
	ld 7,112(31)
	ld 8,120(31)
	mr 10,8
	mr 9,7
	mr 7,9
	mr 8,10
	std 7,112(31)
	std 8,120(31)
	lfd 10,112(31)
	lfd 11,120(31)
	std 9,112(31)
	std 10,120(31)
	lfd 12,112(31)
	lfd 13,120(31)
	addis 3,2,.LC1@toc@ha
	addi 3,3,.LC1@toc@l
	li 4,16
	stfd 8,112(31)
	stfd 9,120(31)
	ld 5,112(31)
	ld 6,120(31)
	fmr 2,1
	fmr 1,0
	stfd 10,112(31)
	stfd 11,120(31)
	ld 7,112(31)
	ld 8,120(31)
	fmr 3,12
	fmr 4,13
	bl printf
	nop
	li 9,0
	mr 3,9
	addi 1,31,176
	ld 0,16(1)
	mtlr 0
	ld 31,-8(1)
	blr
	.long 0
	.byte 0,0,0,1,128,1,0,1
	.size	main,.-.L.main
	.ident	"GCC: (Ubuntu 4.8.2-16ubuntu3) 4.8.2"
