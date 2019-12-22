
	.include "mm_helper.s"

#############################	
.section .data
#############################		

INT_PTR:
	.long 123

	
#############################	
.section .text
#############################		

	.globl _start
_start:
	# test MAX
	movq $3, %rdi
	movq $2, %rsi
	callq MAX

	# test PACK
	movq $0x0, %rdi
	callq PACK

	# test GET
	movq $INT_PTR, %rdi
	callq GET

	movq $0, %rdi
	movq $60, %rax
	syscall
