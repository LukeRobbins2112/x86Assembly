#####################################
	.section .data
#####################################

# file constants
	.equ STDIN, 0
	.equ STDOUT, 1

	.equ NEWLINE_CHAR, '\n'

# syscall constants
	.equ SYS_READ, 	0
	.equ SYS_WRITE,	1
	.equ SYS_EXIT,	60

	
	
#####################################	
	.section .bss
#####################################
	.equ 	BUFFER_SIZE, 512
	.lcomm 	DATA_BUFFER, BUFFER_SIZE

#####################################	
	.section .text
#####################################
	
	.global _start

_start:
	movq %rsp, %rbp			# store beginning of stack frame

loop:
read_data:	
	movq $SYS_READ, %rax	
	movq $STDIN, %rdi		# read from stdin	
	movq $DATA_BUFFER, %rsi		# store in temp buffer
	movq $BUFFER_SIZE, %rdx
	syscall

	#in case of end of file,  close file
	cmp $1,%rax
	je test_exit

convert_upper:
	pushq %rax			# save num bytes read
	movq $DATA_BUFFER, %rdi		# pass buffer as first arg
	movq %rax, %rsi			# pass data size as second arg
	callq to_upper			# convert data to uppercase
	popq %rax			# restore the buffer size value
	
write_data:	
	# write data to output
	movq %rax, %rdx			# buffer size to write
	movq $SYS_WRITE, %rax		# write system call
	movq $STDOUT, %rdi		# write to STDUOUT
	movq $DATA_BUFFER, %rsi		# buffer towrite
	syscall
	
	jmp loop

test_exit:
	cmpb $NEWLINE_CHAR, (%rsi)
	jne convert_upper
exit:
	movq %rbp, %rsp
	mov $SYS_EXIT, %rax	# EXIT
	mov $0,%rdi	# 0 return code = success
	syscall



################################################
	# To_Upper function
################################################
	#
	# REGISTERS
	#	%rdi	First arg - buffer location
	#	%rsi	Second arg - buffer length
	#
	#	%rcx	Byte offset from buffer start - used to get each char
	#	%rdx 	Holds individual chars - we use low byte register %dl
	#

	# case constants
	.equ LOWERCASE_A, 'a'
	.equ LOWERCASE_Z, 'z'
	.equ UPPER_CONVERSION, 'A' - 'a'


	.type to_uppper, @function
to_upper:
	cmpq $0, %rsi		# check buffer length
	je done_to_upper	# if zero, nothing to do

	movq $0, %rcx		# byte offset from start of DATA_BUFFER

loop_to_upper:
	movb (%rdi, %rcx, 1), %dl	# get character, store in low byte of register %rdx

	# check character against bounds
	# if char < 'a' or char > 'z' then skip it
	cmpb $LOWERCASE_A, %dl
	jl next_byte

	cmpb $LOWERCASE_Z, %dl
	jg next_byte

	addb $UPPER_CONVERSION, %dl
	movb %dl, (%rdi, %rcx, 1)

next_byte:
	incq %rcx
	cmpq %rcx, %rsi
	jne loop_to_upper


done_to_upper:
	rep; ret

	

	
	
