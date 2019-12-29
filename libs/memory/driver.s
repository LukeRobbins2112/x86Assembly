
#	.include "mm_helper.s"
	.include "mm.s"
	
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

	# *** These sample blocks are contiguous in memory ***
	
	# sample previous block
	.lcomm PREV_BLOCK, 16
	
	# "current" sample block
	# 4-byte header, 4-byte footer, 8 bytes memory
	.lcomm TEST_BLOCK, 16

	# next sample block
	.lcomm NEXT_BLOCK, 16
	
#############################	
.section .text
#############################		

	.globl _start
_start:
	# jmp basic_tests

	# initialize heap
	callq mm_init

	# test extend_heap
	movq $7, %rdi
	callq extend_heap

	# test find_fit
	movq $16, %rdi
	callq find_fit

	# test mem_sbrk
	movq $256, %rdi
	callq mem_sbrk


	movq $0, %rdi
	movq $60, %rax
	syscall


basic_tests:	
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

	# setup test block
	movq $TEST_BLOCK, %rdi
	movq $16, %rsi
	movq $0, %rdx
	callq setup_block

	# setup prev block
	movq $PREV_BLOCK, %rdi
	movq $16, %rsi
	movq $0, %rdx
	callq setup_block

	# setup next_block
	movq $NEXT_BLOCK, %rdi
	movq $16, %rsi
	movq $0, %rdx
	callq setup_block
	
	# test HDRP
	movq $TEST_BLOCK, %rdi
	addq $4, %rdi
	callq HDRP

	# test FTRP
	movq $TEST_BLOCK, %rdi
	addq $4, %rdi
	callq FTRP

	# test NEXT_BLKP
	movq $TEST_BLOCK, %rdi
	addq $4, %rdi
	callq NEXT_BLKP

	

	# @FUNCTION
	#
	# PURPOSE
	# Helper function to set up test blocks
	#
	# ARGUMENTS
	# Arg0 (%rdi): Block poiner
	# Arg1 (%rsi): Size of the block
	# Arg2 (%rdx): WHether the block is allocated (0 or 1)
	#
	# RETURN
	# No return value
	#

	.equ blk_size, -8
	.equ blk_ptr, -16
	.equ packed_val, -24
	
	.type setup_block @function
setup_block:

	# prepare stack
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	
	# save size, block ptr for later reference
	movq %rdi, blk_ptr(%rbp)
	movq %rsi, blk_size(%rbp)
	
	# pack size | alocated
	# then save that value on the stack
	movq blk_size(%rbp), %rdi
	movq %rdx, %rsi
	callq PACK
	movq %rax, packed_val(%rbp)
	
	# put PACK'ed value in header
	movq blk_ptr(%rbp), %rdi
	movq %rax, %rsi
	callq PUT

	# Get footer
	movq blk_ptr(%rbp), %rdi
	addq $WSIZE, %rdi
	callq FTRP

	# Set footer
	movq %rax, %rdi
	movq packed_val(%rbp), %rsi
	callq PUT

	# return block pointer
	movq blk_ptr(%rbp), %rax
	addq $WSIZE, %rax

	# restrore stack
	movq %rbp, %rsp
	popq %rbp
	ret

	

	

	
