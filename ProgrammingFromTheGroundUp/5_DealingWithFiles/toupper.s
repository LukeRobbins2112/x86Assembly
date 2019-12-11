#####################################
	.section .data
#####################################

input_file:
	.asciz "input.txt"
output_file:
	.asciz "output.txt"

# file constants
	.equ O_RDONLY, 0
	.equ O_CREAT_WRONLY_TRUNC, 03101
	.equ FILE_PERMS, 0666

	.equ ARGV2_POS, 24	# output file
	.equ ARGV1_POS, 16	# input file
	.equ ARGV0_POS, 8	# program name
	.equ ARGC_POS,	0	# num args

	.equ STACK_STORAGE, 16	# amount of space for storing FDs 
	.equ INPUT_FD, 	-8	# local storage for input file FD
	.equ OUTPUT_FD, -16	# local storage for output file FD

# syscall constants
	.equ SYS_READ, 	0
	.equ SYS_WRITE,	1
	.equ SYS_OPEN,	2
	.equ SYS_CLOSE,	3
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
	movq %rsp, %rbp
	subq $STACK_STORAGE, %rsp

open_input:	
	#open file syscall
	movq $SYS_OPEN, %rax
	# movq $input_file,%rdi
	movq ARGV1_POS(%rbp), %rdi
	movq $O_RDONLY, %rsi
	movq $FILE_PERMS,%rdx
	syscall

	# save result
	movq %rax, INPUT_FD(%rbp)

open_output:
	mov $SYS_OPEN,%rax
	# mov $output_file,%rdi
	movq ARGV2_POS(%rbp), %rdi
	mov $O_CREAT_WRONLY_TRUNC,%rsi
	mov $0666,%rdx
	syscall

	# save result
	movq %rax, OUTPUT_FD(%rbp)

	
loop:
read_data:	
	movq $SYS_READ, %rax	
	movq INPUT_FD(%rbp), %rdi
	movq $DATA_BUFFER, %rsi
	movq $BUFFER_SIZE, %rdx
	syscall

	#in case of end of file,  close file
	cmp $0,%rax
	je close_files

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
	movq OUTPUT_FD(%rbp), %rdi	# output fd
	movq $DATA_BUFFER, %rsi		# buffer towrite
	syscall
	
	jmp loop
	
close_files:
	movq $SYS_CLOSE, %rax			# close system call
	movq INPUT_FD(%rbp), %rdi		# get file descriptor - @TODO use common register / address?
	syscall

	movq $SYS_CLOSE, %rax
	movq OUTPUT_FD(%rbp), %rdi
	syscall

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

	

	
	
