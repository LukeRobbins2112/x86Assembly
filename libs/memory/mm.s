
	.include "mm_helper.s"
	.include "../../includes/linux.s"

#############################	
.section .data
#############################

	.equ MAX_MEM_REQUEST, (1 << 12)

# heap_list pointer	
heap_listp:
	.quad 0

#############################	
.section .text
#############################		

	# @FUNCTION mm_init
	#
	# PURPOSE
	# Set up initial heap, with empty 8 bytes, prologue/epilogue
	#
	# ARGUMENTS
	# No Arguments
	#
	# RETURN VALYE
	# Returns 0 on success, -1 on failure

	.type mm_init @function
mm_init:
	# Get initial program break, save it in heap_listp
	movq $SYS_BRK, %rax
	movq $0, %rdi
	syscall
	movq %rax, heap_listp
	

	# Request memory for initial setup
	movq $WSIZE, %rdi
	imulq $4, %rdi		# (WSIZE * 4)
	callq mem_sbrk

	# check result
	cmpq $-1, %rax
	je mm_init_err

	# set up first word as alignment padding
	movq heap_listp, %rdi
	movq $0, %rsi
	callq PUT

	# compute packed value for prologue header/footer
	movq $DSIZE, %rdi
	movq $ALLOCATED, %rsi
	callq PACK

	# put value in prologue header
	pushq %rax			# save for second call
	movq heap_listp, %rdi
	addq $WSIZE, %rdi
	movq %rax, %rsi
	callq PUT

	# put value in prologue footer

	# heap_listp + (2*WSIZE)
	movq $WSIZE, %rdi
	imulq $2, %rdi
	addq heap_listp, %rdi

	# pop saved PACK'ed value
	popq %rsi
	callq PUT

	# now set up epilogue

	# get packed value
	movq $0, %rdi
	movq $ALLOCATED, %rsi
	callq PACK

	# now set it in position
	movq $WSIZE, %rdi
	imulq $3, %rdi
	addq heap_listp, %rdi
	movq %rax, %rsi
	callq PUT

	# set heap_listp to first "free" position
	# this is the start of the block of the prologue,
	# which is actually empty
	addq $WSIZE, heap_listp
	addq $WSIZE, heap_listp

	# return success
	movq $0, %rax
	retq

mm_init_err:
	movq $-1, %rax
	retq

	# @FUNCTION mem_sbrk()
	#
	# PURPOSE
	# Function like system call sbrk()
	# Given a size, move the program break by that amount
	#
	# ARGUMENTS
	# Arg0 (%rdi): Number of bytes to move the break
	#
	# RETURN
	# Returns pointer to new program break
	# Returns -1 if arg is <= 0, or we get ENOMEM
	#
	# NOTES
	# (1) Call to brk may round up our request,
	# 	so caller should check the actual pointer returned
	# (2) We assume requested amount is aligned (done elsewhere)
	#

	.type mem_sbrk @function
mem_sbrk:
	# check if requested memory is valid amount
	cmpq $0, %rdi
	jle sbrk_err
	cmpq $MAX_MEM_REQUEST, %rdi
	jge sbrk_err

	# save argument
	pushq %rdi
	
	# get current program break
	movq $0, %rdi
	movq $SYS_BRK, %rax
	syscall

	# compute new program break to request (current break + size)
	popq %rdi
	addq %rax, %rdi
	pushq %rdi

	# request new break
	movq $SYS_BRK, %rax
	syscall

	# check if break is less than requested
	# if so, there is an error
	popq %rdi
	cmpq %rdi, %rax
	jl sbrk_err

	# return the new program break
	retq
	
	
	
sbrk_err:
	movq $-1, %rax
	retq
	

	# @FUNCTION extend_heap
	#
	# PURPOSE
	# Provide a wrapper for mem_sbrk
	# Allocate space for a given number of words
	# Perform associated setup and coalescing
	#
	# ARGUMENTS
	# Arg0 (%rdi): Num words requested
	#
	# STACK SPACE
	# (RSP - 4): request size in bytes
	# (RSP - 8): packed size/allocation
	# 
	#
	# RETURN
	# Returns pointer to newly allocated free block
	#

	.type extend_heap @function
extend_heap:

	# stack setup
	pushq %rbp
	movq %rsp, %rbp
	subq $12, %rsp

	# get number of words, check if even or odd
	movq %rdi, %rsi
	andq $0x1, %rsi
	cmpq $0x0, %rsi
	je even_words

	# if result is not zero, words is odd and we must fix that
	addq $1, %rdi
	
even_words:
	# convert words to bytes
	imulq $WSIZE, %rdi
	movl %edi, -4(%rbp)	# save the size

	# num bytes are already in arg0, call mem_sbrk for memory
	callq mem_sbrk

	# check result
	cmpq $-1, %rax
	je extend_heap_err

	# save the block pointer
	movl %eax, -8(%rbp)

initialize_headerfooter:	

	# get packed size/allocation
	movl -4(%rbp), %edi
	movq $FREE, %rsi
	callq PACK
	movl %eax, -12(%rbp)	# save packed value

	# get the block header, put value there
	movl -8(%rbp), %edi
	callq HDRP

	movq %rax, %rdi
	movl -12(%rbp), %esi
	callq PUT

	# get the block footer, put value there
	movl -8(%rbp), %edi
	callq FTRP

	movq %rax, %rdi
	movl -12(%rbp), %esi
	callq PUT

set_new_epilogue:
	# get header of "next" block
	movl -8(%rbp), %edi
	callq NEXT_BLKP

	movq %rax, %rdi
	callq HDRP
	pushq %rax	# save pointer

	movq $0, %rdi
	movq $ALLOCATED, %rsi
	callq PACK

	# put the value
	popq %rsi
	movq %rax, %rsi
	callq PUT
	
coalesce_new_block:	
	# coalesce
	movl -8(%rbp), %edi
	callq coalesce

	# result is in %rax, just return
	retq

extend_heap_err:
	movq $0, %rax
	retq
	



	# @FUNCTION coalesce
	#
	# PURPOSE
	# Given a block pointer, combine it with any adjacent free blocks
	# Can coalesce up, down, both, or none
	#
	# ARGUMENTS
	# Arg0 (%rdi): block pointer to free block
	#
	# RETURN
	# Returns pointer to coalesced block
	#

	.type coalesce @function
coalesce:
	movq %rdi, %rax
	retq
