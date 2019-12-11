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

	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp

open_input:	
	#open file syscall
	mov $2,%rax
	mov $input_file,%rdi
	mov $0,%rsi
	mov $0666,%rdx
	syscall

	# save result
	movq %rax, -8(%rbp)

open_output:
	mov $2,%rax
	mov $output_file,%rdi
	mov $O_CREAT_WRONLY_TRUNC,%rsi
	mov $0666,%rdx
	syscall

	# save result
	movq %rax, -16(%rbp)

	
loop:
	movq $0, %rax	# read
	movq -8(%rbp), %rdi
	movq $INPUT_BUFFER, %rsi
	movq $512, %rdx
	syscall

	#in case of end of file,  close file
	cmp $0,%rax
	je .exit

	jmp loop
	
.close_file:
	mov $3,%rax			# close system call
	mov -8(%rbp), %rdi		# get file descriptor - @TODO use common register / address?
	syscall


.exit:
	
	mov $60,%rax	# EXIT
	mov $0,%rdi	# 0 return code = success
	syscall
