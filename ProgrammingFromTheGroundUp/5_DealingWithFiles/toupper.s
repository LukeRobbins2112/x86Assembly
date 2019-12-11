#####################################
	.section .data
#####################################

input_file:
	.asciz "input.txt"
output_file:
	.asciz "output.txt"

# file constants
	.equ O_CREAT_WRONLY_TRUNC, 03101

	.equ INPUT_FD, 	-8
	.equ OUTPUT_FD, -16

# syscall constants
	.equ SYS_READ, 	0
	.equ SYS_WRITE,	1
	.equ SYS_OPEN,	2
	.equ SYS_CLOSE,	3
	.equ SYS_EXIT,	60

#####################################	
	.section .bss
#####################################
	
	.lcomm DATA_BUFFER, 512

#####################################	
	.section .text
#####################################

	.global _start

_start:
	movq %rsp, %rbp
	subq $16, %rsp

open_input:	
	#open file syscall
	movq $SYS_OPEN,%rax
	# movq $input_file,%rdi
	movq 16(%rbp), %rdi
	movq $0,%rsi
	movq $0666,%rdx
	syscall

	# save result
	movq %rax, INPUT_FD(%rbp)

open_output:
	mov $SYS_OPEN,%rax
	mov $output_file,%rdi
	mov $O_CREAT_WRONLY_TRUNC,%rsi
	mov $0666,%rdx
	syscall

	# save result
	movq %rax, OUTPUT_FD(%rbp)

	
loop:
	movq $SYS_READ, %rax	
	movq INPUT_FD(%rbp), %rdi
	movq $DATA_BUFFER, %rsi
	movq $512, %rdx
	syscall

	#in case of end of file,  close file
	cmp $0,%rax
	je close_files

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
	mov $SYS_EXIT, %rax	# EXIT
	mov $0,%rdi	# 0 return code = success
	syscall
