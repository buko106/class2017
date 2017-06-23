	.file "snd.ml"
	.section .rodata.cst8,"a",@progbits
	.align	16
caml_negf_mask:	.quad   0x8000000000000000, 0
	.align	16
caml_absf_mask:	.quad   0x7FFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
	.data
	.globl	camlSnd__data_begin
camlSnd__data_begin:
	.text
	.globl	camlSnd__code_begin
camlSnd__code_begin:
	.data
	.quad	1792
	.globl	camlSnd
camlSnd:
	.quad	1
	.data
	.quad	3063
camlSnd__1:
	.quad	camlSnd__snd_1011
	.quad	3
	.text
	.align	16
	.globl	camlSnd__snd_1011
camlSnd__snd_1011:
	.cfi_startproc
.L100:
	movq	8(%rax), %rax
	ret
	.cfi_endproc
	.type	camlSnd__snd_1011,@function
	.size	camlSnd__snd_1011,.-camlSnd__snd_1011
	.text
	.align	16
	.globl	camlSnd__entry
camlSnd__entry:
	.cfi_startproc
.L101:
	movq	camlSnd__1@GOTPCREL(%rip), %rax
	movq	camlSnd@GOTPCREL(%rip), %rbx
	movq	%rax, (%rbx)
	movq	$1, %rax
	ret
	.cfi_endproc
	.type	camlSnd__entry,@function
	.size	camlSnd__entry,.-camlSnd__entry
	.data
	.text
	.globl	camlSnd__code_end
camlSnd__code_end:
	.data
	.globl	camlSnd__data_end
camlSnd__data_end:
	.long	0
	.globl	camlSnd__frametable
camlSnd__frametable:
	.quad	0
	.section .note.GNU-stack,"",%progbits
