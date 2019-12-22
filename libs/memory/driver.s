
	.include "mm_helper.s"
	
#############################	
.section .data
#############################		

INT_PTR:
	.long 123
INT_VAL:
	.long 321
	
#############################	
.section .bss
#############################			

	# sample block
	# 4-byte header, 4-byte footer, 8 bytes memory
	.lcomm TEST_BLOCK, 16
	
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

	# test PUT
	movq $INT_PTR, %rdi
	movq $321, %rsi
	callq PUT

	# test GET_SIZE
	movq $INT_PTR, %rdi
	callq GET_SIZE

	# test GET_ALLOC
	movq $INT_PTR, %rdi
	callq GET_ALLOC

	# set up test block
	movq $TEST_BLOCK, %rdi
	movq $16, %rsi
	callq PUT

	movq $TEST_BLOCK, %rdi
	addq $12, %rdi
	movq $16, %rsi
	callq PUT
	
	# test HDRP
	movq $TEST_BLOCK, %rdi
	addq $4, %rdi
	callq HDRP

	# test FTRP
	movq $TEST_BLOCK, %rdi
	addq $4, %rdi
	callq FTRP

	movq $0, %rdi
	movq $60, %rax
	syscall
