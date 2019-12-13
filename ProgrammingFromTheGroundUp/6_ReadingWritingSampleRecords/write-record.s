

	.include "linux.s"
	.include "record-def.s"


	.section .text

	.globl write_record
	.type write_record @function

write_record:

	# save stack pointer
	pushq %rbp
	movq %rsp, %rbp

	# write record from buffer
	movq $SYS_WRITE, %rax
	movq $RECORD_SIZE, %rdx
	syscall

	# done writing - return number of bytes read as result
	movq %rbp, %rsp
	popq %rbp
	retq
