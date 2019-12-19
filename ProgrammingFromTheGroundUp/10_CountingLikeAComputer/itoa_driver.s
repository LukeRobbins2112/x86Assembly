
	.section .data
newline:
	.ascii "\n"
	
###################################
.section .bss
###################################

	.lcomm string_buffer, 8

###################################
.section .text
###################################


	.globl _start
_start:
	movq $123, %rdi
	movq $string_buffer, %rsi
	callq itoa

	movq $1, %rax 	# write syscall
	movq $1, %rdi	# STDOUT
	movq $string_buffer, %rsi
	movq $4, %rdx
	syscall

	# newline
	movq $1, %rax 	# write syscall
	movq $1, %rdi	# STDOUT
	movq $newline, %rsi
	movq $1, %rdx
	syscall

	# exit
	movq $0, %rdi
	movq $60, %rax
	syscall
