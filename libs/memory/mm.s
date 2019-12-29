
	.include "mm_helper.s"
	.include "../../includes/linux.s"

#############################	
.section .data
#############################

	.equ MAX_MEM_REQUEST, (1 << 12)

# heap pointers
mem_heap:
	.quad 0
mem_brk:
	.quad 0
	
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
	# also save it in mem_heap and mem_brk for reference throughout prog
	movq $SYS_BRK, %rax
	movq $0, %rdi
	syscall
	movq %rax, heap_listp
	movq %rax, mem_heap
	movq %rax, mem_brk
	

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
	# (2) We assume requested amount is aligned (done elsewhere)
	#

	.type mem_sbrk @function
mem_sbrk:
	# check if requested memory is valid amount
	cmpq $0, %rdi
	jle sbrk_err
	cmpq $MAX_MEM_REQUEST, %rdi
	jge sbrk_err

	# save old program break
	pushq mem_brk
	
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

	# if successful, save new program break in global var
	movq %rax, mem_brk

	# return the **OLD** program break
	popq %rax
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
	# (RSP - 16): block pointer from mem_sbrk (** 8 bytes! **)
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
	subq $16, %rsp

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
	movq %rax, -16(%rbp)

initialize_headerfooter:	

	# get packed size/allocation
	movl -4(%rbp), %edi
	movq $FREE, %rsi
	callq PACK
	movl %eax, -8(%rbp)	# save packed value

	# get the block header, put value there
	# remember, the returned block pointer is the old
	# program break, so HDRP returns address of old epilogue
	movq -16(%rbp), %rdi
	callq HDRP

	movq %rax, %rdi
	movl -8(%rbp), %esi
	callq PUT

	# get the block footer, put value there
	movq -16(%rbp), %rdi
	callq FTRP

	movq %rax, %rdi
	movl -8(%rbp), %esi
	callq PUT

set_new_epilogue:
	# get header of "next" block
	movq -16(%rbp), %rdi
	callq NEXT_BLKP

	movq %rax, %rdi
	callq HDRP
	pushq %rax	# save pointer

	movq $0, %rdi
	movq $ALLOCATED, %rsi
	callq PACK

	# put the value
	popq %rdi
	movq %rax, %rsi
	callq PUT
	
coalesce_new_block:	
	# coalesce
	movq -16(%rbp), %rdi
	callq coalesce

	# result is in %rax, just reset stack and return
	movq %rbp, %rsp
	popq %rbp
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


	# @FUNCTION find_fit
	#
	# PURPOSE
	# Look for a block in which the given size will fit
	#
	# ARGUMENTS
	# Arg0 (%rdi): Given size for which we need a block
	#
	# STACK
	# (%rbp - 8): Save the size given as arg
	# (%rbp - 16): fitPtr
	# (%rbp - 24): HDRP(fitPtr)
	#
	# RETURN
	# Returns block pointer to proper block on success
	# Returns NULL on failure
	#

	.type find_fit @function
find_fit:
	# stack setup
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp

	# save arg
	movq %rdi, -8(%rbp)

	# copy heap_listp to fitPtr
	movq heap_listp, %rsi
	movq %rsi, -16(%rbp)

find_fit_loop:
	# get fitPtr header
	movq -16(%rbp), %rdi
	callq HDRP
	movq %rax, -24(%rbp)

	# get block size
	movq %rax, %rdi
	callq GET_SIZE

	# check loop condition
	cmpq $0, %rax
	je find_fit_done

	# check if size is big enough
	cmpq -8(%rbp), %rax
	jl find_fit_next

	# check if block is allocated
	movq -24(%rbp), %rdi
	callq GET_ALLOC

	cmpq $FREE, %rax
	jne find_fit_next

	# if both passed, we found it
	movq -16(%rbp), %rax
	jmp find_fit_done

find_fit_next:
	movq -16(%rbp), %rdi
	callq NEXT_BLKP
	movq %rax, -16(%rbp)
	jmp find_fit_loop

fit_not_found:
	movq $0, %rax
	
find_fit_done:
	movq %rbp, %rsp
	popq %rbp
	ret

	# @FUNCTION place
	#
	# PURPOSE
	# Once an appropriate chunk of memory is found,
	# this function sets it up for use
	# This may involve splitting the block, depending
	# on its size
	# In either case, it sets the header/footer metadata
	#
	# ARGUMENTS
	# Arg0 (%rdi): The block pointer itself
	# Arg1 (%rsi): THe size of the requested memory
	#
	# STACK
	# -8(%rbp): block pointer arg
	# -16(%rbp): size arg
	# -24(%rbp): old block size
	#
	# RETURN
	# No return value
	#

	.type place @function
place:
	# stack setup
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp

	# save block pointer and size args
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	
	# get size of existing free block
	# block pointer is already in %rdi
	# save old size on the stack
	callq HDRP
	movq %rax, %rdi
	callq GET_SIZE
	movq %rax, -24(%rbp)

	# check to see if we're splitting the block
	# size + (2*DSIZE) -- aka will remainder be minimum block size
	addq $DSIZE, %rsi
	addq $DSIZE, %rsi

	cmpq %rsi, -24(%rbp)
	jl place_no_split

	# Split the block, save the rest
place_split:

	# set up packed val
	movq -16(%rbp), %rdi
	movq $ALLOCATED, %rdi
	callq PACK
	movq %rax, %rbx

	### Set up requested block chunk ###

	# get bp header
	movq -8(%rbp), %rdi
	callq HDRP

	# mark as allocated
	movq %rax, %rdi
	movq %rbx, %rsi
	callq PUT

	# get bp footer
	movq -8(%rbp), %rdi
	callq FTRP

	# mark as allocated
	movq %rax, %rdi
	movq %rbx, %rsi
	callq PUT

	### Now set up the remainder ###

	# get packed size for remainder
	# (prevSize - size) | 0x0
	movq -24(%rbp), %rdi
	subq -16(%rbp), %rdi
	movq $FREE, %rsi
	callq PACK
	movq %rax, %rbx

	# get NEXT_BLKP of allocated chunk
	movq -8(%rbp), %rdi
	callq NEXT_BLKP
	movq %rax, %r8

	# PUT free block header
	movq %rax, %rdi
	callq HDRP
	movq %rax, %rdi
	movq %rbx, %rsi
	callq PUT

	# PUT free block footer
	movq %r8, %rdi
	callq FTRP
	movq %rax, %rdi
	movq %rbx, %rsi
	callq PUT

	jmp place_end

place_no_split:
	# get packed val
	movq -24(%rbp), %rdi
	movq $ALLOCATED, %rsi
	callq PACK
	movq %rax, %rbx

	# get bp header
	movq -8(%rbp), %rdi
	callq HDRP

	# mark as allocated
	movq %rax, %rdi
	movq %rbx, %rsi
	callq PUT

	# get bp footer
	movq -8(%rbp), %rdi
	callq FTRP

	# mark as allocated
	movq %rax, %rdi
	movq %rbx, %rsi
	callq PUT
	
place_end:
	movq %rbp, %rsp
	popq %rbp
	retq
