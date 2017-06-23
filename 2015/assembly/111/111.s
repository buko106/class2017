	.file	"111.c"
	.section	".toc","aw"
	.section	".text"
	.section	.rodata
	.align 3
.LC0:
	.string	"%lld %lld %lld"
	.align 3
.LC1:
	.string	"%9.9lf\n"
	.align 3
.LC2:
	.string	"sign is less than %lld\nexponent is less than %lld\nfraction is less then %lld\n"
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
	addi 8,31,136
	addi 10,31,144
	addi 9,31,152
	addis 3,2,.LC0@toc@ha
	addi 3,3,.LC0@toc@l
	mr 4,8
	mr 5,10
	mr 6,9
	bl __isoc99_scanf
	nop
	ld 9,136(31)
	cmpdi 7,9,0
	blt 7,.L2
	ld 9,136(31)
	cmpdi 7,9,1
	bgt 7,.L2
	ld 9,144(31)
	cmpdi 7,9,0
	blt 7,.L2
	ld 9,144(31)
	cmpdi 7,9,2047
	bgt 7,.L2
	ld 9,152(31)
	cmpdi 7,9,0
	blt 7,.L2
	ld 10,152(31)
	li 9,-1
	rldicl 9,9,0,12
	cmpd 7,10,9
	bgt 7,.L2
	ld 8,136(31)
	ld 10,144(31)
	ld 9,152(31)
	mr 3,8
	mr 4,10
	mr 5,9
	bl make_double
	nop
	fmr 0,1
	stfd 0,120(31)
	ld 9,120(31)
	mr 10,9
	std 10,112(31)
	lfd 12,112(31)
	std 9,112(31)
	lfd 0,112(31)
	addis 3,2,.LC1@toc@ha
	addi 3,3,.LC1@toc@l
	stfd 12,120(31)
	ld 4,120(31)
	fmr 1,0
	bl printf
	nop
	b .L3
.L2:
	addis 3,2,.LC2@toc@ha
	addi 3,3,.LC2@toc@l
	li 4,2
	li 5,2048
	lis 6,0x10
	sldi 6,6,32
	bl printf
	nop
.L3:
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
	.align 2
	.globl to_double
	.section	".opd","aw"
	.align 3
to_double:
	.quad	.L.to_double,.TOC.@tocbase,0
	.previous
	.type	to_double, @function
.L.to_double:
	std 31,-8(1)
	stdu 1,-64(1)
	mr 31,1
	std 3,112(31)
	lfd 0,112(31)
	fcfid 0,0
	fmr 1,0
	addi 1,31,64
	ld 31,-8(1)
	blr
	.long 0
	.byte 0,0,0,0,128,1,0,1
	.size	to_double,.-.L.to_double
	.ident	"GCC: (Ubuntu 4.8.2-16ubuntu3) 4.8.2"
