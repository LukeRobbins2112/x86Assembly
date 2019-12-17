
	.include "linux.s"

##########################################
.section .data
##########################################	

newline:
	.ascii "\n"

##########################################
.section .text
##########################################

	.globl write_newline
	.type write_newline @function
write_newline:

	pushq %rbp
	movq %rsp, %rbp

	movq $SYS_WRITE, %rax
	movq $newline, %rsi
	movq $1, %rdx
	syscall

	# restore stack
	movq %rbp, %rsp
	popq %rbp
	retq
	
