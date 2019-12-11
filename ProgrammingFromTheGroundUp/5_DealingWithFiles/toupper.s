	.section .data

input_file:
	.asciz "input.txt"
output_file:
	.asciz "output.txt"

	.equ O_CREAT_WRONLY_TRUNC, 03101

	.equ INPUT_FD, 	-8
	.equ OUTPUT_FD, -16 

	.section .bss

	.lcomm INPUT_BUFFER, 512

	.section .text
	.global _start

_start:
	movq %rsp, %rbp
	subq $16, %rsp

open_input:	
	#open file syscall
	movq $2,%rax
	# movq $input_file,%rdi
	movq 16(%rbp), %rdi
	movq $0,%rsi
	movq $0666,%rdx
	syscall

	# save result
	movq %rax, INPUT_FD(%rbp)

open_output:
	mov $2,%rax
	mov $output_file,%rdi
	mov $O_CREAT_WRONLY_TRUNC,%rsi
	mov $0666,%rdx
	syscall

	# save result
	movq %rax, OUTPUT_FD(%rbp)

	
loop:
	movq $0, %rax	# read
	movq INPUT_FD(%rbp), %rdi
	movq $INPUT_BUFFER, %rsi
	movq $512, %rdx
	syscall

	#in case of end of file,  close file
	cmp $0,%rax
	je close_files

	# write data to output
	movq %rax, %rdx			# buffer size to write
	movq $1, %rax			# write system call
	movq OUTPUT_FD(%rbp), %rdi	# output fd
	movq $INPUT_BUFFER, %rsi	# buffer towrite
	syscall
	
	jmp loop
	
close_files:
	movq $3,%rax			# close system call
	movq INPUT_FD(%rbp), %rdi		# get file descriptor - @TODO use common register / address?
	syscall

	movq $3, %rax
	movq OUTPUT_FD(%rbp), %rdi
	syscall

exit:
	mov $60,%rax	# EXIT
	mov $0,%rdi	# 0 return code = success
	syscall
