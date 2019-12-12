	.section .data

print_text:
	.asciz "hello, world!\n"

	.section .text

	.globl _start
_start:
	#stdout FD is already open
	movq $1, %rax		# write
	movq $1, %rdi		# STDOUT
	movq $print_text, %rsi	# text to print
	movq $15, %rdx		# size of buffer to print
	syscall

	movq $60, %rax
	movq $0, %rdi
	syscall
