

	.include "linux.s"
	.include "record-def.s"


	.section .text

	.globl write_record
	.type write_record @function

write_record:

	# write record from buffer
	# %rdi already has FD
	# %rsi already has buffer address
	movq $SYS_WRITE, %rax
	movq $RECORD_SIZE, %rdx
	syscall

	# done writing - return number of bytes read as result
	retq
