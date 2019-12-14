
	.section .data
	
hello_world:
	.asciz "hello, world!\n"

	###############
	.section .text
	###############

	.globl _start
_start:
	movq $hello_world, %rdi
	callq printf

	movq $0, %rdi
	callq exit
