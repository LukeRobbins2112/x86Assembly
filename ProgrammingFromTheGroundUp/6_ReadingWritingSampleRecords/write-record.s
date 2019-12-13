

	.include "linux.s"
	.include "record-def.s"


	.section .text

	.equ OUTPUT_FD, 16
	.equ WRITE_BUF, 24

	.globl write_record
	.type write_record @function

write_record:

	# save stack pointer
	pushq %rbp
	movq %rsp, %rbp

	# write record from buffer
	movq $SYS_WRITE, %rax
	movq OUTPUT_FD(%rbp), %rdi
	movq WRITE_BUF(%rbp), %rsi
	movq $RECORD_SIZE, %rdx
	syscall

	# done writing - return number of bytes read as result
	movq %rbp, %rsp
	popq %rbp
	retq
