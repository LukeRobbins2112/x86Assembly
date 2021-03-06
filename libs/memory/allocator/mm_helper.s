
.include "mm_constants.s"
	
#########################	
.section .text
#########################

	#
	# @FUNCTION MAX
	#

	.global MAX
	.type MAX @function
MAX:
	cmpq %rdi, %rsi
	jge MAX_SECOND
	movq %rdi, %rax
	ret
MAX_SECOND:
	movq %rsi, %rax
	ret
	


	# @FUNCTION PACK
	#
	# PURPOSE
	# Combine size and allocation bit into a single word
	#
	# ARGUMENTS
	# Arg0 (%rdi): block size
	# Arg1 (%rsi): alloc bit
	#
	# RETURN
	# Packed combination of size and alloc bit

	.global PACK
	.type PACK @function
PACK:
	movl %edi, %eax
	orl %esi, %eax
	ret

	#
	# @FUNCTION GET
	#
	# PURPOSE
	# Get integer value at the given address
	#
	# ARGUMENTS
	# ARG0 (%rdi): the pointer to dereference
	#
	# RETURN
	# The value at that address
	#

	.global GET
	.type GET @function
GET:
	movl (%rdi), %eax
	ret

	#
	# @FUNCTION PUT
	#
	# PURPOSE
	# Set the given address to the desired value
	#
	# ARGUMENTS
	# Arg0 (%rdi): Address to set
	# Arg1 (%rsi): Value to put at address
	#
	# RETURN
	# No return value
	# @TODO might be nice to get original value at that addr?
 	#

	.global PUT
	.type PUT @function
PUT:
	movl %esi, (%rdi)
	ret

	# @FUNCTION
	#
	# PURPOSE
	# Get the size of a block by examining the size
	# value of the header, ignoring the ALLOC bit
	#
	# ARGUMENTS
	# Arg0 (%rdi): Pointer to the block header
	#
	# RETURN
	# Returns block size

	.global GET_SIZE
	.type GET_SIZE @function
GET_SIZE:
	# ptr is already in %rdi, just call GET
	callq GET

	# take result and AND with ~0x7 to clear low 3 bits
	andq $~0x7, %rax

	# result is in %rax already, just return
	ret

	
	# @FUNCTION
	#
	# PURPOSE
	# Check bit to determine if block is allocated
	#
	# ARGUMENT
	# Pointer to block header
	#
	# Return value
	# Returns result of low bit check
	#

	.global GET_ALLOC
	.type GET_ALLOC @function
GET_ALLOC:	
	# ptr is already in %rdi, just call GET
	callq GET

	# take result and AND with 0x1 to check if allocated
	andq $0x1, %rax

	# result is in %rax already, just return
	ret


	# @FUNCTION
	#
	# PURPOSE
	# Given a block pointer, retrieve a pointer to its header
	#
	# ARGUMENTS
	# ARG0 (%rsi): BLock pointer
	#
	# RETURN
	# Return pointer to the block header
	#

	.global HDRP
	.type HDRP @function
HDRP:
	movq %rdi, %rax
	subq $WSIZE, %rax
	ret

	# @FUNCTION
	#
	# PURPOSE
	# Given a block pointer, retrieve a pointer to its footer
	#
	# ARGUMENTS
	# ARG0 (%rsi): BLock pointer
	#
	# RETURN
	# Return pointer to the block footer
	#

	.global FTRP
	.type FTRP @function
FTRP:
	# save original block pointer
	pushq %rdi
	
	# get header (bp is already in %rdi)
	callq HDRP
	
	# pointer to header is in %rax
	# use that to get size
	movq %rax, %rdi
	callq GET_SIZE

	# retrieve block pointer
	popq %rdi

	# add block size, to get pointer to next block
	addq %rdi, %rax 

	# subtract DSIZE to get footer pointer
	subq $DSIZE, %rax

	# return footer pointer
	ret

	# @FUNCTION
	#
	# PURPOSE
	# Get pointer to the beginning of next block pointer
	#
	# ARGUMENTS
	# ARG0 (%rdi): Current block pointer
	#
	# RETURN
	# Next block pointer
	#

	.global NEXT_BLKP
	.type NEXT_BLKP @function
NEXT_BLKP:
	# save bp
	pushq %rdi
	
	# get current block header (bp is already in %rdi)
	callq HDRP

	# get size of current block, using header
	movq %rax, %rdi
	callq GET_SIZE

	# retrieve bp
	popq %rdi

	# combine pointer and size to get next
	# (bp + size) = (next_bp + 4 extra bytes for footer)
	# then subtract those 4 extra bytes to get start of next_bp
	addq %rdi, %rax

	# return next block pointer
	ret


	# @FUNCTION
	#
	# PURPOSE
	# Get pointer to the beginning of previous block pointer
	#
	# ARGUMENTS
	# ARG0 (%rdi): Current block pointer
	#
	# RETURN
	# Previous block pointer
	#

	.global PREV_BLKP
	.type PREV_BLKP @function
PREV_BLKP:
	# save bp
	pushq %rdi
	
	# get pointer to prev block's footer
	subq $DSIZE, %rdi

	# get size of prev block, using footer
	callq GET_SIZE

	# retrieve bp
	popq %rdi

	# combine pointer and size to get prev (bp - size)
	subq %rax, %rdi
	movq %rdi, %rax

	# return prev block pointer
	ret

