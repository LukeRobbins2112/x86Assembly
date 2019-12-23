
	.include "mm_helper.s"
	.include "../../includes/linux.s"

#############################	
.section .data
#############################

	.equ MAX_MEM_REQUEST, (1 << 12)

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
	# Get initial program break
	movq $0, %rdi
	movq $SYS_BRK, %rax
	syscall

	ret

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
	
