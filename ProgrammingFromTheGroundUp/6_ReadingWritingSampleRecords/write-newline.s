
	.include "linux.s"

##########################################
.section .data
##########################################	

newline:
	.ascii "\n"

##########################################
.section .text
##########################################

	.equ FILE_DESC, 16
	
	.globl write_newline
	.type write_newline @function
write_newline:

	pushq %rbp
	movq %rsp, %rbp

	movq $SYS_WRITE, %rax
	movq FILE_DESC(%rbp), %rdi
	movq $newline, %rsi
	movq $1, %rdx
	syscall

	# restore stack
	movq %rbp, %rsp
	popq %rbp
	retq
	
