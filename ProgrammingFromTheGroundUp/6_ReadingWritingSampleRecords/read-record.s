

	.include "linux.s"
	.include "record-def.s"


	.section .text

	.equ INPUT_FD, 16
	.equ READ_BUF, 24

	.globl read_record
	.type read_record @function

read_record:

	# save stack pointer
	pushq %rbp
	movq %rsp, %rbp

	# read record into buffer
	movq $SYS_READ, %rax
	movq INPUT_FD(%rbp), %rdi
	movq READ_BUF(%rbp), %rsi
	movq $RECORD_SIZE, %rdx
	syscall

	# done reading - return number of bytes read as result
	movq %rbp, %rsp
	popq %rbp
	retq
