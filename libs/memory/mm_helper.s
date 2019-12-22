

#############################
.section .rodata	# constants
#############################


WSIZE:
	.long 4
DSIZE:
	.long 8
CHUNKSIZE:
	.long (1 << 12)	# 4096 bytes

#########################	
.section .text
#########################

	#
	# @FUNCTION MAX
	#

	.type MAX @function
MAX:
	cmpq %rdi, %rsi
	jge MAX_SECOND
	movq %rdi, %rax
	ret
MAX_SECOND:
	movq %rsi, %rax
	ret
	


	#
	# @FUNCTION PACK
	#

	.type PACK @function
PACK:
	movq %rdi, %rax
	orq $1, %rax
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

	.type GET @function
GET:
	movq (%rdi), %rax
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

	.type PUT @function
PUT:
	movq %rsi, (%rdi)
	ret
	
