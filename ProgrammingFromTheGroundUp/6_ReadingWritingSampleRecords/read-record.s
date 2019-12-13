

	.include "linux.s"
	.include "record-def.s"


	.section .text

	.globl read_record
	.type read_record @function

	#
	# ARGS
	# Arg 0 (%rdi): Input FD 
	# Arg 1 (%rsi): Read buffer
read_record:

	# read record into buffer
	# %rdi is already set to FD
	# %rsi is already set to buffer address
	movq $SYS_READ, %rax
	movq $RECORD_SIZE, %rdx
	syscall

	# done reading - return number of bytes read as result
	retq
