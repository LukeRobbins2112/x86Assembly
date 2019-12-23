
	.include "mm_helper.s"
	.include "../../includes/linux.s"

#############################	
.section .data
#############################



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
