

	.include "linux.s"

######################################
.section .bss
######################################	

code_len:
	.long
msg_len:
	.long

	
#########################################
.section .text
#########################################

	#
	# @Function
	# error_exit	
	#
	# Prints error code + message
	#
	# Arguments
	#
	# Arg0 (%rdi): Error code string (memory address)
	# Arg1 (%rsi): Error message string (memory address)
	#

	.globl error_exit
	.type error_exit @function
error_exit:

	# save inputs
	pushq %rsi
	pushq %rdi

	# get code length
	callq count_chars
	# move length to SYS_write buffer size register
	movq %rax, %rdx
	
	# write error code to stderr
	movq $SYS_WRITE, %rax	
	movq $STDERR, %rdi
	popq %rsi		# arg0 (error code)
	syscall

	# get msg length (already on stack)
	callq count_chars
	movq %rax, %rdx

	# write errorm sg to stderr
	movq $SYS_WRITE, %rax	
	movq $STDERR, %rdi
	popq %rsi		# arg0 (error code)
	syscall

	# write a newline
	pushq $STDERR
	callq write_newline
	popq %rax
	
exit:
	movq $1, %rdi
	movq $SYS_EXIT, %rax
	syscall
	
	
