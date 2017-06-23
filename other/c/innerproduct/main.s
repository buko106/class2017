	.file	"main.c"
	.section	".toc","aw"
	.section	".text"
	.comm	a,160000,8
	.comm	b,160000,8
	.section	.rodata
	.align 3
.LC3:
	.string	"N=%llu\nans=%.10le\ntime(s)=%.10le\n"
	.section	".toc","aw"
.LC0:
	.quad	a
.LC1:
	.quad	b
.LC2:
	.quad	0x408f400000000000
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
	stdu 1,-208(1)
	mr 31,1
	li 9,20000
	std 9,144(31)
	li 3,0
	bl time
	nop
	mr 9,3
	rldicl 9,9,0,32
	mr 3,9
	bl srand
	nop
	li 9,0
	stw 9,140(31)
	b .L2
.L3:
	bl rand
	nop
	mr 9,3
	extsw 9,9
	std 9,120(31)
	lfd 0,120(31)
	fcfid 0,0
	addis 9,2,.LC0@toc@ha
	ld 10,.LC0@toc@l(9)
	lwz 9,140(31)
	extsw 9,9
	sldi 9,9,3
	add 9,10,9
	stfd 0,0(9)
	bl rand
	nop
	mr 9,3
	extsw 9,9
	std 9,120(31)
	lfd 0,120(31)
	fcfid 0,0
	addis 9,2,.LC1@toc@ha
	ld 10,.LC1@toc@l(9)
	lwz 9,140(31)
	extsw 9,9
	sldi 9,9,3
	add 9,10,9
	stfd 0,0(9)
	lwz 9,140(31)
	addi 9,9,1
	stw 9,140(31)
.L2:
	lwz 9,140(31)
	extsw 10,9
	ld 9,144(31)
	cmpld 7,10,9
	blt 7,.L3
	addi 9,31,160
	mr 3,9
	li 4,0
	bl gettimeofday
	nop
	addis 10,2,.LC0@toc@ha
	ld 3,.LC0@toc@l(10)
	addis 9,2,.LC1@toc@ha
	ld 4,.LC1@toc@l(9)
	ld 5,144(31)
	bl innerproduct
	nop
	stfd 1,152(31)
	addi 9,31,176
	mr 3,9
	li 4,0
	bl gettimeofday
	nop
	ld 10,176(31)
	ld 9,160(31)
	subf 9,9,10
	std 9,120(31)
	lfd 0,120(31)
	fcfid 12,0
	ld 10,184(31)
	ld 9,168(31)
	subf 9,9,10
	std 9,120(31)
	lfd 0,120(31)
	fcfid 11,0
	addis 10,2,.LC2@toc@ha
	lfd 0,.LC2@toc@l(10)
	fdiv 11,11,0
	addis 9,2,.LC2@toc@ha
	lfd 0,.LC2@toc@l(9)
	fdiv 0,11,0
	fadd 0,12,0
	lfd 10,152(31)
	lfd 11,152(31)
	stfd 0,112(31)
	ld 9,112(31)
	mr 10,9
	std 10,120(31)
	lfd 12,120(31)
	std 9,120(31)
	lfd 0,120(31)
	addis 3,2,.LC3@toc@ha
	addi 3,3,.LC3@toc@l
	ld 4,144(31)
	stfd 10,112(31)
	ld 5,112(31)
	fmr 1,11
	stfd 12,112(31)
	ld 6,112(31)
	fmr 2,0
	bl printf
	nop
	li 9,0
	mr 3,9
	addi 1,31,208
	ld 0,16(1)
	mtlr 0
	ld 31,-8(1)
	blr
	.long 0
	.byte 0,0,0,1,128,1,0,1
	.size	main,.-.L.main
	.section	".toc","aw"
.LC4:
	.quad	0x000000000
	.section	".text"
	.align 2
	.globl dot
	.section	".opd","aw"
	.align 3
dot:
	.quad	.L.dot,.TOC.@tocbase,0
	.previous
	.type	dot, @function
.L.dot:
	std 31,-8(1)
	stdu 1,-80(1)
	mr 31,1
	std 3,128(31)
	std 4,136(31)
	std 5,144(31)
	addis 9,2,.LC4@toc@ha
	lfd 0,.LC4@toc@l(9)
	stfd 0,56(31)
	li 9,0
	std 9,48(31)
	b .L6
.L7:
	ld 9,48(31)
	sldi 9,9,3
	ld 10,128(31)
	add 9,10,9
	lfd 12,0(9)
	ld 9,48(31)
	sldi 9,9,3
	ld 10,136(31)
	add 9,10,9
	lfd 0,0(9)
	fmul 0,12,0
	lfd 12,56(31)
	fadd 0,12,0
	stfd 0,56(31)
	ld 9,48(31)
	addi 9,9,1
	std 9,48(31)
.L6:
	ld 10,48(31)
	ld 9,144(31)
	cmpld 7,10,9
	blt 7,.L7
	lfd 0,56(31)
	fmr 1,0
	addi 1,31,80
	ld 31,-8(1)
	blr
	.long 0
	.byte 0,0,0,0,128,1,0,1
	.size	dot,.-.L.dot
	.ident	"GCC: (Ubuntu 4.8.2-16ubuntu3) 4.8.2"
