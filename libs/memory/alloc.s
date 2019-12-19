
	#
	# PROGRAM
	# Provide dynamic memory allocations, and manage blocks
	#

	# includes system calls and other constants
	.include "linux.s"



####################################
.section .data
####################################

	#  
	# Constants
	#
	.equ HEADER_SIZE, 16	# 8 bytes size + 8 bytes allocated/unallocated flag
	.equ SIZE_FIELD, 8	# header location of the size metadata
	.equ ALLOCATED_FIELD, 0	# header location of the allocated/unallocated flag

	.equ UNAVAILABLE, 0
	.equ AVAILABLE, 1

	#
	# Data
	#

heap_begin:
	.quad 0
current_break:
	.quad 0
	
####################################
.section .text
####################################


	#
	# @FUNCTION alloc_init
	#
	# Initializes our memory manager
	# Gives us the location of our program break,
	# so we have a defined start to our heap
	#
	
	.globl alloc_init
	.type alloc_init @function
alloc_init:

	# get the current program break
	# then increment to get first available address
	# calling brk with arg of 0 returns current break
	movq $0, %rdi
	movq $SYS_BRK, %rax
	syscall
	incq %rax

	# save address as beginning of heap
	movq %rax, heap_begin
	movq %rax, current_break
	
	# we have what we need to begin ; return from function
	ret

	

	
########## @FUNCTION allocate ####################################
	#
	# Retrieves a chunk of memory for the program
	# If there is a free block, use that
	# If not, ask Linux for more memory
	#
	# @PARAMETERS
	# Arg0 (%rdi): size of the block we want to allocate
	#
	# @RETURN
	# Returns the start address of the newly allocated block
	# Returns 0 if we can't allocate memory
	#

	.globl allocate
	.type allocate @function
allocate:

	# grab current_break & heap_begin
	movq current_break, %rsi
	movq heap_begin, %rax

alloc_loop_begin:
	
	# if current_break is at heap_begin, we need more memory
	cmpq %rsi, %rax
	je move_break	

	# check current block to see if it is available
	cmpq $UNAVAILABLE, ALLOCATED_FIELD(%rax)
	je next_location

	# check to see if the size is big enough
	# rdi holds requested size, rcx grabs size of block
	movq SIZE_FIELD(%rax), %rcx
	cmpq %rcx, %rdi
	jle allocate_here

next_location:

	# get size of current block
	movq SIZE_FIELD(%rax), %rcx

	# add size of block + size of header to current position
	addq $HEADER_SIZE, %rax
	addq %rcx, %rax

	# repeat the process
	jmp alloc_loop_begin

allocate_here:

	# mark space as unavailable
	movq $UNAVAILABLE, ALLOCATED_FIELD(%rax)

	# move to start of usable memory
	addq $HEADER_SIZE, %rax

	# return memory address to caller
	ret

move_break:
	# at this point we've used all our free memory
	# need to request from Linux
	# %rsi holds the current break location

	# add (header size + requested block) to break
	addq $HEADER_SIZE, %rsi
	addq %rdi, %rsi

	# request the memory
	pushq %rax		# save current heap position
	pushq %rdi		# save value of original argument
	movq $SYS_BRK, %rax
	movq %rsi, %rdi
	syscall

	# make sure it succeeded
	cmpq $0, %rax
	je error

	# restore saved registers
	popq %rdi
	popq %rax
	
	# set up block header
	movq $UNAVAILABLE, ALLOCATED_FIELD(%rax)
	movq %rdi, SIZE_FIELD(%rax)

	# move start of usable memory into return register
	addq $HEADER_SIZE, %rax

	# update current_break
	movq %rsi, current_break

	# return new block
	ret

error:
	# return 0 on error (as brk does to us)
	movq $0, %rax
	ret

########## END OF FUNCTION ############


#################### @FUNCTION deallocate ##########################
	#
	# PURPOSE
	# Return a chunk of memory to the pool once we're done using it
	#
	# ARGUMENTS
	# Arg0 (%rdi): The address of the memory we want to return to the pool
	#	Note: This is the start of the usable memory - have to move down to addess header
	#
	# RETURN
	# No return value
	#

	.globl deallocate
	.type deallocate @function
deallocate:

	# adjust memory location to point to start of header
	subq $HEADER_SIZE, %rdi

	# mark the block as available
	movq $AVAILABLE, ALLOCATED_FIELD(%rdi)
	
	# return (no value)
	ret

################### END OF FUNCTION #################################	
	
	
