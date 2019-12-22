
	.include "mm_helper.s"

	.section .text

	.globl _start
_start:
	# test MAX
	movq $3, %rdi
	movq $2, %rsi
	callq MAX

	# test PACK
	movq $0x0, %rdi
	callq PACK

	movq $0, %rdi
	movq $60, %rax
	syscall
